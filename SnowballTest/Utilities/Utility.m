//
//  Utility.m
//  SnowballTest
//
//  Created by Han Quoc Han on 7/10/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import "Utility.h"

@implementation Utility
+ (UIImage *)getFirstImageOfVideo:(AVAsset *)asset time:(CMTime)time {// completedBlock:(void(^)(UIImage *img))completedBlock {
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    CGImageRef imgRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:nil];
    UIImage* thumbnail = [[UIImage alloc] initWithCGImage:imgRef scale:UIViewContentModeScaleAspectFit orientation:UIImageOrientationUp];
    return thumbnail;
}

+ (void)generateImage:(AVURLAsset *)asset completedBlock:(void(^)(UIImage *img))completedBlock {
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform=TRUE;
    CMTime thumbTime = CMTimeMakeWithSeconds(0,30);
    generator.requestedTimeToleranceAfter = kCMTimeZero;
    generator.requestedTimeToleranceBefore = kCMTimeZero;
    
    AVAssetImageGeneratorCompletionHandler handler = ^(CMTime requestedTime, CGImageRef im, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error){
        if (result != AVAssetImageGeneratorSucceeded) {
            NSLog(@"couldn't generate thumbnail, error:%@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                completedBlock(nil);
            });
        } else {
            UIImage *img = [UIImage imageWithCGImage:im];
            dispatch_async(dispatch_get_main_queue(), ^{
                completedBlock(img);
            });
        }
    };
    [generator generateCGImagesAsynchronouslyForTimes:[NSArray arrayWithObject:[NSValue valueWithCMTime:thumbTime]] completionHandler:handler];
}
@end
