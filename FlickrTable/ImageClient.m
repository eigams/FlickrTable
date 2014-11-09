//
//  ImageClient.m
//  FlickrTable
//
//  Created by Stefan Buretea on 3/31/14.
//  Copyright (c) 2014 NumberFour AG. All rights reserved.
//

#import "ImageClient.h"


@interface ImageClient()

@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation ImageClient

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
+ (ImageClient *) sharedInstance
{
    static ImageClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *baseURLString = [NSString stringWithFormat:FLICKR_URL_REQUEST_RECENT, FLICKR_KEY];
        sharedClient = [[self alloc] initWithBaseURL:[NSURL URLWithString:baseURLString]];
    });
    
    return sharedClient;
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
- (void)loadRecentImagesWithCompletion:(void(^)(NSArray *images, NSError *error))completion
{
    ImageClient *client = [[self class] sharedInstance];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:client.request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
                                        NSArray *images = responseObject[@"photos"][@"photo"];
                                        
                                        NSLog(@"image count: %d", [images count]);
                                        
                                        completion(images, nil);
        
                                     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                         completion(nil, error);
                                     }];
    
    [operation start];
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
- (id) initWithBaseURL:(NSURL *)url
{
    self = [super init];
    if(self)
    {
        self.request = [NSURLRequest requestWithURL:url];
    }
    
    return self;
}

@end
