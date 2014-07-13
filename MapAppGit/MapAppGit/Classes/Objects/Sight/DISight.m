//
//  DISight.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISight.h"

#import "DIHelper.h"

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

@end
