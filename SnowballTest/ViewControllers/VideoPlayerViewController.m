//
//  VideoPlayerViewController.m
//  SnowballTest
//
//  Created by Han Quoc Han on 7/12/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import "VideoPlayerViewController.h"
#import "PlayerManager.h"

@interface VideoPlayerViewController ()

@end

@implementation VideoPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)btnClose_Clicked:(id)sender {
    [[PlayerManager sharedInstance] stop];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
