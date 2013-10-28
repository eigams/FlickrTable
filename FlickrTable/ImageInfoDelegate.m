//
//  ImageInfoURLConnection.m
//  FlickrTable
//
//  Created by Stefan Buretea on 10/21/13.
//  Inspired by Scott Robertson - https://gist.github.com/spr/
//

#import "ImageInfoDelegate.h"

#import "FlickerImageSource.h"
#import "FlickrConstants.h"

@interface ImageInfoURLConnection : NSURLConnection

@property (nonatomic, readwrite, strong) ImageInfoURLConnectionDelegateSuccess completion;
@property (nonatomic, readwrite, strong) ImageInfoURLConnectionDelegateFailure failure;

@property (nonatomic, readwrite, strong) NSMutableData *data;
@property (nonatomic, readwrite, strong) NSURLResponse *response;

@end

@implementation ImageInfoURLConnection

@end

@implementation ImageInfoDelegate
{
    NSMutableArray *_connections; //holds all connections
    NSOperationQueue *_networkQueue;
    
    NSString *_pid;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   init                                              |+|
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
- (id)init
{
    self = [super init];
    if(self)
    {
        _networkQueue = [[NSOperationQueue alloc] init];
        _networkQueue.maxConcurrentOperationCount = 1;//we have just 1 thread for this, easier to cancel all calls
        
        _connections = [NSMutableArray arrayWithCapacity:MAX_IMAGES];
        
        _timeout = 10;
        _cachePolicy = NSURLRequestUseProtocolCachePolicy;
    }
    
    return self;
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
static NSString *FLICKR_URL_PHOTO_INFO = @"http://api.flickr.com/services/rest/?method=flickr.photos.getInfo&api_key=%@&photo_id=%@&format=json&nojsoncallback=1";
- (void) downloadImageInfo:(NSString *)pid withCompletion:(ImageInfoURLConnectionDelegateSuccess)completion failure:(ImageInfoURLConnectionDelegateFailure)failure
{
    _pid = pid;
    
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:FLICKR_URL_PHOTO_INFO, FLICKR_KEY, pid]] cachePolicy:_cachePolicy timeoutInterval:_timeout];
    ImageInfoURLConnection *theConnection = [[ImageInfoURLConnection alloc] initWithRequest:theRequest delegate:self startImmediately:NO];
    if(nil == theConnection)
    {
        failure([NSError errorWithDomain:@"ImageInfoDelegate" code:-1 userInfo:@{NSLocalizedDescriptionKey: @"Could not initialize NSURLConnection"}]);
        
        return ;
    }
    
    //configure the connection
    [theConnection setDelegateQueue:_networkQueue];
    theConnection.data = [NSMutableData dataWithCapacity:1024];
    theConnection.failure = failure;
    theConnection.completion = completion;

    //we got the connection configured, start it
    [theConnection start];
    
    [_connections addObject:theConnection];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:   cancelAllCalls                                    |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:   cancels any queued callbacks                        |+|
// |+|                   and then adds an operation                          |+|
// |+|                   on the queue to cancel all                          |+|
// |+|                   connections and clean up the array we use.          |+|
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
- (void)cancelAllCalls
{
    [_networkQueue setSuspended:YES];
    [_networkQueue cancelAllOperations];
    [_networkQueue addOperationWithBlock:^{
        for(ImageInfoURLConnection *connection in _connections)
        {
            [connection cancel];
            connection.failure([NSError errorWithDomain:@"ImageInfoDelegate" code:-2 userInfo:@{NSLocalizedDescriptionKey: @"Call canceled by user"}]);
        }
        
        [_connections removeAllObjects];
    }];
    
    [_networkQueue setSuspended:NO];
}

#pragma mark - NSURLConnection delegates

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
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // A response has been received, this is where we initialize the instance var
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    ImageInfoURLConnection *iConnection = (ImageInfoURLConnection *)connection;
    iConnection.response = response;
    
    iConnection.data.length = 0;
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
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to the instance variable you declared
    ImageInfoURLConnection *iConnection = (ImageInfoURLConnection *)connection;
    [iConnection.data appendData:data];
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
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME:    connectionDidFinishLoading                       |+|
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
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    ImageInfoURLConnection *iConnection = (ImageInfoURLConnection *) connection;
    [_connections removeObject:iConnection];
    
    if([iConnection.response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)iConnection.response;
        if(response.statusCode >= 400) //client/server error
        {
            iConnection.failure([NSError errorWithDomain:@"ImageInfoDelegate" code:response.statusCode userInfo:@{NSLocalizedDescriptionKey: [NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]}]);
            
            return ;
        }
    }
    
    // The request is complete and data has been received
    // Can parse the stuff in the instance variable now
    iConnection.completion(iConnection.data);
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
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // The request has failed for some reason!
    // Check the error var
    
    ImageInfoURLConnection *ImageConnection = (ImageInfoURLConnection *)connection;
    ImageConnection.failure(error);
    
    [_connections removeObject:ImageConnection];
}

@end
