# VideoPlayer
Video Player with no delay when change video.

# The idea for make feeling like playing 1 video
To play video i'm using AVPlayer. When we play multiple videos and play sequentially, there is a gap when switch video.
The idea to make feeling like playing 1 video is:
When play current item, we will use other AVPlayer to preload next video. 
After that, when start to play next video, we just need check if the current preload player is ready, swap it with current player and make current player become preload player, if not just replace current video with next video like normal.
So we will have maximum two players: one for play and one for preload.
Other idea is use AVQueuePlayer to play list videos. It supports preload next video smoothly and has no gap.But when implement animation for switch video and for the furture we want to customize somethings, it will be hard to custom it. So i decide to keep the option 1, use two avplayer.

# How did we do that

#H4 Create preload AVPlayer

    self.preloadPlayerItem = [AVPlayerItem playerItemWithAsset:nextAsset];
    if (!self.preloadAVPlayer) {
        self.preloadAVPlayer = [[AVPlayer alloc] initWithPlayerItem:_preloadPlayerItem];
    } else {
        [self.preloadAVPlayer replaceCurrentItemWithPlayerItem:_preloadPlayerItem];
    }

#H4 When switch to next video
 Check if the preload player is ready, if yes, swap player and make animation 
If not, just use current player to load next item like normal 

    if (preloadAsset && self.preloadPlayerItem.status == AVPlayerStatusReadyToPlay)

#H4 Make animation
To make animation smooth and user can't see the gap when we switch video, the idea is create one image for last frame of current video and first image of next video and add to current player view.
After animation time we remove these images.

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

#H4 Switch video player

    [self swapPlayer:&_avPlayer otherPlayer:&_preloadAVPlayer];
    [self.avPlayerLayer setPlayer:self.avPlayer];
    [self.avPlayerView.layer addSublayer:self.avPlayerLayer];
    [self.avPlayer seekToTime:kCMTimeZero];
    [self.avPlayer play];
    [self preloadNextItem];

#