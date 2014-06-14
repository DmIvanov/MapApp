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
    
    return @{@"avatarData" :          @"avatarData",
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



@end
