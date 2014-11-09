//
//  FlickrImage.m
//  FlickrTable
//
//  Created by Stefan Burettea on 7/29/13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "FlickrImage.h"

@interface FlickrImage()

- (id)init;
- (id)initWithPID:(NSString *)pid url:(NSString *)url previewURL:(NSString *)previewURL;

@end

@implementation FlickrImage

@synthesize pid = _pid;
@synthesize title = _title;
@synthesize url = _url;
@synthesize previewURL = _previewURL;
@synthesize username = _username;
@synthesize realname = _realname;
@synthesize location = _location;
@synthesize description = _description;
@synthesize posted = _posted;
@synthesize taken = _taken;

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
- (id)init
{
    self = [super init];
    if(self)
    {
        _pid = @""; //picture id
        _url = @"";
        _previewURL = @"";
        _title = @"";
        _username = @"";
        _realname = @"";
        _location = @"";
        _description = @"";
        _posted = @"";
        _taken = @"";
    }
    
    return self;
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
+ (FlickrImage *)image
{
    return [[[self class] alloc] init];
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
- (id)initWithPID:(NSString *)pid url:(NSString *)url previewURL:(NSString *)previewURL
{
    self = [super init];
    
    _pid = (nil == pid) ? @"" : pid; //picture id
    _url = (nil == url) ? @"" : url;
    _previewURL = (nil == previewURL) ? @"" : previewURL;
    
    _title = @"";
    _username = @"";
    _realname = @"";
    _location = @"";
    _description = @"";
    _posted = @"";
    _taken = @"";
    
    return self;
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
+ (FlickrImage *)imageWithPID:(NSString *)pid url:(NSString *)url previewURL:(NSString *)previewURL
{
    return [[[self class] alloc] initWithPID:pid url:url previewURL:previewURL];
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
+ (FlickrImage *) imageWithImage:(FlickrImage *)source
{
    return [[[self class] alloc] initWithPID:source.pid url:source.url previewURL:source.url];
}

@end
