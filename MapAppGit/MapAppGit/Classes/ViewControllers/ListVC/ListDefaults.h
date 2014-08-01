//
//  ListDefaults.h
//  
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CELL_ID                     @"cellId"
#define CELL_ID_2                   @"cellId2"

#define DEFAULT_GROWING_INDEX       1
#define CELL_HEIGHT                 43.
#define CELL_HEIGHT_BIG             290.
#define CELL_HEIGHT_SECOND          64.
#define CELL_HEIGHT_HELP            320.

#define ratio(height)               ((height - CELL_HEIGHT)/(CELL_HEIGHT_BIG - CELL_HEIGHT))
#define START_RATIO                 ratio(CELL_HEIGHT_SECOND)

#define BOTTOM_START                ((CELL_HEIGHT_BIG + CELL_HEIGHT_SECOND) + START_RATIO*CELL_HEIGHT)
#define BOTTOM_STOP                 ((CELL_HEIGHT_BIG + CELL_HEIGHT_SECOND) - (1 - START_RATIO)*CELL_HEIGHT)
