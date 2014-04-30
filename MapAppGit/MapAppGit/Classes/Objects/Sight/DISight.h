//
//  DISight.h
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DISight : NSObject

@property (nonatomic) NSNumber *latitudeNumber;
@property (nonatomic) NSNumber *longitudeNumber;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortDescriptionString;
@property (nonatomic, strong) NSString *history;
@property (nonatomic, strong) NSString *scheduleString;
@property (nonatomic, strong) NSArray *scheduleArray;
@property (nonatomic, strong) NSArray *scheduleArrayString;
@property (nonatomic, strong) NSString *priceString;
@property (nonatomic) NSNumber *priceNumber;
@property (nonatomic, strong) NSString *about;
@property (nonatomic, strong) NSString *now;
@property (nonatomic, strong) NSString *contacts;
@property (nonatomic, strong) NSString *direction;
@property (nonatomic, strong) NSString *interesting;
@property (nonatomic, strong) NSString *mustSee;

@property (nonatomic, strong) NSData *avatarData;

@end
