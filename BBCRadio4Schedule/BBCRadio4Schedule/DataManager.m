//
//  DataManager.m
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import "DataManager.h"
#import "AppDelegate.h"

@interface DataManager()

@property (atomic, strong) NSCache *programCache;

@end

@implementation DataManager

static DataManager *q_sharedInstance;

NSString* const bbcTodayProgramsURL     = @"http://www.bbc.co.uk/radio4/programmes/schedules/fm/today.json";
NSString* const bbcTomorrowProgramsURL  = @"http://www.bbc.co.uk/radio4/programmes/schedules/fm/tomorrow.json";
NSString* const bbcYesterdayProgramsURL = @"http://www.bbc.co.uk/radio4/programmes/schedules/fm/yesterday.json";

NSString* const yesterdaysProgramsKeyName    = @"yesterday";
NSString* const todaysProgramsKeyName        = @"today";
NSString* const tomorrowsProgramsKeyName     = @"tomorrow";

NSString* const bbcScheduleDateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";

@synthesize programCache = _programCache;

#pragma mark - Init

- (id)init {
    
    self = [super init];
    if (self) {
    }
    
    return self;
}

+ (instancetype)sharedInstance {
    
    static dispatch_once_t singletonPred;
    dispatch_once(&singletonPred, ^{
        q_sharedInstance = [[DataManager alloc] init];
    });
    
    return q_sharedInstance;
}

#pragma mark  - Caching

- (NSCache*)programCache {
    
    if (!_programCache) {
        _programCache = [NSCache new];
    }
    
    return _programCache;
}

- (void)setProgramCache:(NSCache *)programCache {
    
    _programCache = programCache;
}

#pragma mark - Fetch data

- (void)fetchJSONfromURL:(NSString*)urlString completion:(void(^)(NSDictionary *data, NSError *error))completion {
    
    NSURL *url = [NSURL URLWithString:urlString];

    [(AppDelegate*)[[UIApplication sharedApplication] delegate] increaseNetworkIndicatorCount];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    
    [session resetWithCompletionHandler:^{
    
        NSURLSessionDataTask *task = [session dataTaskWithURL:url
                                                                 completionHandler:^(NSData *data,
                                                                                     NSURLResponse *response,
                                                                                     NSError *error) {
                                                                     
                                                                     [(AppDelegate*)[[UIApplication sharedApplication] delegate] decreaseNetworkIndicatorCount];
                                                                     
                                                                     NSDictionary *dictionary;
                                                                     if (!error) {
                                                                         NSError *JSONError = nil;
                                                                         
                                                                         dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                                                                                     options:0
                                                                                                                                       error:&JSONError];
                                                                         if (JSONError) {
                                                                             NSLog(@"Serialization error: %@", JSONError.localizedDescription);
                                                                         }
                                                                         else {
                                                                             NSLog(@"Response: %@", dictionary);
                                                                         }
                                                                     }
                                                                     else {
                                                                         NSLog(@"Error: %@", error.localizedDescription);
                                                                     }
                                                                     
                                                                     if (completion) {
                                                                         completion(dictionary, error);
                                                                     }
                                      }];
        // Start the task.
        [task resume];
    }];
}

- (void)fetchProgramsWithCompletion:(void(^)(BOOL success, NSError *error))completion {
    
    __block NSDictionary *yesterdayProgram;
    __block NSDictionary *todayProgram;
    __block NSDictionary *tomorrowProgram;
    __block NSError *lastError;
    
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_group_enter(group);
    [self fetchJSONfromURL:bbcYesterdayProgramsURL completion:^(NSDictionary *data, NSError *error) {
        
        if (data) {
            yesterdayProgram = data;
        }
        else if (error) {
            lastError = error;
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self fetchJSONfromURL:bbcTodayProgramsURL completion:^(NSDictionary *data, NSError *error) {
        
        if (data) {
            todayProgram = data;
        }
        else if (error) {
            lastError = error;
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_enter(group);
    [self fetchJSONfromURL:bbcTomorrowProgramsURL completion:^(NSDictionary *data, NSError *error) {
        
        if (data) {
            tomorrowProgram = data;
        }
        else if (error) {
            lastError = error;
        }
        dispatch_group_leave(group);
    }];
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        
        if (yesterdayProgram) {
            [self.programCache setObject:yesterdayProgram forKey:yesterdaysProgramsKeyName];
        }
        
        if (todayProgram) {
            [self.programCache setObject:todayProgram forKey:todaysProgramsKeyName];
        }
        
        if (tomorrowProgram) {
            [self.programCache setObject:tomorrowProgram forKey:tomorrowsProgramsKeyName];
        }
        
        BOOL success = yesterdayProgram && todayProgram && tomorrowProgram;
        if (completion) {
            completion(success, lastError);
        }
    });
}

#pragma mark - Data Source

- (NSDictionary*)scheduleForKey:(NSString *)key {
    
    return [self.programCache objectForKey:key];
}

@end
