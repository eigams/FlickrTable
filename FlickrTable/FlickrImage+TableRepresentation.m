//
//  FlickrImage+TableRepresentation.m
//  FlickrTable
//
//  Created by Stefan Burettea on 27/09/2013.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "FlickrImage+TableRepresentation.h"

@implementation FlickrImage (TableRepresentation)

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
    static NSDateFormatter *dateFormatterPosted = nil;
    static NSDateFormatter *dateFormatterTaken = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatterPosted = [[NSDateFormatter alloc] init];
        [dateFormatterPosted setDateFormat:@"dd MMM YYYY, HH:mm:ss"];
        
        dateFormatterTaken = [[NSDateFormatter alloc] init];
        [dateFormatterTaken setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    });
    
    NSString *posted;
    NSString *taken;
    
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeDate error:nil];
    NSUInteger matches = [detector numberOfMatchesInString:self.posted options:0 range:NSMakeRange(0, [self.posted length])];
    if(matches > 0)
    {
        posted = self.posted;
    }
    else
    {
        posted = [dateFormatterPosted stringFromDate:[NSDate dateWithTimeIntervalSince1970:[self.posted doubleValue]]];
    }

    matches = [detector numberOfMatchesInString:self.taken options:0 range:NSMakeRange(0, [self.taken length])];
    if(matches > 0)
    {
        taken = self.taken;
    }
    else
    {
        taken = [dateFormatterPosted stringFromDate:[dateFormatterTaken dateFromString:self.taken]];
    }
    
    return @{@"titles":@[@"Title", @"Username", @"Realname", @"Location", @"Description", @"Posted", @"Taken"],
             @"values":@[self.title ? self.title : @"",
                         self.username ? self.username : @"",
                         self.realname ? self.realname : @"",
                         self.location ? self.location : @"",
                         self.description? self.description : @"",
                         posted ? posted : @"",
                         taken ? taken : @""]};
}

@end
