//
//  DataManager.h
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import <Foundation/Foundation.h>

//Section key names
extern NSString* const yesterdaysProgramsKeyName;
extern NSString* const todaysProgramsKeyName;
extern NSString* const tomorrowsProgramsKeyName;

//Schedule date format
extern NSString* const bbcScheduleDateFormat;

/**
 *  Manager singleton to handle data retrieval and cache
 */
@interface DataManager : NSObject

+ (instancetype)sharedInstance;

/**
 *  Fetch programs
 *
 *  @param completion Block to execute on completion
 */
- (void)fetchProgramsWithCompletion:(void(^)(BOOL success, NSError *error))completion;

/**
 *  Provide data for tableview datasource
 *
 *  @param key Section key name
 *
 *  @return Fetched data for section
 */
- (NSDictionary*)scheduleForKey:(NSString*)key;

@end
