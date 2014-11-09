//
//  FlickerImageSource.m
//  FlickrTable
//
//  Created by Stefan Burettea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "FlickerImageSource.h"
#import "FlickrConstants.h"
#import "FlickrImage.h"

#import "ImageHTTPClient.h"
#import "ImageDataInfo.h"

#import "ManagedObjectStore.h"

@implementation FlickerImageSource
{
    NSMutableArray *_images;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   fetchRecentImagesWithCompletion                   |+|
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
- (void)fetchRecentImages
{
    __block FlickerImageSource *myclass = self;
    
    [[ImageHTTPClient sharedInstance] loadRecentImages:^(NSArray *images, NSError *error) {
        
        myclass->_images = [NSMutableArray arrayWithCapacity: images.count];
        
        __block NSMutableString *imageURL;
        __block NSMutableString *previewURL;
        
        [images enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            NSDictionary *image = obj;
            
            @autoreleasepool {
                NSString *url = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@", image[@"farm"], image[@"server"], image[@"id"], image[@"secret"] ];
                
                //compute the url for the pic
                imageURL = [NSMutableString stringWithString:url];
                [imageURL appendString:@"_b.jpg"];
                
                //compute the url for the previer pic
                previewURL = [NSMutableString stringWithString:url];
                [previewURL appendString:@"_q.jpg"];
                
                //the image info is incomplete
                //the rest of the info about and image will be downloaded when the preview is clicked
                FlickrImage * flickerImage = [FlickrImage imageWithPID:image[@"id"] url:imageURL previewURL:previewURL];
                [myclass->_images addObject:flickerImage];
                
                if(idx >= MAX_IMAGES - 1) {
                    *stop = YES;
                }
            }

        }];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if([myclass->_delegate respondsToSelector:@selector(didCompleteDownloadingImages)])
                [myclass->_delegate didCompleteDownloadingImages];
        });
    }];
    
    return ;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   fetchArchivedImagesWithCompletion                 |+|
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
- (void)fetchArchivedImages
{
    __block FlickerImageSource *myclass = self;
    
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //load images from the disk
        NSArray *images = [[ManagedObjectStore sharedInstance] allItemsOfType:NSStringFromClass([ImageDataInfo class])];
        if (images.count > 0) {
            NSMutableArray *sink = [NSMutableArray arrayWithCapacity:images.count];
            
            for(ImageDataInfo *iiData in images) {
                
                @autoreleasepool {
                    FlickrImage *image = [FlickrImage imageWithPID:iiData.pid url:iiData.url previewURL:iiData.previewURL];
                    image.username = iiData.username;
                    image.realname = iiData.realname;
                    image.location = iiData.location;
                    image.description = iiData.descr;
                    image.posted = iiData.posted;
                    image.taken = iiData.taken;
                    
                    [sink addObject:image];
                }
            }
            
            myclass->_images = [sink copy];
        } else {
            myclass->_images = nil;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if([myclass->_delegate respondsToSelector:@selector(didCompleteDownloadingImages)]){
                [myclass->_delegate didCompleteDownloadingImages];
            }
        });
    });
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
- (NSUInteger)count
{
    return _images.count;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   imageAtIndex                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:  returns the image stored at the given index          |+|
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
- (id)imageAtIndex:(NSUInteger)index
{
    if(index < _images.count)
    {
        return _images[index];
    }
    
    if(_images.count > 0)
    {
        return _images[0];
    }
    
    return nil;
}

@end
