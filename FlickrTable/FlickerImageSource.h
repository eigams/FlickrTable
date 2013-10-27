//
//  FlickerImageSource.h
//  FlickrTable
//
//  Created by Stefan Buretea on 22.04.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlickrImage;

@interface NSMutableURLRequest(ImageURLRequest)

+ (NSMutableURLRequest *) URLRequestWithString:(NSString *)urlString;

@end

@interface FlickerImageSource : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;

- (void)fetchRecentImagesWithCompletion:(void (^)(void))completion;
- (FlickrImage *)imageAtIndex:(NSUInteger)index;

@end
