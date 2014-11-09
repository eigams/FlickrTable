//
//  ImageDataInfo.h
//  FlickrTable
//
//  Created by Stefan Buretea on 11/30/13.
//  Copyright (c) 2013 NumberFour AG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ImageDataInfo : NSManagedObject

@property (nonatomic, copy) NSString *pid;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, copy) NSString *realname;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *previewURL;
@property (nonatomic, copy) NSString *posted;
@property (nonatomic, copy) NSString *descr;
@property (nonatomic, copy) NSString *taken;

- (NSDictionary *)tr_tableRepresentation;

@end
