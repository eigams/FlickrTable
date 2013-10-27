//
//  LibraryAPI.h
//  FlickrTable
//
//  Created by Stefan Buretea on 10/17/13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LibraryAPI : NSObject

+ (LibraryAPI *)sharedInstance;

- (void)clearCache;

@end
