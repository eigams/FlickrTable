//
//  ImageInfoDelegate.h
//  FlickrTable
//
//  Created by Stefan Buretea on 10/21/13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ImageInfoURLConnectionDelegateSuccess) (NSData *data);
typedef void (^ImageInfoURLConnectionDelegateFailure) (NSError *error);

@interface ImageInfoDelegate : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, readwrite) NSTimeInterval timeout;
@property (nonatomic, readwrite) NSURLRequestCachePolicy cachePolicy;

- (void) downloadImageInfo:(NSString *)pid withCompletion:(ImageInfoURLConnectionDelegateSuccess) success failure:(ImageInfoURLConnectionDelegateFailure) failure;
- (void) cancelAllCalls;

+ (instancetype) sharedInstance;

@end
