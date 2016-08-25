//
//  BBCScheduleScrollerTableViewCell.m
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import "BBCScheduleScrollerTableViewCell.h"
#import "BBCScheduleScrollerViewController.h"

NSString* const bbcScheduleCellIdentifier = @"ScheduleCell";

@interface BBCScheduleScrollerTableViewCell()

@property (nonatomic, strong) BBCScheduleScrollerViewController *scroller;

@end

@implementation BBCScheduleScrollerTableViewCell

@synthesize scroller = _scroller;

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setupWithScheduleKey:(NSString*)scheduleKey programSelected:(void(^)(NSDictionary *program))programSelected {
    
    [self.scroller refreshWithScheduleKey:scheduleKey];
    self.scroller.programSelected = programSelected;
}

- (BBCScheduleScrollerViewController*)scroller {
    
    if (!_scroller) {
        //Lazy load a scroller controller
        _scroller = [self.storyboard instantiateViewControllerWithIdentifier:bbcScheduleScrollerStoryboardIdentifier];
        _scroller.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scroller.view.frame = CGRectMake(0, 0, self.contentView.bounds.size.width, self.contentView.bounds.size.height);
        [self addSubview:_scroller.view];
    }
    
    return _scroller;
}

- (void)setScroller:(BBCScheduleScrollerViewController *)scroller {
    
    _scroller = scroller;
}

- (void)prepareForReuse {
    
    _scroller.programSelected = nil;
}

- (void)willDisplayCellInController:(UIViewController*)controller {
    
    [controller addChildViewController:self.scroller];
}

- (void)didFinishDisplayingCell {
    
    [self.scroller removeFromParentViewController];
}

@end
