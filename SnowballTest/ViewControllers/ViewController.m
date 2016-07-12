//
//  ViewController.m
//  SnowballTest
//
//  Created by Han Quoc Han on 7/10/16.
//  Copyright © 2016 Co-Bro Company. All rights reserved.
//

#import "ViewController.h"
#import "VideoTableViewCell.h"
#import "Utility.h"
#import "PlayerManager.h"
#import "VideoPlayerViewController.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, VideoTableViewCellDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tbView;
@property (nonatomic, strong) NSArray *listVideos;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Video Player";
    // Do any additional setup after loading the view, typically from a nib.
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithTitle:@"Play All" style:UIBarButtonItemStyleDone target:self action:@selector(btnPlayAll_Clicked:)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc] initWithTitle:@"Animation" style:UIBarButtonItemStyleDone target:self action:@selector(btnChangeAnimation_Clicked:)];
    self.navigationItem.leftBarButtonItem = leftItem;
    [self setupDataForTesting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (void)setupDataForTesting {
    self.listVideos = @[@"http://media.snowballnow.com/video/upload/v1466430342/xo2jvulyira9mtl1wevz.mp4",
                        @"http://media.snowballnow.com/video/upload/v1450752299/deff3bxsmpsrow4i40e0.mp4",
                        @"http://media.snowballnow.com/video/upload/v1450787135/poareeehaxfqhcyavnnl.mp4"];
    [_tbView reloadData];
}

- (void)playVideos:(NSArray *)videos {
    VideoPlayerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"VideoVC"];
    [self.navigationController presentViewController:vc animated:YES completion:^{
        [[PlayerManager sharedInstance] playItems:videos];
        [[PlayerManager sharedInstance] showAtView:vc.view];
    }];
}

#pragma mark - UIEvent
- (void)btnPlayAll_Clicked:(id)sender {
    [self playVideos:self.listVideos];
}

- (void)btnChangeAnimation_Clicked:(id)sender {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Change animation type" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"Fade" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PlayerManager sharedInstance].videoAnimation = VideoAnimationFade;
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Slide" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PlayerManager sharedInstance].videoAnimation = VideoAnimationSlide;
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"None" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [PlayerManager sharedInstance].videoAnimation = VideoAnimationNone;
    }]];
    [self presentViewController:controller animated:YES completion:nil];
    
}
#pragma mark - UITableViewDatasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _listVideos.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"VideoTableViewCell";
    VideoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    [cell setupWithLink:_listVideos[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 150.f;
}

#pragma mark - VideoTableViewCellDelegate
- (void)videoCellDidClickedPlay:(VideoTableViewCell *)cell {
    NSIndexPath *indexPath = [_tbView indexPathForCell:cell];
    if (indexPath) {
        NSString *videoLink = _listVideos[indexPath.row];
        [self playVideos:@[videoLink]];
    }
}

@end
