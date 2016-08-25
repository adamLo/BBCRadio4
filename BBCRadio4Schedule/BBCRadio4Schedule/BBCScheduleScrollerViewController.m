//
//  BBCScheduleScrollerViewController.m
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import "BBCScheduleScrollerViewController.h"
#import "BBCProgramCollectionViewCell.h"
#import "BBCProgramCollectionViewCell.h"

#import "DataManager.h"

@interface BBCScheduleScrollerViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UILabel *noScheduleLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *scheduleCollectionView;

@property (nonatomic, weak) NSArray *broadcasts;

@end

@implementation BBCScheduleScrollerViewController

NSString* const bbcScheduleScrollerStoryboardIdentifier = @"ScheduleViewController";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.scheduleCollectionView.backgroundColor = [UIColor clearColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)refreshWithScheduleKey:(NSString*)scheduleKey {
    
    NSDictionary *schedule = [[DataManager sharedInstance] scheduleForKey:scheduleKey];
    NSDictionary *day = schedule[@"schedule"][@"day"];
    self.broadcasts = day[@"broadcasts"];
    
    //Toggle placeholder if no data available
    self.noScheduleLabel.hidden = self.broadcasts.count > 0;
    self.scheduleCollectionView.hidden = self.broadcasts.count == 0;
    
    [self.scheduleCollectionView reloadData];
}

- (void)setupNoScheduleLabel {
    
    self.noScheduleLabel.text = NSLocalizedString(@"NO SCHEDULE", @"No schedule title");
    self.noScheduleLabel.font = [UIFont boldSystemFontOfSize:18.0];
}

#pragma mark - Collectionview

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _broadcasts.count;
}

- (UICollectionViewCell*)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    BBCProgramCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:bbcProgramCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *broadcast = self.broadcasts[indexPath.row];
    
    [cell setupWithBroadcast:broadcast];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    
    NSDictionary *broadcast = self.broadcasts[indexPath.row];
    if (self.programSelected) {
        self.programSelected(broadcast);
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize size = CGSizeMake(collectionView.bounds.size.height, collectionView.bounds.size.height);
    return size;
}

@end
