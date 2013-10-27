//
//  AppDelegate.m
//  FlickrTable
//
//  Created by Stefan Buretea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "AppDelegate.h"

#import "FlickrImageListViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FlickrImageListViewController alloc] init]];
    
    self.window.backgroundColor = [UIColor colorWithRed:0.76f green:0.81f blue:0.87f alpha:1];
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end