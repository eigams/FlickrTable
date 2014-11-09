//
//  FlickrImage.h
//  FlickrTable
//
//  Created by Stefan Buretea on 8/22/13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FlickrImage : NSObject

@property (nonatomic, copy, readonly) NSString *pid;
@property (nonatomic, copy, readonly) NSString *title;
@property (nonatomic, copy, readonly) NSString *url;
@property (nonatomic, copy, readonly) NSString *previewURL;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *description;
@property (nonatomic, copy) NSString *posted;
@property (nonatomic, copy) NSString *taken;

+ (instancetype)image;
+ (instancetype)imageWithPID:(NSString *)pid url:(NSString *)url previewURL:(NSString *)previewURL;
+ (instancetype) imageWithImage:(FlickrImage *)source;

@end
