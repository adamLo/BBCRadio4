//
//  BBCProgramCollectionViewCell.m
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import "BBCProgramCollectionViewCell.h"
#import "ImageCache.h"
#import "DataManager.h"

@interface BBCProgramCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView; //Photo thumbnail
@property (weak, nonatomic) IBOutlet UILabel *titleLabel; //Program title

@property (weak, nonatomic) IBOutlet UIView *missedCoverView; //View to display when a program is missed
@property (weak, nonatomic) IBOutlet UILabel *missedCoverLabel;

//Retain schedule dates
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;

@end

@implementation BBCProgramCollectionViewCell

NSString* const bbcProgramCellIdentifier = @"ProgramCell";
NSTimeInterval const kmissedAnimationDuration = 0.3; //Animation duration to show missed cover

- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    //Add some background to totle to increase readability
    self.titleLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    
    //Make corners rounded
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 5.0;
    
    [self setupMissedCover];
}

- (void)setupWithBroadcast:(NSDictionary*)broadcast {
    
    NSDictionary *program = broadcast[@"programme"];
    NSDictionary *displayTitles = program[@"display_titles"];
    
    //Display title
    NSString *title = displayTitles[@"title"];
    self.titleLabel.text = title ? title : NSLocalizedString(@"No title", @"No title");
    
    //Fetchj photo
    NSString *imageId = program[@"image"][@"pid"];
    if (imageId) {
        __weak typeof(self) weakSelf = self;
        [[ImageCache sharedInstance] fetchImageWithIdentifier:imageId completion:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.thumbnailImageView.image = image;
            });
        }];
    }
    
    //Display missed cover
    NSString *startString = broadcast[@"start"];
    NSString *endString = broadcast[@"end"];
    if (startString && endString) {
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = bbcScheduleDateFormat;
        self.startDate = [formatter dateFromString:startString];
        self.endDate = [formatter dateFromString:endString];
    }
    [self checkMissedAnimated:NO];
}

- (void)prepareForReuse {
    
    self.thumbnailImageView.image = nil;
    self.titleLabel.text = nil;
    self.startDate = nil;
    self.endDate = nil;
    self.missedCoverView.hidden = YES;
}

- (void)setupMissedCover {
    
    self.missedCoverView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.7];
    self.missedCoverLabel.textColor = [UIColor redColor];
    self.missedCoverLabel.text = NSLocalizedString(@"MISSED", @"Missed title");
    self.missedCoverView.hidden = YES;
}

- (void)checkMissedAnimated:(BOOL)animated {
    
    if (self.startDate && self.endDate) {
        
        NSDate *now = [NSDate date];
        if ([now compare:self.endDate] == NSOrderedDescending) {
            //Missed
            if (animated) {
                //Possible feature: add a timer to check status on the fly and isplay cover real time with animation
                [UIView animateWithDuration:kmissedAnimationDuration animations:^{
                    self.missedCoverView.alpha = 0.0;
                    self.missedCoverView.hidden = NO;
                } completion:^(BOOL finished) {
                    self.missedCoverView.alpha = 1.0;
                }];
            }
            else {
                self.missedCoverView.hidden = NO;
            }
        }
    }
    else {
        self.missedCoverView.hidden = YES;
    }
}

@end
