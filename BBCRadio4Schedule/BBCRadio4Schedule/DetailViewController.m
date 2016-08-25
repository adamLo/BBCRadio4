//
//  DetailViewController.m
//  BBCRadio4Schedule
//
//  Created by IG on 08/09/2015.
//  Copyright (c) 2015 Super Cool Start-up. All rights reserved.
//

#import "DetailViewController.h"
#import "DataManager.h"
#import "ImageCache.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeight;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void) viewWillAppear:(BOOL)animated {

    [super viewWillAppear:animated];
    
    // Update the view.
    [self configureView];
}

- (void)configureView {
    // Update the user interface for the detail item.

    NSDictionary *program = self.detailItem[@"programme"];
    NSDictionary *displayTitles = program[@"display_titles"];
    
    NSString *title = displayTitles[@"title"] ? displayTitles[@"title"] : NSLocalizedString(@"No title", @"No title");
    NSString *subTitle = displayTitles[@"subtitle"];
    NSString *startString = self.detailItem[@"start"];
    NSString *endString = self.detailItem[@"end"];
    NSNumber *duration = self.detailItem[@"duration"];
    NSString *shortSynopsis = program[@"short_synopsis"];
    NSString *type = program[@"type"];
    
    self.title = title;
    
    UIFont *titleFont = [UIFont boldSystemFontOfSize:16.0];
    UIColor *textColor = [UIColor blackColor];
    UIFont *subtitleFont = [UIFont systemFontOfSize:14.0];
    UIFont *boldFont = [UIFont boldSystemFontOfSize:12.0];
    UIFont *normalFont = [UIFont systemFontOfSize:12.0];
    
    NSMutableParagraphStyle *paragraphStyle = NSMutableParagraphStyle.new;
    paragraphStyle.alignment                = NSTextAlignmentCenter;
    
    //Start description with title
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                                                                                                           NSFontAttributeName: titleFont,
                                                                                                           NSForegroundColorAttributeName: textColor,
                                                                                                           NSParagraphStyleAttributeName: paragraphStyle
                                                                                                           }];
    if (subTitle) {
        //Add subtitle if we have
        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:subTitle attributes:@{
                                                                                                      NSFontAttributeName: subtitleFont,
                                                                                                      NSForegroundColorAttributeName: textColor,
                                                                                                      NSParagraphStyleAttributeName: paragraphStyle
                                                                                                 }]];
    }
    
    BOOL durationDisplayed = NO;
    if (startString && endString) {
        //Add schedule start and end with duration
        
        NSDateFormatter *formatter = [NSDateFormatter new];
        formatter.dateFormat = bbcScheduleDateFormat;
        NSDate *start = [formatter dateFromString:startString];
        NSDate *end = [formatter dateFromString:endString];
        if (start && end) {
        
            formatter.dateStyle = NSDateFormatterShortStyle;
            formatter.timeStyle = NSDateFormatterShortStyle;
            NSString *schedule = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:start], [formatter stringFromDate:end]];
            
            if (duration.integerValue) {
                NSInteger hours = (NSInteger)(duration.doubleValue / 3600);
                NSInteger minutes = (duration.integerValue - (hours * 3600)) / 60;
                schedule = [schedule stringByAppendingString:[NSString stringWithFormat:@" (%li:%li)", (long)hours, (long)minutes]];
            }
            
            [desc appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
            [desc appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Schedule: ", @"schedule title") attributes:@{
                                                                                                          NSFontAttributeName: boldFont,
                                                                                                          NSForegroundColorAttributeName: textColor,
                                                                                                          }]];
            [desc appendAttributedString:[[NSAttributedString alloc] initWithString:schedule attributes:@{
                                                                                                                                                     NSFontAttributeName: normalFont,                                                                                                                                                 NSForegroundColorAttributeName: textColor,
                                                                                                                                                     }]];
            durationDisplayed = YES;
        }
    }
    
    if (type) {
        //Add type if we have
        if (!durationDisplayed) {
            [desc appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        }
        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n"]];
        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:NSLocalizedString(@"Type: ", @"Type title") attributes:@{
                                                                                                                                                 NSFontAttributeName: boldFont,
                                                                                                                                                 NSForegroundColorAttributeName: textColor,
                                                                                                                                                 }]];
        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:type attributes:@{
                                                                                                           NSFontAttributeName: normalFont,                                                                                                                                                 NSForegroundColorAttributeName: textColor,                                                                                                           }]];
    }
    
    if (shortSynopsis) {
        //Add short synopsis
        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n"]];
        [desc appendAttributedString:[[NSAttributedString alloc] initWithString:shortSynopsis attributes:@{
                                                                                                      NSFontAttributeName: normalFont,                                                                                                                                                 NSForegroundColorAttributeName: textColor,                                                                                                      }]];
    }
    
    self.descriptionLabel.attributedText = desc;
    
    //Update content to make scrollable if needed
    CGRect textFrame = [desc boundingRectWithSize:CGSizeMake(self.view.bounds.size.width - 10, 10000) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    self.contentHeight.constant = self.descriptionLabel.frame.origin.y + textFrame.size.height + 10.0;
    [self.view layoutIfNeeded];
    
    //Fetch Photo
    NSString *imageId = program[@"image"][@"pid"];
    if (imageId) {
        __weak typeof(self) weakSelf = self;
        [[ImageCache sharedInstance] fetchImageWithIdentifier:imageId completion:^(UIImage *image) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.photoImageView.image = image;
            });
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
