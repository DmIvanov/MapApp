//
//  DISimpleMarker.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 19.07.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "RMMarker.h"

@class DIMapController;
@class DISight;

@interface DISimpleMarker : RMMarker

@property (nonatomic, weak) DIMapController *mapController;
@property (nonatomic, weak) DISight *sight;

@end
