//
//  ImageInfoURLConnection.m
//  FlickrTable
//
//  Created by Stefan Buretea on 10/21/13.
//  Inspired by Scott Robertson - https://gist.github.com/spr/
//

#import "ImageInfoHTTPClient.h"

#import "FlickerImageSource.h"
#import "FlickrConstants.h"
#import "FlickrImage.h"

#import "AFHTTPRequestOperation.h"
#import "UIImageView+AFNetworking.h"


@interface ImageInfoURLConnection : NSURLConnection

@property (nonatomic, readwrite, strong) ImageInfoURLConnectionDelegateSuccess completion;
@property (nonatomic, readwrite, strong) ImageInfoURLConnectionDelegateFailure failure;

@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;

@end

@implementation ImageInfoURLConnection

@end

@implementation ImageInfoHTTPClient
{
    NSString *_pid;
}

+ (ImageInfoHTTPClient *)sharedInstance;
{
    static ImageInfoHTTPClient *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (void) updateInfoForImage:(NSString *)pid
                    success:(ImageInfoURLConnectionDelegateSuccess)success
                    failure:(ImageInfoURLConnectionDelegateFailure)failure {

    _pid = pid;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FLICKR_URL_PHOTO_INFO, FLICKR_KEY, pid]];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url];

    [[[NSURLSession sharedSession] dataTaskWithRequest:theRequest
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                        if(nil == error) {
                                            success([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
                                        } else {
                                            failure(error);
                                        }
    }] resume];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   downloadImageInfo                                 |+|
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
//static NSString *FLICKR_URL_PHOTO_INFO = @"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1";
//- (void) updateInfoForImage:(NSString *)pid success:(ImageInfoURLConnectionDelegateSuccess)completion failure:(ImageInfoURLConnectionDelegateFailure)failure
- (void) updateInfoForImage:(NSString *)pid
{
    _pid = pid;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:FLICKR_URL_PHOTO_INFO, FLICKR_KEY, pid]];
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:theRequest];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
    {
        if(NO == [responseObject isKindOfClass:[NSDictionary class]])
        {
            NSLog(@"ERROR: wrong data type received !");
            
            if([self.delegate respondsToSelector:@selector(imageInfoHTTPClient:didFailWithError:)])
            {
                [self.delegate imageInfoHTTPClient:self didFailWithError:nil];
            }

            return ;
        }

        if([self.delegate respondsToSelector:@selector(imageInfoHTTPClient:didUpdateWithInfo:)])
        {
            [self.delegate imageInfoHTTPClient:self didUpdateWithInfo:responseObject];
        }
    }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
    {

         NSLog(@"ERROR: %@", error);
        
        [self.delegate imageInfoHTTPClient:self didFailWithError:nil];
    }];
    
    [operation start];
}

@end
