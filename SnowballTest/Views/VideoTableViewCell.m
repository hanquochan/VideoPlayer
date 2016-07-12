//
//  VideoTableViewCell.m
//  SnowballTest
//
//  Created by Han Quoc Han on 7/10/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import "VideoTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
#import "Utility.h"

@implementation VideoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)showLoading:(BOOL)isShow {
    if (isShow) {
        [self.activityLoading startAnimating];
    } else {
        [self.activityLoading stopAnimating];
    }
}

- (IBAction)btnPlay_Clicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoCellDidClickedPlay:)]) {
        [self.delegate videoCellDidClickedPlay:self];
    }
}

- (void)setupWithLink:(NSString *)link {
    [self.activityLoading startAnimating];
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL URLWithString:link] options:nil];
    [Utility generateImage:asset completedBlock:^(UIImage *img) {
        [self.activityLoading stopAnimating];
        self.imvImage.image = img;
    }];
}
@end
