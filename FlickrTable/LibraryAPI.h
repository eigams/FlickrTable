//
//  LibraryAPI.h
//  FlickrTable
//
//  Created by Stefan Buretea on 10/17/13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryAPI : NSObject

+ (instancetype)sharedInstance;

- (void)clearCache;

+ (BOOL)saveImageURL:(NSString *)URL toFile:(NSString *)filename;
+ (BOOL)deleteImageFile:(NSString *)filename;

@end
