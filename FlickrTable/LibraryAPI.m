//
//  LibraryAPI.m
//  FlickrTable
//
//  Created by Stefan Buretea on 10/17/13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "LibraryAPI.h"
#import "FlickrConstants.h"
#import "FlickerImageSource.h"

@interface FlickerImageCacheInfo : NSData

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) UIImage *image;

@end

@implementation FlickerImageCacheInfo

@synthesize url;
@synthesize image;

@end

@implementation LibraryAPI
{
    NSMutableArray *_cacheInfo;
    
    NSMutableData *_responseData;
    
    NSString *_pid; //picture id
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
+ (LibraryAPI *)sharedInstance
{
    static LibraryAPI *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[LibraryAPI alloc] init];
    });
    
    return _sharedInstance;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (id) init
{
    self = [super init];
    if(self)
    {
        //register for notifications when a preview image needs to be downloaded
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadImage:) name:DOWNLOAD_IMAGE_NOTIFICATION object:nil];
        
        _cacheInfo = [NSMutableArray new];        
    }
    
    return self;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: clearCache                                          |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)clearCache;
{
    [_cacheInfo removeAllObjects];
}

//1. download the images and the preview images
//2. store all of them into an array
//3. start to asynchronously download the rest of every image info (async NSURLRequest)
//4. use delegation to update the UITableView when the download of image info completes

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   downloadImage                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void) downloadImage:(NSNotification *)notification
{
    UIImageView *imageView = notification.userInfo[@"previewImageView"];
    NSString *previewImageURL = notification.userInfo[@"previewURL"];
    
    FlickerImageCacheInfo *found;
    
    for(FlickerImageCacheInfo *info in _cacheInfo)
    {
        if(YES == [info.url isEqualToString:previewImageURL])
        {
            found = info;
            break;
        }
    }
    
    if(found)
    {
        [imageView setImage:found.image];
    }
    else
    {
        found = [FlickerImageCacheInfo new];
        found.url = previewImageURL;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableURLRequest *URLRequest = [NSMutableURLRequest URLRequestWithString:previewImageURL];
            NSURLResponse *response;
            
            NSError *error = nil;
            NSData *responseData = [NSURLConnection sendSynchronousRequest:URLRequest returningResponse:&response error:&error];
            
            found.image = [UIImage imageWithData:responseData];
            
            [_cacheInfo addObject:found];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                [imageView setImage:found.image];
            });
        });
    }
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:                                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:                                                        |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:                                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
