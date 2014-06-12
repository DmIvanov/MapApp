//
//  DISight.h
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightList.h"


typedef NS_ENUM(NSUInteger, SightType) {
    SightTypeOther,         //прочие
    SightTypeChosen,        //выбранные
    SightTypeInteresting,   //интересные
    SightTypeDone,          //посещённые
    SightTypeLocal          //локальные
};


@interface DISight : NSObject

@property (nonatomic) SightType sightType;

@property (nonatomic) NSNumber *latitudeNumber;
@property (nonatomic) NSNumber *longitudeNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortDescriptionString;
@property (nonatomic, strong) NSString *scheduleString;
@property (nonatomic, strong) NSArray *scheduleArray;
@property (nonatomic, strong) NSArray *scheduleArrayString;
@property (nonatomic) NSNumber *priceNumber;
@property (nonatomic, strong) NSString *priceAdditional;
@property (nonatomic, strong) NSString *priceCategories;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *metro;
@property (nonatomic, strong) NSString *phones;

@property (nonatomic, strong) NSDictionary *list;

@property (nonatomic, strong) NSData *avatarData;

@end
