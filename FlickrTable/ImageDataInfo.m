//
//  ImageDataInfo.m
//  FlickrTable
//
//  Created by Stefan Buretea on 11/30/13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import "ImageDataInfo.h"


@implementation ImageDataInfo

@dynamic pid;
@dynamic title;
@dynamic url;
@dynamic location;
@dynamic realname;
@dynamic username;
@dynamic previewURL;
@dynamic posted;
@dynamic descr;
@dynamic taken;

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
- (NSDictionary *)tr_tableRepresentation
{
    return @{@"titles":@[@"Title", @"Username", @"Realname", @"Location", @"Description", @"Posted", @"Taken"],
             @"values":@[self.title ? self.title : @"",
                         self.username ? self.username : @"",
                         self.realname ? self.realname : @"",
                         self.location ? self.location : @"",
                         self.descr ? self.descr : @"",
                         self.posted ? self.posted : @"",
                         self.taken ? self.taken : @""]};
}


@end
