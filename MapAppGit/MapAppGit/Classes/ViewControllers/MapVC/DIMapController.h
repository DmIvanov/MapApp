//
//  DIMapController.h
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "RMMapView.h"

@interface DIMapController : UIViewController
    <RMMapViewDelegate,
    RMTilesUpdateDelegate>

@property (nonatomic, strong) IBOutlet RMMapView *mapView;

#pragma mark - RMMapViewDelegate methods
- (void)beforeMapMove:(RMMapView*)map;
- (void)afterMapMove:(RMMapView*)map;
- (void)afterMapTouch:(RMMapView*)map;

#pragma mark - RMTilesUpdateDelegate methods
- (void)regionUpdate:(RMSphericalTrapezium)region;

@end
