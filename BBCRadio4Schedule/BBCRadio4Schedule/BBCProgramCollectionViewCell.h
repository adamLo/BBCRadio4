//
//  BBCProgramCollectionViewCell.h
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString* const bbcProgramCellIdentifier;

/**
 *  Cell prototype for a scheduled program
 */
@interface BBCProgramCollectionViewCell : UICollectionViewCell

/**
 *  Set up cell with a program
 *
 *  @param broadcast Program data
 */
- (void)setupWithBroadcast:(NSDictionary*)broadcast;

@end
