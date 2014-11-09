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

@class FlickerImageSource;

@protocol FlickerImageSourceDelegate <NSObject>

@optional

- (void) didCompleteDownloadingImages;

@end

@interface FlickerImageSource : NSObject

@property (nonatomic, assign, readonly) NSUInteger count;
@property (nonatomic, weak) id<FlickerImageSourceDelegate> delegate;

- (void)fetchRecentImages;
- (void)fetchArchivedImages;

- (id)imageAtIndex:(NSUInteger)index;

@end
