//
//  DISightsManager.m
//  
//
//  Created by Dmitry Ivanov on 15.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightsManager.h"

#import "ListItem.h"
#import "DISight.h"

@implementation DISightsManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;


+ (DISightsManager *)sharedInstance {
    
    static DISightsManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DISightsManager alloc] initSingletone];
    });
    return sharedInstance;
}

- (id)initSingletone {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"MapAppGit" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    //NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"MapAppGit.sqlite"];
    NSURL *storeURL = [[NSBundle mainBundle] URLForResource:@"MapAppGit" withExtension:@"sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSDictionary *options = @{NSReadOnlyPersistentStoreOption: @(YES)};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (ListItem *)createAndSaveItemWithName:(NSString *)name description:(NSString *)description imageData:(NSData *)data {
    
    if (!name.length || !description.length || !data.length) {
        NSLog(@"AppDelegate: Failed to create ListItem - some fields are empty");
        return nil;
    }
    
    ListItem *newItem = [NSEntityDescription insertNewObjectForEntityForName:@"ListItem"
                                                      inManagedObjectContext:self.managedObjectContext];
    if (newItem) {
        newItem.name = name;
        newItem.descriptionString = description;
        newItem.imageData = data;
        
        NSError *error;
        if ([self.managedObjectContext save:&error]) {
            NSLog(@"AppDelegate: ListItem %@ successfully saved", newItem.name);
        }
        else {
            NSLog(@"AppDelegate: Failed to save the context. Error = %@", error);
        }
    }
    else {
        NSLog(@"AppDelegate: Failed to create new ListItem.");
    }
    
    return newItem;
}

- (NSArray *)dataArray {
    
    NSFetchRequest *request = [NSFetchRequest new];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListItem"
                                              inManagedObjectContext:self.managedObjectContext];
    [request setEntity:entity];
    NSError *error;
    NSArray *items = [self.managedObjectContext executeFetchRequest:request
                                                              error:&error];
    if (error) {
        NSLog(@"AppDelegate: Failed to execute NFetchRequest. Error = %@", error);
    }
    
    return items;
}


#pragma mark - Pathes and URLs

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)pathForObjectsFolder {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = paths.firstObject; // Get documents folder
    NSString *tilesFolderPath = [documentsDirectory stringByAppendingPathComponent:@"/Objects"];
    
    return tilesFolderPath;
}


- (NSDictionary *)objectDictAtPath:(NSString *)path {

    NSString *infoPath = [path stringByAppendingPathComponent:@"info.txt"];
    NSString *contentString = [NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:nil];
    if (contentString) {
        NSMutableDictionary *objectDict = [NSMutableDictionary new];
        NSArray *components = [contentString componentsSeparatedByString:@"\n\n\n"];
        for (NSString *compString in components) {
            NSArray *keyValueArray = [compString componentsSeparatedByString:@"\n\n"];
            if (keyValueArray.count > 1)
                [objectDict setValue:keyValueArray[1] forKey:keyValueArray[0]];
        }
        //NSLog(@"%@", objectDict);
        return objectDict;
    }
    else
        return nil;
}

- (DISight *)sightFromDictionary:(NSDictionary *)dict {
    
    DISight *sight = [DISight new];
    sight.name = dict[@"Name"];
    sight.history = dict[@"History"];
    
    return sight;
}

- (NSArray *)recognizedSights {
    
    NSMutableArray *sights = [NSMutableArray arrayWithCapacity:100];
    
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self pathForObjectsFolder] error:nil];
    for (int count = 0; count < [directoryContent count]; count++)
    {
        NSString *fileName = directoryContent[count];
        NSString *objectFolderPath = [[self pathForObjectsFolder] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@", fileName]];
        NSArray *objectFolderContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:objectFolderPath error:nil];
        if (objectFolderContent.count) {
            DISight *sight = [self sightFromDictionary:[self objectDictAtPath:objectFolderPath]];
            if (sight)
                [sights addObject:sight];
        }
    }
    
    return sights;
}



@end
