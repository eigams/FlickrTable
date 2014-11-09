//
//  ManagedObjectStore.m
//  RKGeonames
//
//  Created by Stefan Buretea on 1/30/14.
//  Copyright (c) 2014 Stefan Burettea. All rights reserved.
//

#import "ManagedObjectStore.h"

static NSString *const EntityName = @"ImageInfoData";
static NSString *const DataModel = @"FlickerTable";

@interface NSFetchRequest(Helper)

+ (NSFetchRequest *)fetchRequestWithEntityName:(NSString *)entityName context:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate;

@end

@implementation NSFetchRequest(Helper)

+ (NSFetchRequest *)fetchRequestWithEntityName:(NSString *)entityName context:(NSManagedObjectContext *)context predicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:entityName inManagedObjectContext:context];
    [request setEntity:entityDescription];
    
    [request setPredicate:predicate];
    
    return request;
}

@end

typedef void(^PerformBlock_t)(void);

@interface NSManagedObjectContext(Helper)

+ (NSManagedObjectContext *)mainContext;
- (NSManagedObjectContext *)mainContext;
- (NSManagedObjectContext *)privateContext;

- (void)save;

- (void)executeAsyncFetchRequest:(NSFetchRequest *)request completion:(void(^)(NSArray *objects, NSError *error))completion;

- (void)performBlock:(PerformBlock_t)block async:(BOOL)async;

@end

@implementation NSManagedObjectContext(Helper)

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: mainContext                                         |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
+ (NSManagedObjectContext *)mainContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    
    return context;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: mainContext                                         |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSManagedObjectContext *)mainContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [context setParentContext:self];
    
    return context;
}


// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: privateContext                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSManagedObjectContext *)privateContext
{
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    [context setParentContext:self];
    
    return context;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: privateContext                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)save
{
    @try
    {
        [self performBlock:^{
            
            NSError *error;
            if ([self hasChanges] && ![self save:&error])
            {
                NSLog(@"Error saving context: %@", [error localizedDescription]);
            }
            
        } async:YES];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception caught while saving context: %@", exception);
    }
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: mainContext                                         |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)performBlock:(PerformBlock_t)block async:(BOOL)async
{
    if(YES == async)
    {
        [self performBlock:block];
    }
    else
    {
        [self performBlockAndWait:block];
    }
}

- (void)executeAsyncFetchRequest:(NSFetchRequest *)request completion:(void(^)(NSArray *objects, NSError *error))completion
{
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    
    __block NSManagedObjectContext *weakPtr = self;
    
    NSManagedObjectContext *backgroundContext = [self privateContext];
    [backgroundContext performBlock:^{
        [backgroundContext setPersistentStoreCoordinator:coordinator];
        
        NSError *error = nil;
        NSArray *fetchedObjects = [backgroundContext executeFetchRequest:request error:&error];
        
        [weakPtr performBlock:^{
            
            if(nil != fetchedObjects)
            {
                NSMutableArray *mutObjectsIDs = [NSMutableArray arrayWithCapacity:[fetchedObjects count]];
                [fetchedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSManagedObject *mo = (NSManagedObject *)obj;
                    [mutObjectsIDs addObject:mo.objectID];
                }];
                
                NSMutableArray *mutObjects = [NSMutableArray arrayWithCapacity:[mutObjectsIDs count]];
                
                [mutObjectsIDs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    NSManagedObject *mo = [weakPtr objectWithID:obj];
                    [mutObjects addObject:mo];
                }];
                
                if (completion)
                {
                    NSArray *objetcs = [mutObjects copy];
                    completion(objetcs,nil);
                }
            }
            else
            {
                if(completion)
                {
                    completion(nil, error);
                }
            }
            
            
        }];
        
    }];
}

@end

@interface ManagedObjectStore()
{
    NSManagedObjectContext *_mainContext;
    NSManagedObjectContext *_privateContext;
    NSManagedObjectContext *_writeContext;
    
    NSPersistentStoreCoordinator *_persistentStore;
}

@end

@implementation ManagedObjectStore

//@synthesize persistentStore = _persistentStore;
//@synthesize mainContext = _mainContext;

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: itemArchivePath                                     |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSString *) itemArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);\
    
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:@"store.data"];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: managedObject                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSManagedObject *)managedObjectOfType:(NSString *)entity;
{
    @try
    {
        NSManagedObjectContext *managedObjectContext = [NSThread isMainThread] ? _mainContext : _privateContext;
        
        NSEntityDescription *description = [NSEntityDescription entityForName:entity inManagedObjectContext:managedObjectContext];
        
        Class class = NSClassFromString(entity);
        
        return [[class alloc] initWithEntity:description insertIntoManagedObjectContext:managedObjectContext];
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception caught: %@", exception);
    }
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: removeAll                                           |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)removeAllItemsOfType:(NSString *)entity
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:_mainContext]];
    [request setIncludesPropertyValues:NO]; //only fetch the managedObjectID
    
    NSError *error = nil;
    NSArray *allObjects = [_mainContext executeFetchRequest:request error:&error];
    
    if (error)
    {
        NSLog(@"Error occurred while saving: %@", [error localizedDescription]);
    }
    
    for(NSManagedObject *object in allObjects)
    {
        [_mainContext deleteObject:object];
    }
    
    [_mainContext save];
    
    return ;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: sharedInstance                                      |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
SingletonImplemetion(ManagedObjectStore);

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: applicationDocumentsDirectory                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: saveDataInContext                                   |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)saveDataInContext:(void(^)(NSManagedObjectContext *context))saveBlock updateMainContext:(BOOL)update
{
    //    __block CountryStore *weakPtr = self;
    
    // perform a heavy write block on the child context
    [_privateContext performBlockAndWait:^{
        
        saveBlock(_privateContext);
        
        if(YES == update)
        {
            //[weakPtr saveChanges];
            [_mainContext performBlock:^{
                [_mainContext save:nil];
            }];
            
            NSLog(@"Done write test: Saving parent");
        }
    }];
    
    return;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: saveDataInContext                                   |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)saveData:(id)source withBlock:(void(^)(id obj, NSManagedObjectContext *context))saveBlock updateMainContext:(BOOL)update
{
    // perform a heavy write block on the child context
    [_privateContext performBlock:^{
        
        if ([source isKindOfClass:[NSArray class]])
        {
            for (id obj in source)
            {
                saveBlock(obj, _privateContext);
            }
        }
        else
        {
            saveBlock(source, _privateContext);
        }
        
        if(YES == update)
        {
            //[weakPtr saveChanges];
            [_mainContext performBlock:^{
                [_mainContext save];
            }];
            
            NSLog(@"Done write test: Saving parent");
        }
    }];
    
    return;
}

- (void)saveData:(id)source withBlock:(void(^)(id obj, NSManagedObjectContext *context))saveBlock
{
    [self saveData:source withBlock:saveBlock updateMainContext:YES];
}


// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: init                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (id)init
{
    self = [super init];
    
    if(self)
    {
        // Create NSManagedObjectModel and NSPersistentStoreCoordinator
        NSURL *modelURL = [[NSBundle mainBundle] URLForResource:DataModel withExtension:@"momd"];
        NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"FlickerTable.sqlite"];
        
        // remove old store if exists, when remodeling
//        NSFileManager *fileManager = [NSFileManager defaultManager];
//        if ([fileManager fileExistsAtPath:[storeURL path]])
//            [fileManager removeItemAtURL:storeURL error:nil];
        
        NSManagedObjectModel *localmodel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
        
        NSPersistentStoreCoordinator *storeCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:localmodel];
        [storeCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                       configuration:nil
                                                 URL:storeURL
                                             options:nil
                                               error:nil];
        
        //this context will only be used to write data to disk
        _writeContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_writeContext setPersistentStoreCoordinator:storeCoordinator];
        
        //the managed object context can manage undo, but we dont need it for now
        [_writeContext setUndoManager:nil];
        
        
        // create the main ctx with concurrency type NSMainQueueConcurrencyType
        _mainContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_mainContext setParentContext:_writeContext];
        
        _privateContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_privateContext setParentContext:_mainContext];
        [_privateContext setUndoManager:nil];
    }
    
    return self;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: fetchItem                                           |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSManagedObject *)fetchItem:(NSString *)entity predicate:(NSPredicate *)predicate
{
    NSManagedObjectContext *currentContext = [NSThread isMainThread] ? _mainContext : _privateContext;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity
                                                                 context:currentContext
                                                               predicate:predicate];
    
    NSError *error;
    NSArray *results = [currentContext executeFetchRequest:request error:&error];
    if(nil != error)
    {
        NSLog(@"Error occured: %@", error);
        
        return nil;
    }
    
    return ((nil != results) && ([results count] > 0)) ? [results objectAtIndex:0] : nil;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: removeItem                                           |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)removeItem:(NSString *)entity predicate:(NSPredicate *)predicate
{
    NSManagedObject *obj = [self fetchItem:entity predicate:predicate];
    if(nil == obj)
    {
        NSLog(@"No object found to be deleted !!!");
        
        return ;
    }
    
    NSManagedObjectContext *currentContext = [NSThread isMainThread] ? _mainContext : _privateContext;
    
    [currentContext deleteObject:obj];

    [currentContext save:nil];
    
    [self writeToDisk];
}


// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: updateItem                                           |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (BOOL)updateItem:(NSString *)entity predicate:(NSPredicate *)predicate value:(id)newValue key:(NSString *)key
{
    //try to find the object in the store
    NSManagedObject *obj = [self fetchItem:entity predicate:predicate];
    if(nil == obj)
    {
        NSLog(@"Object not found !");
        
        return NO;
    }
    
    //set the new value
    [obj setValue:newValue forKey:key];
    
    //save
    [self writeToDisk];
    
    return YES;
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: updateChildItem                                           |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (BOOL)updateItem:(NSString *)entity
         predicate:(NSPredicate *)predicate
    childPredicate:(NSPredicate *)childPredicate
             value:(id)newValue
               key:(NSString *)key
{
    //try to find the object in the store
    NSManagedObject *obj = [self fetchItem:entity predicate:predicate];
    if(nil == obj)
    {
        NSLog(@"Object not found !");
        
        return NO;
    }
    
    NSSet *set = [obj valueForKey:key];
    NSSet *resultSet = [set filteredSetUsingPredicate:childPredicate];
    id child = [[resultSet allObjects] objectAtIndex:0];
    
    child = newValue;
    
    //save
    [self writeToDisk];
    
    return YES;
}


// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: fetchItem                                           |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)fetchItem:(NSString *)entity
    withPredicate:(NSPredicate *)predicate
       completion:(void(^)(NSArray *results))block
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity
                                                                 context:_privateContext
                                                               predicate:predicate];
    
    //get only the object's ids
    [request setIncludesPropertyValues:NO];
    
    __block NSArray *results;
    [_privateContext performBlock:^{
        
        NSError *error;
        NSArray *managedObjects = [_privateContext executeFetchRequest:request error:&error];
        if(nil != error)
        {
            NSLog(@"Error occured: %@", error);
            
            return ;
        }
        
        if([managedObjects count] == 0)
        {
            NSLog(@"Error no objects fetched !");
            
            return ;
        }
        
        NSMutableArray *mainObjects = [NSMutableArray arrayWithCapacity:[managedObjects count]];
        [managedObjects enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            
            if (![obj isKindOfClass:[NSManagedObject class]]) {
                @throw [NSException exceptionWithName:@"CoreDataException"
                                               reason:@"Error while converting objects, must be a NSManagedObject"
                                             userInfo:[NSDictionary dictionaryWithObject:obj forKey:@"Object"]];
            }
            
            NSManagedObjectID *objID = [obj objectID];
            [mainObjects addObject:[_mainContext objectWithID:objID]];
        }];
        
        results = [NSArray arrayWithArray:mainObjects];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            block(results);
        });
    }];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: writeToDisk                                         |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (void)writeToDisk
{
    NSManagedObjectContext *writeManagedObjectContext = _writeContext;
    NSManagedObjectContext *mainManagedObjectContext = _mainContext;
    
    [mainManagedObjectContext performBlock:^{
        
        NSError *error;
        if ([mainManagedObjectContext hasChanges] && ![mainManagedObjectContext save:&error])
        {
            NSLog(@"Error saving context: %@", [error userInfo]);
        }
        
        [writeManagedObjectContext performBlock:^{
            
            NSError *error;
            if ([writeManagedObjectContext hasChanges] && ![writeManagedObjectContext save:&error])
            {
                NSLog(@"Error saving context: %@", [error userInfo]);
            }
        }];
    }];
}

- (NSArray *)allItemsOfType:(NSString *)entity
{
    return [self allItemsOfType:entity sortedByKey:nil];
}

// |+|=======================================================================|+|
// |+|                                                                       |+|
// |+|    FUNCTION NAME: allItems                                            |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    DESCRIPTION:                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    PARAMETERS:    none                                                |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|    RETURN VALUE:  N/A                                                 |+|
// |+|                                                                       |+|
// |+|                                                                       |+|
// |+|=======================================================================|+|
- (NSArray *)allItemsOfType:(NSString *)entity sortedByKey:(NSString *)key
{
    //1
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:entity];
    
    //2
    //    NSEntityDescription *description = [[model entitiesByName] objectForKey:];
    
    //3
    //    [request setEntity:description];
    
    if(nil != key)
    {
        //4
        NSSortDescriptor *sortd = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
        
        //5
        [request setSortDescriptors:[NSArray arrayWithObject:sortd]];
    }
    
    NSError *error;
    
    //6
    NSArray *results = [_mainContext executeFetchRequest:request error:&error];
    
    if(nil != error)
    {
        NSLog(@"Error loading data from CD: %@", [error localizedDescription]);
    }
    
    return results;
}

@end


