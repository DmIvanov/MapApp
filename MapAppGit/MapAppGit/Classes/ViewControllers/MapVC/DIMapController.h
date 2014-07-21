//
//  DIMapController.h
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "RMMapView.h"

#import "DISightShortView.h"

@class DIListMapVC;
@class DISimpleMarker;

@interface DIMapController : UIViewController
    <RMMapViewDelegate,
    CLLocationManagerDelegate,
    DISightShortViewDelegate>

@property (nonatomic, strong) IBOutlet RMMapView *mapView;
@property (nonatomic, strong) DIListMapVC *listMapController;

- (void)markerTapped:(DISimpleMarker *)marker withTouches:(NSSet *)touches event:(UIEvent *)event;

@end
