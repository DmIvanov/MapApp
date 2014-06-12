//
//  DISight.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISight.h"

@implementation DISight

+ (NSDictionary *)propertyMapping {
    
    return @{@"AvatarImage" :         @"avatarData",
             @"Coordinates" :         @"latitudeNumber",
             @"Name" :                @"name",
             @"Price" :               @"priceNumber",
             @"ScheduleTable" :       @"scheduleArrayString",
             @"ShortDescription" :    @"shortDescriptionString",
             @"SightType" :           @"sightType",
             
             @"About" :               @"listAbout",
             @"Contacts" :            @"listContacts",
             @"History" :             @"listHistory",
             @"Interesting" :         @"listInteresting",
             @"Now" :                 @"listNow"};
}

- (void)setCoordinatesFromString:(NSString *)string {
    
    NSArray *components = [string componentsSeparatedByString:@" "];
    if (components.count > 1) {
        _latitudeNumber = @([(NSString *)components[0] doubleValue]);
        _longitudeNumber = @([(NSString *)components[1] doubleValue]);
    }
}

- (void)setValue:(id)value forKey:(NSString *)key {
    
    if ([key isEqualToString:@"latitudeNumber"]) {
        [self setCoordinatesFromString:value];
    }
    else
        [super setValue:value forKey:key];
}

@end
