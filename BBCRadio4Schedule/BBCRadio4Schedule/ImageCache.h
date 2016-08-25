//
//  ImageCache.h
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 *  Singleton for image retrieval and cache
 */
@interface ImageCache : NSObject

+ (instancetype)sharedInstance;

/**
 *  Asynchronously returns image for gived id
 *
 *  @param imageId    Image id
 *  @param completion Block to execute when image fetched
 */
- (void)fetchImageWithIdentifier:(NSString*)imageId completion:(void(^)(UIImage *image))completion;

@end
