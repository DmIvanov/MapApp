//
//  DISight.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISight.h"

#import <CoreData/CoreData.h>

#import "DIHelper.h"
#import "DISightsManager.h"

@implementation DISight

- (instancetype)initWithManagedObject:(NSManagedObject *)object {
    
    self = [super init];
    if (!self)
        return nil;
    
    //_dbId = object.objectID;
    NSArray *properties = [DIHelper propertiesForСlass:self.class];
    for (NSString *propertyName in properties) {
        //if ([propertyName isEqualToString:@"dbId"])
        //    continue;
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


#pragma mark

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

- (BOOL)isClosedNow {
    
    NSMutableDictionary *todayDict = [NSMutableDictionary dictionaryWithDictionary:[self todayWHDict]];
    [self reorgonizedDictForDayNightSight:todayDict];
    if ([self isDateDict:todayDict compriseDate:[NSDate date]])
        return NO;
    else
        return YES;
}

- (void)reorgonizedDictForDayNightSight:(NSMutableDictionary *)dictionary {
    
    NSDate *timeOpen    = dictionary[@"timeOpen"];
    NSDate *timeClose   = dictionary[@"timeClose"];
    
    if (timeClose < timeOpen) { //night workhours
        timeClose = [timeClose dateByAddingTimeInterval:60*60*24];
        dictionary[@"timeClose"] = timeClose;
    }
}

- (BOOL)isDateDict:(NSDictionary *)dictionary compriseDate:(NSDate *)date {
    
    NSDate *timeOpen    = dictionary[@"timeOpen"];
    NSDate *timeClose   = dictionary[@"timeClose"];
    timeClose = [timeClose dateByAddingTimeInterval:59];
    
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSHourCalendarUnit | NSMinuteCalendarUnit
                                                                   fromDate:date];
    NSString *timeString = [NSString stringWithFormat:@"%d:%d", components.hour, components.minute];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"HH:mm"];
    NSDate *timeNow = [dateFormat dateFromString:timeString];
    
    NSTimeInterval absoluteOpen     = [timeOpen timeIntervalSince1970];
    NSTimeInterval absoluteClose    = [timeClose timeIntervalSince1970];
    NSTimeInterval absoluteNow      = [timeNow timeIntervalSince1970];
    
    if (absoluteNow <= absoluteClose && absoluteNow >= absoluteOpen)
        return YES;
    else
        return NO;
}

- (BOOL)isFreeToday {
    
    NSDictionary *todayDict = [self todayWHDict];
    BOOL totalyFreeToday = [todayDict[@"free"] boolValue];
    CGFloat priceFloat = [_price floatValue];
    if (!priceFloat || totalyFreeToday)
        return YES;
    else
        return NO;
}


#pragma mark

- (UIImage *)imageForBigButtonAdd {
    
    NSString *imageName;
    switch (_sightType) {
        case SightTypeChosen:
            imageName = @"list_button_add_released";
            break;
        case SightTypeInteresting:
            imageName = @"list_button_add_pressed";
            break;
        case SightTypeDone:
            imageName = @"";
            break;
        case SightTypeOther:
            imageName = @"";
            break;
        case SightTypeLocal:
            imageName = @"";
            break;
            
        default:
            break;
    }
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

- (UIImage *)imageForMapMarker {
    
    NSString *imageName;
    if ([self isClosedNow]) {
        imageName = @"map-poi-temp_unavi";
    }
    else {
        switch (_sightType) {
            case SightTypeChosen:
                imageName = @"map-poi-secondary";
                break;
            case SightTypeInteresting:
                imageName = @"map-poi-primary";
                break;
            case SightTypeDone:
                imageName = @"";
                break;
            case SightTypeLiked:
                imageName = @"map-poi-visited-like";
                break;
            case SightTypeOther:
                imageName = @"list_button_add_released";
                break;
            case SightTypeLocal:
                imageName = @"";
                break;
                
            default:
                break;
        }
    }
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

- (UIImage *)imageForListCell {
    
    NSString *imageName;
    if ([self isClosedNow]) {
        imageName = @"list_tittle_status_closed";
    }
    else {
        switch (_sightType) {
            case SightTypeChosen:
                imageName = @"";
                break;
            case SightTypeInteresting:
                imageName = @"list_tittle_status_selected";
                break;
            case SightTypeDone:
                imageName = @"";
                break;
            case SightTypeLiked:
                imageName = @"";
                break;
            case SightTypeOther:
                imageName = @"";
                break;
            case SightTypeLocal:
                imageName = @"";
                break;
                
            default:
                break;
        }
    }
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}

- (UIImage *)imageForNavibarButton {
    
    NSString *imageName;
        switch (_sightType) {
            case SightTypeChosen:
                imageName = @"info_tittlebar_button_add_unpressed";
                break;
            case SightTypeInteresting:
                imageName = @"info_tittlebar_button_add_pressed";
                break;
            case SightTypeDone:
                imageName = @"";
                break;
            case SightTypeLiked:
                imageName = @"";
                break;
            case SightTypeOther:
                imageName = @"";
                break;
            case SightTypeLocal:
                imageName = @"";
                break;
                
            default:
                break;
        }
    UIImage *image = [UIImage imageNamed:imageName];
    
    return image;
}


#pragma mark - Setters & getters

- (void)setSightType:(SightType)sightType {
    
    if (_sightType != sightType) {
        _sightType = sightType;
        NSDictionary *info = @{@"sight" : self};
        [[NSNotificationCenter defaultCenter] postNotificationName:DINOTIFICATION_SIGHT_STATE_CHANGED
                                                            object:nil
                                                          userInfo:info];
//        [[DISightsManager sharedInstance] setValue:@(_sightType)
//                                            forKey:@"sightType"
//                                   forObjectWithId:_dbId];
        [[DISightsManager sharedInstance] setSightType:@(_sightType)
                                              forSight:self];
    }
}

@end
