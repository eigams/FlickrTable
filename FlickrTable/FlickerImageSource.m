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

@implementation NSMutableURLRequest(ImageURLRequest)

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
+ (NSMutableURLRequest *) URLRequestWithString:(NSString *)urlString
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    request.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData; // this will make sure the request always ignores the cached image
    request.HTTPShouldHandleCookies = NO;
    request.HTTPShouldUsePipelining = YES;
    
    return request;
}

@end

@implementation FlickerImageSource
{
    NSArray *_images;
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
static NSString *FLICKR_URL_PHOTO_INFO = @"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1";
- (NSMutableDictionary *)runRequest:(NSString *)url andParam:(NSString *)param
{
    NSString *urlString = (nil == param) ? [NSString stringWithFormat:url, FLICKR_KEY] : [NSString stringWithFormat:url, FLICKR_KEY, param];
    
    NSMutableURLRequest *request = [NSMutableURLRequest URLRequestWithString:urlString];
    
    NSURLResponse *response;
    
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:nil];
    if(nil == responseData)
    {
        NSLog(@"response data is nil !!!");
        
        return nil;
    }

    return [NSJSONSerialization JSONObjectWithData:responseData options:0 error:nil];
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
static NSString *FLICKR_URL_REQUEST_RECENT = @"http://api.flickr.com/services/rest?method=flickr.photos.getRecent&api_key=%@&format=json&nojsoncallback=1";
- (void)fetchRecentImagesWithCompletion:(void (^)(void))completion
{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    
        NSMutableDictionary *jsonData = [self runRequest:FLICKR_URL_REQUEST_RECENT andParam:nil];

        NSArray *jsonImages = jsonData[@"photos"][@"photo"];

        __block NSMutableArray *images = [NSMutableArray arrayWithCapacity: jsonImages.count];

        NSMutableString *imageURL;
        NSMutableString *previewURL;
        
        for(NSDictionary* image in jsonImages)
        {
            NSString *url = [NSString stringWithFormat:@"http://farm%@.staticflickr.com/%@/%@_%@", image[@"farm"], image[@"server"], image[@"id"], image[@"secret"] ];

            //compute the url for the pic
            imageURL = [[NSMutableString alloc] initWithString:url];
            [imageURL appendString:@"_b.jpg"];
            
            //compute the url for the previer pic
            previewURL = [[NSMutableString alloc] initWithString:url];
            [previewURL appendString:@"_q.jpg"];

            //the image info is incomplete
            //the rest of the info about and image will be downloaded when the preview is clicked
            FlickrImage * flickerImage = [[FlickrImage alloc] initWithPID:image[@"id"] url:imageURL previewURL:previewURL];
            [images addObject:flickerImage];
        }
        
        _images = images;
        
        dispatch_sync(dispatch_get_main_queue(), completion);
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
- (FlickrImage *)imageAtIndex:(NSUInteger)index
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
