//
//  PlayerManager.m
//  SnowballTest
//
//  Created by Han Quoc Han on 7/10/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import "PlayerManager.h"
#import "Utility.h"

@interface PlayerManager()
@property (nonatomic, strong) NSArray *listItems;
@property (nonatomic, strong) NSString *currentPlayLink;
@property (nonatomic, strong) UIImageView *imgViewLastVideo;
@end

@implementation PlayerManager
+ (instancetype)sharedInstance {
    static PlayerManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PlayerManager alloc] init];
        
        // Do any other initialisation stuff here
    });
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        _videoAnimation = VideoAnimationFade;
    }
    return self;
}

#pragma mark - Public Methods
- (void)playItems:(NSArray *)items {
    [self stop];
    self.listItems = items;
    if (items.count > 0) {
        [self playItem:items.firstObject];
    }
}

- (void)showAtView:(UIView *)presentView {
    self.containerView = presentView;
    self.avPlayerLayer.frame = CGRectMake(0, 0, presentView.frame.size.width, presentView.frame.size.height);;
    self.avPlayerView.frame = CGRectMake(0, 0, presentView.frame.size.width, presentView.frame.size.height);
    [presentView insertSubview:self.avPlayerView atIndex:0];
}

- (void)stop {
    // remove all observer registered with this view controll first. Try catch these codes to make sure app will not crash if we remove it again or not yet registered.
    @try {
        [self.preloadPlayerItem removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *exception) {}
    @try {
        [self.preloadPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    } @catch (NSException *exception) {}
    @try {
        [self.avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    } @catch (NSException *exception) {}
    @try {
        [self.avPlayer.currentItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    } @catch (NSException *exception) {}
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    // reset all objects.
    [self.avPlayer pause];
    [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
    self.avPlayer = nil;
    [self.preloadAVPlayer pause];
    [self.preloadAVPlayer replaceCurrentItemWithPlayerItem:nil];
    self.preloadAVPlayer = nil;
    self.preloadPlayerItem = nil;
    self.listItems = nil;
    [self.avPlayerLayer removeFromSuperlayer];
    self.avPlayerLayer = nil;
    [self.avPlayerView removeFromSuperview];
    self.avPlayerView = nil;
}

#pragma mark - Private Method
- (void)playItem:(NSString *)videoLink {
    self.currentPlayLink = videoLink;
    // play current item
    /* check if the current player is not yet created-> create new one.
     If not, just replace the current item
     The idea is when play current item, we will use other AVPlayer to preload next video.
    After that, when start to play next video, we just need check if the current preload player is ready, swap it with current player and make current player become preload player */

    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL URLWithString:videoLink]];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
    if (!self.avPlayer) {
        self.avPlayer = [[AVPlayer alloc] initWithPlayerItem:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        [self preloadNextItem];
        [self.avPlayer play];
    } else{
        @try {
            [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"status"];
            [[self.avPlayer currentItem] removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
            [self.preloadPlayerItem removeObserver:self forKeyPath:@"status"];
            [self.preloadPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        } @catch (NSException *exception) {
        }
        AVURLAsset *preloadAsset = (AVURLAsset *)self.preloadPlayerItem.asset;
        /* check if the preload player is ready, if yes, swap player and make animation 
         If not, just use current player to load next item like normal */
        if (preloadAsset && self.preloadPlayerItem.status == AVPlayerStatusReadyToPlay) {
            [self.preloadPlayerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
            [self.preloadPlayerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
            /* To make animation smooth and user can't see the gap when we switch video, the idea is create one image for last frame of current video and first image of next video and add to current player view.
             After animation time we remove these images.
             */
            UIImage *imgOld = [Utility getFirstImageOfVideo:self.avPlayer.currentItem.asset time:self.avPlayer.currentItem.duration];
            UIImage *imgNew = [Utility getFirstImageOfVideo:preloadAsset time:kCMTimeZero];
            UIImageView *imvOld = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
            UIImageView *imvNew = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height)];
            imvNew.contentMode = UIViewContentModeScaleAspectFit;
            imvOld.contentMode = UIViewContentModeScaleAspectFit;
            imvOld.image = imgOld;
            imvNew.image = imgNew;
            [self.avPlayerView addSubview:imvOld];
            [self.avPlayerView addSubview:imvNew];
            [self.avPlayerLayer removeFromSuperlayer];
#if TARGET_IPHONE_SIMULATOR
            [self.avPlayerLayer setPlayer:self.preloadAVPlayer];
#endif
            //made animation
            void (^playBlock)() = ^() {
                [imvOld removeFromSuperview];
                [imvNew removeFromSuperview];
                [self swapPlayer:&_avPlayer otherPlayer:&_preloadAVPlayer];
                [self.avPlayerLayer setPlayer:self.avPlayer];
                [self.avPlayerView.layer addSublayer:self.avPlayerLayer];
                [self.avPlayer seekToTime:kCMTimeZero];
                [self.avPlayer play];
                [self preloadNextItem];
            };
            if (_videoAnimation == VideoAnimationFade) {
                imvNew.alpha = 0.0f;
                [UIView animateWithDuration:1.0f animations:^{
                    imvNew.alpha = 1.0f;
                    imvOld.alpha = 0.0f;
                } completion:^(BOOL finished) {
                    playBlock();
                }];
            } else if (_videoAnimation == VideoAnimationNone) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    playBlock();
                });
            } else if (_videoAnimation == VideoAnimationSlide) {
                imvNew.frame = CGRectMake(self.containerView.frame.size.width, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
                [UIView animateWithDuration:0.3f animations:^{
                    imvNew.frame = CGRectMake(0, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
                    imvOld.frame = CGRectMake(-self.containerView.frame.size.width, 0, self.containerView.frame.size.width, self.containerView.frame.size.height);
                } completion:^(BOOL finished) {
                    playBlock();
                }];

            }
            //[self.avPlayerLayer setPlayer:self.preloadAVPlayer];
        } else {
            [self.avPlayer replaceCurrentItemWithPlayerItem:nil];
            [self.avPlayer replaceCurrentItemWithPlayerItem:playerItem];
            [self.avPlayer seekToTime:kCMTimeZero];
            [playerItem addObserver:self forKeyPath:@"status" options:0 context:nil];
            [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
            [self preloadNextItem];
            [self.avPlayer play];
        }
    }
    if (!self.avPlayerLayer) {
        self.avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
        self.avPlayerView = [[UIView alloc] initWithFrame:CGRectZero];
        [self.avPlayerView.layer addSublayer:self.avPlayerLayer];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(playerItemDidReachEnd:)
                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                   object:nil];
    }
    // preload next items
    
    
}

- (void)preloadNextItem {
    /* the idea is when play current item, we will use other AVPlayer to preload next video.
     After that, when start to play next video, we just need check if the current preload player is ready, swap it with current player and make current player become preload player */
    NSInteger currentIndex = [self.listItems indexOfObject:self.currentPlayLink];
    if ((currentIndex + 1) < self.listItems.count) {
        AVAsset *nextAsset = [AVAsset assetWithURL:[NSURL URLWithString:self.listItems[currentIndex + 1]]];
        @try {
            [self.preloadPlayerItem removeObserver:self forKeyPath:@"status"];
            [self.preloadPlayerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
        } @catch (NSException *exception) {
            
        }
        self.preloadPlayerItem = [AVPlayerItem playerItemWithAsset:nextAsset];
        if (!self.preloadAVPlayer) {
            self.preloadAVPlayer = [[AVPlayer alloc] initWithPlayerItem:_preloadPlayerItem];
        } else {
            [self.preloadAVPlayer replaceCurrentItemWithPlayerItem:_preloadPlayerItem];
        }
    }
}

- (void)playNextItem {
    NSInteger currentIndex = [self.listItems indexOfObject:self.currentPlayLink];
    if ((currentIndex + 1) < self.listItems.count) {
        [self playItem:self.listItems[currentIndex + 1]];
    }
}

- (void)swapPlayer:(AVPlayer * __strong*)avPlayer1 otherPlayer:(AVPlayer *__strong*)avPlayer2 {
    AVPlayer* swap = *avPlayer1;
    *avPlayer1 = *avPlayer2;
    *avPlayer2 = swap;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    if ([self.avPlayer currentItem] == [notification object]) {
        [self playNextItem];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[AVPlayerItem class]]) {
        AVPlayerItem *item = (AVPlayerItem *)object;
        if ([keyPath isEqualToString:@"status"]) {
            switch(item.status) {
                case AVPlayerItemStatusFailed:
                    [self playNextItem];
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    break;
                case AVPlayerItemStatusUnknown:
                    break;
            }
        } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
            /* handle the property "playbackLikelyToKeepUp" to resume the player */
            if (object == self.avPlayer.currentItem) {
                if (self.avPlayer.currentItem.playbackLikelyToKeepUp == YES &&
                    CMTIME_COMPARE_INLINE(self.avPlayer.currentTime, >, kCMTimeZero) &&
                    CMTIME_COMPARE_INLINE(self.avPlayer.currentTime, !=, self.avPlayer.currentItem.duration)) {
                    [self.avPlayer play];
                }
            } else {
                NSLog(@"AAA");
            }
        }
    }
}
@end
