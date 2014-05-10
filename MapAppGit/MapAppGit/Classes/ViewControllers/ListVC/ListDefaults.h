//
//  ListDefaults.h
//  
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define COLOR1              [UIColor colorWithRed:218./255. green:165./255. blue:32./255. alpha:1.]
#define COLOR2              [UIColor colorWithRed:184./255. green:134./255. blue:11./255. alpha:1.]
#define COLOR3              [UIColor colorWithRed:139./255. green:69./255. blue:19./255. alpha:1.]
#define COLOR4              [UIColor colorWithRed:205./255. green:133./255. blue:63./255. alpha:1.]
#define COLOR5              [UIColor colorWithRed:244./255. green:164./255. blue:96./255. alpha:1.]
#define COLOR6              [UIColor colorWithRed:255./255. green:165./255. blue:0. alpha:1.]
#define COLOR0              [UIColor colorWithRed:255./255. green:215./255. blue:0. alpha:1.]

#define CELL_ID                     @"cellId"

#define DEFAULT_GROWING_INDEX       1
#define CELL_HEIGHT                 40.
#define CELL_HEIGHT_BIG             300.
#define CELL_HEIGHT_SECOND          70.

#define START_RATIO                 ((CELL_HEIGHT_SECOND - CELL_HEIGHT)/(CELL_HEIGHT_BIG - CELL_HEIGHT))
#define BOTTOM_START                ((CELL_HEIGHT_BIG + CELL_HEIGHT_SECOND) + START_RATIO*CELL_HEIGHT)
#define BOTTOM_STOP                 ((CELL_HEIGHT_BIG + CELL_HEIGHT_SECOND) - (1 - START_RATIO)*CELL_HEIGHT)
