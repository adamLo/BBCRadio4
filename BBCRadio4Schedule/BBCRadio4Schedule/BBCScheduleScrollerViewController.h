//
//  BBCScheduleScrollerViewController.h
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const bbcScheduleScrollerStoryboardIdentifier;

/**
 *  Controller to display program thumbnails and handle selection
 */
@interface BBCScheduleScrollerViewController : UIViewController

/**
 *  Displays section with given key
 *
 *  @param scheduleKey Section key
 */
- (void)refreshWithScheduleKey:(NSString*)scheduleKey;

/**
 *  Block to execute when a program selected
 */
@property (nonatomic, copy) void (^programSelected)(NSDictionary* program);

@end
