//
//  AppDelegate.h
//  FlickrTable
//
//  Created by Stefan Buretea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FlickrImageListViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FlickrImageListViewController *viewController;

@end
