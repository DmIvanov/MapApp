//
//  DISight.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISight.h"

#import "DIHelper.h"
#import "DISightsManager.h"

@implementation DISight

- (instancetype)initWithManagedObject:(NSManagedObject *)object {
    
    self = [super init];
    if (!self)
        return nil;
    
    NSArray *properties = [DIHelper propertiesForСlass:self.class];
    for (NSString *propertyName in properties) {
        id objectValue = [object valueForKey:propertyName];
        if (objectValue) {
            [self setValue:objectValue forKey:propertyName];
        }
    }
    
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    
    DLog(@"Error: setValue:%@ forUndefinedKey:%@", value, key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    
    DLog(@"Error: no such a key:%@ in DISight object", key);
    return nil;
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"workingHours"]) {
        value = (NSDictionary*)[NSKeyedUnarchiver unarchiveObjectWithData:value];
    }
    [super setValue:value forKey:key];
}




- (NSUInteger)indexForTodayInWHTable {
    
    NSDate *today = [NSDate date];
    NSString *todayString = [[DISightsManager sharedInstance] insideDateStringFromDate:today];
    
    return [self indexForDateStringInWHTable:todayString];
}

- (NSUInteger)indexForDateStringInWHTable:(NSString *)todayString {
    
    NSUInteger startYear = 14;
    NSArray *components = [todayString componentsSeparatedByString:@"."];
    if (components.count < 3)
        return NSNotFound;
    
    NSUInteger currentYear = [components[2] integerValue];
    NSUInteger idx = NSNotFound;
    while (idx == NSNotFound && currentYear >= startYear) {
        idx = [self.workingHours indexOfObjectPassingTest:^BOOL(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
            return [(NSString *)obj.allKeys.firstObject isEqualToString:todayString];
        }];
        currentYear--;
        todayString = [NSString stringWithFormat:@"%@.%@.%@", components[0], components[1], @(currentYear)];
    }
    
    return idx;
}

- (NSDictionary *)todayWHDict {
    
    NSDictionary *dict;
    NSDate *today = [NSDate date];
    NSString *todayString = [[DISightsManager sharedInstance] insideDateStringFromDate:today];
    NSUInteger idx = [self indexForDateStringInWHTable:todayString];
    if (idx != NSNotFound) {
        NSDictionary *todayExtDict = _workingHours[idx];
        dict = todayExtDict[todayString];
    }

    return dict;
}

- (NSArray *)sevenDaysWH {
    
    NSArray *arr;
    NSUInteger idx = [self indexForTodayInWHTable];
    if (idx != NSNotFound) {
        NSRange range = NSMakeRange(idx, 7);
        arr = [_workingHours subarrayWithRange:range];
    }
    
    return arr;
}

@end
