//
//  BBCScheduleScrollerTableViewCell.h
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const bbcScheduleCellIdentifier;

/**
 *  Cell prototype to display scroller with schedules
 */
@interface BBCScheduleScrollerTableViewCell : UITableViewCell

/**
 *  Needed for view controller instantiation
 */
@property (nonatomic, weak) UIStoryboard *storyboard;

/**
 *  Set up cell for specified section
 *
 *  @param scheduleKey     Section key
 *  @param programSelected Block to execute when a thumbnail touched
 */
- (void)setupWithScheduleKey:(NSString*)scheduleKey programSelected:(void(^)(NSDictionary *program))programSelected;

/**
 *  Needed to maintain controller hiearchy
 *
 *  @param controller Host controller to attach child controller to
 */
- (void)willDisplayCellInController:(UIViewController*)controller;

/**
 *  Will detach child controller when not needed
 */
- (void)didFinishDisplayingCell;

@end
