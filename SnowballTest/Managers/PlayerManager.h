//
//  PlayerManager.h
//  SnowballTest
//
//  Created by Han Quoc Han on 7/10/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef enum {
    VideoAnimationFade,
    VideoAnimationSlide,
    VideoAnimationNone
} VideoAnimation;

@interface PlayerManager : NSObject
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) AVPlayer *preloadAVPlayer;
@property (nonatomic, strong) AVPlayerLayer *avPlayerLayer;
@property (nonatomic, strong) UIView *avPlayerView;
@property (nonatomic, strong) AVPlayerItem *preloadPlayerItem;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, readwrite) VideoAnimation videoAnimation;
+ (instancetype)sharedInstance;
- (void)playItems:(NSArray *)items;
- (void)stop;
- (void)showAtView:(UIView *)presentView;
@end
