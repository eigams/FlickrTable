//
//  ImageHTTPClient
//  FlickrTable
//
//  Created by Stefan Buretea on 3/31/14.
//  Copyright (c) 2014 Stefan Buretea AG. All rights reserved.
//

#import "Singleton.h"

@interface ImageHTTPClient : NSObject

SingletonInterface(ImageClient);

- (void)loadRecentImages:(void(^)(NSArray *images, NSError *error))completion;

@end
