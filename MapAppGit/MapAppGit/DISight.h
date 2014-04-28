//
//  DISight.h
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DISight : NSObject

@property (nonatomic) CGFloat coordLatitude;
@property (nonatomic) CGFloat coordLongitude;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *shortDescription;
@property (nonatomic, strong) NSString *history;

@end
