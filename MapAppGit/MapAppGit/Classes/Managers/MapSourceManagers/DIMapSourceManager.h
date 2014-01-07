//
//  DIMapSourceManager.h
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapView.h"


@interface DIMapSourceManager : NSObject

@property (nonatomic, strong) id<RMTileSource> tileSource;

- (void)setMapSourceForMapView:(RMMapView *)mapView;
- (void)makeDatabase;

@end
