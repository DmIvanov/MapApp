//
//  DISightsManager.m
//  
//
//  Created by Dmitry Ivanov on 15.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightsManager.h"

#import <CoreData/CoreData.h>

#import "DISight.h"

@interface DISightsManager ()
{
    NSMutableArray *_sights;
    NSMutableDictionary *_types;
}
@property (nonatomic, strong) NSDateFormatter *insideDateFormatter;
@property (nonatomic, strong) NSDateFormatter *outsideDateFormatter;
@property (nonatomic, strong) NSDateFormatter *timeFormatter;

@end

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
//        [[NSNotificationCenter defaultCenter] addObserver:self
//                                                 selector:@selector(applicationDidEnterBackground:)
//                                                     name:UIApplicationDidEnterBackgroundNotification
//                                                   object:nil];
    }
    return self;
}

//- (void)applicationDidEnterBackground:(NSNotification *)notification {
//    
//    [self saveContext];
//}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if (/*[managedObjectContext hasChanges] &&*/ ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

- (void)setValue:(id)value forKey:(NSString *)key forObjectWithId:(NSManagedObjectID *)objId {
    
//    NSManagedObject *object = [self.managedObjectContext objectWithID:objId];
//    [object setValue:value forKey:key];
//    DLog(@"%@", [object valueForKey:key]);
//    DLog(@"%@", [object valueForKey:@"name"]);
//    [self saveContext];
    
//    NSFetchRequest *request = [[NSFetchRequest alloc] init];
//    [request setEntity:[NSEntityDescription entityForName:@"DISight" inManagedObjectContext:self.managedObjectContext]];
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@", @"Дворцовая площадь"];
//    [request setPredicate:predicate];
//    
//    NSError *error = nil;
//    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
//    NSManagedObject *object = results.firstObject;
//    [object setValue:value forKey:key];
//    [self saveContext];
}

- (void)setSightType:(NSNumber *)typeValue forSight:(DISight *)sight {
    
    [_types setValue:typeValue forKey:sight.name];
    [[NSUserDefaults standardUserDefaults] setObject:_types forKey:@"typesDictionary"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"SightBaseConverter" withExtension:@"momd"];
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
    
    //NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"SightsBase.sqlite"];
    NSURL *storeURL = [[NSBundle mainBundle] URLForResource:@"SightsBase" withExtension:@"sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    //NSDictionary *options = @{NSReadOnlyPersistentStoreOption: @(NO)};
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
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

- (NSArray *)dataArray {
    
    if (!_sights) {
        _sights = [NSMutableArray arrayWithCapacity:100];
        
        NSFetchRequest *request = [NSFetchRequest new];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"DISight"
                                                  inManagedObjectContext:self.managedObjectContext];
        [request setEntity:entity];
        NSError *error;
        NSArray *items = [self.managedObjectContext executeFetchRequest:request
                                                                  error:&error];
        if (error) {
            NSLog(@"AppDelegate: Failed to execute NFetchRequest. Error = %@", error);
        }
        
        NSDictionary *typesFromDef = [[NSUserDefaults standardUserDefaults] objectForKey:@"typesDictionary"];
        _types = [[NSMutableDictionary alloc] initWithCapacity:100];
        
        //for (NSUInteger i=0; i<13; i++) {
            for (NSManagedObject *sightObject in items) {
                DISight *newSight = [[DISight alloc] initWithManagedObject:sightObject];
                [_sights addObject:newSight];
                if (typesFromDef && typesFromDef[newSight.name])
                    newSight.sightType = [typesFromDef[newSight.name] integerValue];
                else
                    [_types setValue:@(newSight.sightType) forKey:newSight.name];
            }
        //}
        if (typesFromDef) {
            _types = [NSMutableDictionary dictionaryWithDictionary:typesFromDef];
        }
        
        //caching all the images for fast list animation (till we have less than 100 objects)
        //[self bgPhotoPprocessing];
    }
    
    return _sights;
}

//- (void)bgPhotoPprocessing {
//    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (DISightExtended *sight in _sights) {
//            [sight avatarImage];
//            //DLog(@"size - %.3f", (CGFloat)sight.originalSight.avatarData.length/1000);
//        }
//    });
//}


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


#pragma mark - Setters & getters

- (NSDateFormatter *)insideDateFormatter {
    
    if (!_insideDateFormatter) {
        _insideDateFormatter = [[NSDateFormatter alloc] init];
        [_insideDateFormatter setDateFormat:@"dd.MM.yy"];
    }
    
    return _insideDateFormatter;
}

- (NSDateFormatter *)outsideDateFormatter {
    
    if (!_outsideDateFormatter) {
        NSLocale *locale = [NSLocale currentLocale];
        _outsideDateFormatter = [[NSDateFormatter alloc] init];
        [_outsideDateFormatter setLocale:locale];
        [_outsideDateFormatter setDateStyle:NSDateFormatterShortStyle];
    }
    
    return _outsideDateFormatter;
}

- (NSDateFormatter *)timeFormatter {
    
    if (!_timeFormatter) {
        NSLocale *locale = [NSLocale currentLocale];
        _timeFormatter = [[NSDateFormatter alloc] init];
        [_timeFormatter setLocale:locale];
        [_timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    }
    
    return _timeFormatter;
}


#pragma mark - Other functions

- (NSString *)timeStringFromDate:(NSDate *)date {
    
    return [self.timeFormatter stringFromDate:date];
}

- (NSString *)insideDateStringFromDate:(NSDate *)date {
    
    return [self.insideDateFormatter stringFromDate:date];
}

- (NSString *)outsideDateStringFromDate:(NSDate *)date {
 
    return [self.outsideDateFormatter stringFromDate:date];
}

- (NSString *)openCloseStringFromDateOpen:(NSDate *)open dateClose:(NSDate *)close {

    NSString *openString = [self timeStringFromDate:open];
    NSString *closeString = [self timeStringFromDate:close];
    if ([openString isEqualToString:closeString])
        return DILocalizedString(@"sightCardClosedToday");
        
    close = [close dateByAddingTimeInterval:60];
    closeString = [self timeStringFromDate:close];
    
    if ([openString isEqualToString:closeString]) {
        return DILocalizedString(@"sightCardAllDayLong");
    }
    else
        return [NSString stringWithFormat:@"%@ - %@", openString, closeString];
}

- (NSString *)weekDayFromDateString:(NSString *)dateString {
    
    NSDate *date = [self.insideDateFormatter dateFromString:dateString];
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSWeekdayCalendarUnit fromDate:date];
    NSUInteger dayNumber = [comp weekday];
    NSString *weekdayStr;
    switch (dayNumber) {
        case 1:
            weekdayStr = DILocalizedString(@"weekdaySun");
            break;
        case 2:
            weekdayStr = DILocalizedString(@"weekdayMon");
            break;
        case 3:
            weekdayStr = DILocalizedString(@"weekdayTue");
            break;
        case 4:
            weekdayStr = DILocalizedString(@"weekdayWed");
            break;
        case 5:
            weekdayStr = DILocalizedString(@"weekdayThu");
            break;
        case 6:
            weekdayStr = DILocalizedString(@"weekdayFri");
            break;
        case 7:
            weekdayStr = DILocalizedString(@"weekdaySat");
            break;
        default:
            weekdayStr = @"";
            break;
    }
    
    return weekdayStr;
}

@end
