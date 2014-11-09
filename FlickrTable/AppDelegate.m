//
//  AppDelegate.m
//  FlickrTable
//
//  Created by Stefan Buretea on 22.08.13.
//  Copyright (c) 2013 Stefan Buretea. All rights reserved.
//

#import "AppDelegate.h"

#import "FlickrImageListViewController.h"

#import "AFNetworkActivityIndicatorManager.h"

@implementation AppDelegate

@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

//// 1
//- (NSManagedObjectContext *) managedObjectContext
//{
//    if (_managedObjectContext != nil)
//    {
//        return _managedObjectContext;
//    }
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil)
//    {
//        _managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [_managedObjectContext setPersistentStoreCoordinator: coordinator];
//    }
//    
//    return _managedObjectContext;
//}
//
////2
//- (NSManagedObjectModel *)managedObjectModel
//{
//    if (_managedObjectModel != nil)
//    {
//        return _managedObjectModel;
//    }
//    
//    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//    
//    return _managedObjectModel;
//}
//
////3
//- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
//{
//    if (_persistentStoreCoordinator != nil)
//    {
//        return _persistentStoreCoordinator;
//    }
//    
//    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory]
//                                               stringByAppendingPathComponent: @"FlickerTable.sqlite"]];
//    NSError *error = nil;
//    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc]
//                                   initWithManagedObjectModel:[self managedObjectModel]];
//    
//    if(![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
//                                                  configuration:nil URL:storeUrl options:nil error:&error])
//    {
//        /*Error for store creation should be handled in here*/
//    }
//    
//    return _persistentStoreCoordinator;
//}
//
//- (NSString *)applicationDocumentsDirectory
//{
//    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
//}
//
//- (NSArray *)getAllArchivedImages
//{
//    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
//    
//    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ImageDataInfo" inManagedObjectContext:self.managedObjectContext];
//    [fetchRequest setEntity:entity];
//    
//    NSError *error;
//    NSArray *fetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
//    if(nil != error)
//    {
//        NSLog(@"Error loading results: %@", [error localizedDescription]);
//    }
//    
//    return fetchResults;
//}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[[FlickrImageListViewController alloc] init]];
    
    self.window.backgroundColor = [UIColor colorWithRed:0.76f green:0.81f blue:0.87f alpha:1];
    [self.window makeKeyAndVisible];
    
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    return YES;
}

@end