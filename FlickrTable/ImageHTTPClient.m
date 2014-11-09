//
//  ImageClient.m
//  FlickrTable
//
//  Created by Stefan Buretea on 3/31/14.
//  Copyright (c) 2014 Stefan Buretea AG. All rights reserved.
//

#import "ImageHTTPClient.h"


@interface ImageHTTPClient()

@property (nonatomic, strong) NSURLRequest *request;

@end

@implementation ImageHTTPClient

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
+ (ImageHTTPClient *) sharedInstance
{
    static ImageHTTPClient *sharedClient = nil;
    
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
- (void)loadRecentImages:(void(^)(NSArray *images, NSError *error))completion
{
    ImageHTTPClient *client = [[self class] sharedInstance];
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:client.request
                                     completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                         
                                         if(nil == error) {
                                             NSDictionary *sink = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                                             NSArray *images = sink[@"photos"][@"photo"];
                                             
                                             NSLog(@"image count: %d", [images count]);
                                             
                                             completion(images, nil);
                                         } else {
                                             completion(nil, error);
                                         }
    }] resume];
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
    if(self) {
        self.request = [NSURLRequest requestWithURL:url];
    }
    
    return self;
}

@end
