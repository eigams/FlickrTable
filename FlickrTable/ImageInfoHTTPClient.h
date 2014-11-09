//
//  ImageInfoDelegate.h
//  FlickrTable
//
//  Created by Stefan Buretea on 10/21/13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FlickrImage;

typedef void (^ImageInfoURLConnectionDelegateSuccess) (NSDictionary *image);
typedef void (^ImageInfoURLConnectionDelegateFailure) (NSError *error);

@class ImageInfoHTTPClient;

@protocol ImageInfoHTTPClientDelegate <NSObject>

@optional
- (void)imageInfoHTTPClient:(ImageInfoHTTPClient *)client didUpdateWithInfo:(id)data;
- (void)imageInfoHTTPClient:(ImageInfoHTTPClient *)client didFailWithError:(NSError *)error;

@end

@interface ImageInfoHTTPClient : NSObject

@property (nonatomic, weak) id<ImageInfoHTTPClientDelegate> delegate;

- (void) updateInfoForImage:(NSString *)pid success:(ImageInfoURLConnectionDelegateSuccess) success failure:(ImageInfoURLConnectionDelegateFailure) failure;
- (void) updateInfoForImage:(NSString *)pid;

+ (instancetype) sharedInstance;

@end
