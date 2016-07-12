//
//  VideoTableViewCell.h
//  SnowballTest
//
//  Created by Han Quoc Han on 7/10/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VideoTableViewCell;
@protocol VideoTableViewCellDelegate <NSObject>
@optional
- (void)videoCellDidClickedPlay:(VideoTableViewCell *)cell;

@end

@interface VideoTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityLoading;
@property (weak, nonatomic) IBOutlet UIImageView *imvImage;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
@property (weak, nonatomic) id<VideoTableViewCellDelegate> delegate;
- (void)showLoading:(BOOL)isShow;
- (void)setupWithLink:(NSString *)link;
@end
