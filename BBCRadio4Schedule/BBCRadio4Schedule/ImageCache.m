//
//  ImageCache.m
//  BBCRadio4Schedule
//
//  Created by Adam Lovastyik on 2016. 05. 23..
//  Copyright © 2016. Super Cool Start-up. All rights reserved.
//

#import "ImageCache.h"
#import "AppDelegate.h"

@interface ImageCache()

@property (nonatomic, strong) NSCache *imageCache;

@end

@implementation ImageCache

static ImageCache *q_sharedInstance;

@synthesize imageCache = _imageCache;

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
        q_sharedInstance = [[ImageCache alloc] init];
    });
    
    return q_sharedInstance;
}

#pragma mark  - Cache

- (NSCache*)imageCache {
    
    if (!_imageCache) {
        _imageCache = [NSCache new];
    }
    
    return _imageCache;
}

- (void)setImageCache:(NSCache *)imageCache {
    
    _imageCache = imageCache;
}

- (void)fetchImageWithIdentifier:(NSString*)imageId completion:(void(^)(UIImage *image))completion {
    
    UIImage *cachedImage = [self.imageCache objectForKey:imageId];
    if (cachedImage) {
        if (completion) {
            completion(cachedImage);
        }
    }
    else {
        
        NSURL *url = [NSURL URLWithString: [NSString stringWithFormat:@"http://ichef.bbci.co.uk/images/ic/480x270/%@.jpg", imageId]];
        
        [(AppDelegate*)[[UIApplication sharedApplication] delegate] increaseNetworkIndicatorCount];
        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession]
                                                       downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                                           
                                                           [(AppDelegate*)[[UIApplication sharedApplication] delegate] decreaseNetworkIndicatorCount];

                                                           UIImage *downloadedImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
                                                           
                                                           if (downloadedImage) {
                                                               [self.imageCache setObject:downloadedImage forKey:imageId];
                                                           }
                                                           
                                                           if (completion) {
                                                               completion(downloadedImage);
                                                           }
                                                       }];
        
        [downloadPhotoTask resume];
    }
}

@end
