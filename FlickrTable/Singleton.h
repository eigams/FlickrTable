//
//  Singleton.h
//  RKGeonames
//
//  Created by Stefan Buretea on 1/25/14.
//  Copyright (c) 2014 Stefan Burettea. All rights reserved.
//

#ifndef __Singleton_h__
#define __Singleton_h__

#define SingletonInterface(Class) \
+ (instancetype)sharedInstance;

#define SingletonImplemetion(Class) \
static Class *__## sharedSingleton; \
\
\
+ (Class *)sharedInstance \
{ \
    static dispatch_once_t onceToken; \
    dispatch_once(&onceToken, ^{ \
        __## sharedSingleton = [[self alloc] init]; \
    }); \
\
    return __## sharedSingleton; \
} \

#endif
