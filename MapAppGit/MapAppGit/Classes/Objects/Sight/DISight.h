//
//  DISight.h
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

@class NSManagedObject;

typedef NS_ENUM(NSUInteger, SightType) {
    SightTypeChosen,        //выбранные
    SightTypeInteresting,   //интересные
    SightTypeDone,          //посещённые
    SightTypeLiked,         //понравившиеся
    SightTypeOther,         //прочие
    SightTypeLocal          //локальные
};


@interface DISight : NSObject

@property (nonatomic, strong) NSData *avatarData;
@property (nonatomic, strong) NSData *smallAvatarData;

@property (nonatomic, strong) NSNumber *latitudeNumber;
@property (nonatomic, strong) NSNumber *longitudeNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortDescr;
@property (nonatomic, strong) NSNumber *price;
@property (nonatomic, strong) NSArray *workingHours;

@property (nonatomic, strong) NSNumber *wifi;
@property (nonatomic, strong) NSNumber *foto;
@property (nonatomic, strong) NSNumber *audioguide;

//list
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *contacts;
@property (nonatomic, strong) NSString *history;
@property (nonatomic, strong) NSString *interesting;
@property (nonatomic, strong) NSString *now;
@property (nonatomic, strong) NSString *advices;

@property (nonatomic) SightType sightType;

- (instancetype)initWithManagedObject:(NSManagedObject *)object;

- (BOOL)isClosedNow;
- (NSDictionary *)todayWHDict;
- (NSArray *)sevenDaysWH;

- (BOOL)isFreeToday;

- (UIImage *)imageForBigButtonAdd;
- (UIImage *)imageForMapMarker;
- (UIImage *)imageForListCell;

@end
