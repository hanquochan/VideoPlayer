//
//  Utility.h
//  SnowballTest
//
//  Created by Han Quoc Han on 7/10/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Utility : NSObject
// generate first image of video to display as thumbnail
+ (UIImage *)getFirstImageOfVideo:(AVAsset *)asset time:(CMTime)time; // completedBlock:(void(^)(UIImage *img))completedBlock;
+ (void)generateImage:(AVURLAsset *)asset completedBlock:(void(^)(UIImage *img))completedBlock;
@end
