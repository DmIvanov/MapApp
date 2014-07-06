//
//  DISight.h
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_ENUM(NSUInteger, SightType) {
    SightTypeChosen,        //выбранные
    SightTypeInteresting,   //интересные
    SightTypeDone,          //посещённые
    SightTypeOther,         //прочие
    SightTypeLocal          //локальные
};


@interface DISight : NSObject

@property (nonatomic, strong) NSData *avatarData;

@property (nonatomic, strong) NSNumber *latitudeNumber;
@property (nonatomic, strong) NSNumber *longitudeNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortDescriptionString;
@property (nonatomic, strong) NSNumber *priceNumber;
@property (nonatomic, strong) NSDictionary *workingHours;

@property (nonatomic, strong) NSNumber *wifi;
@property (nonatomic, strong) NSNumber *foto;
@property (nonatomic, strong) NSNumber *audioguide;

@property (nonatomic, strong) NSString *listAbout;
@property (nonatomic, strong) NSString *listContacts;
@property (nonatomic, strong) NSString *listHistory;
@property (nonatomic, strong) NSString *listInteresting;
@property (nonatomic, strong) NSString *listNow;

@property (nonatomic) SightType sightType;

- (instancetype)initWithManagedObject:(NSManagedObject *)object;

@end
