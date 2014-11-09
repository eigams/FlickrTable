//
//  ImageClient.h
//  FlickrTable
//
//  Created by Stefan Buretea on 3/31/14.
//  Copyright (c) 2014 NumberFour AG. All rights reserved.
//

//#import "AFHTTPClient.h"
#import "Singleton.h"

@interface ImageClient : NSObject

SingletonInterface(ImageClient);

- (void)loadRecentImagesWithCompletion:(void(^)(NSArray *images, NSError *error))completion;

@end
