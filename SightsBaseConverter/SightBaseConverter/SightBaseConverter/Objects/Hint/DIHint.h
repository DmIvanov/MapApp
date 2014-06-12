//
//  DIHint.h
//  SightBaseConverter
//
//  Created by Dmitry Ivanov on 29.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DIHint : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
