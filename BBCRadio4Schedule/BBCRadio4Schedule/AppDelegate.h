//
//  AppDelegate.h
//  BBCRadio4Schedule
//
//  Created by IG on 08/09/2015.
//  Copyright (c) 2015 Super Cool Start-up. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/**
 *  Displays network indicator
 */
- (void)increaseNetworkIndicatorCount;

/**
 *  Hides network indicator when not needed anymore
 */
- (void)decreaseNetworkIndicatorCount;

@end

