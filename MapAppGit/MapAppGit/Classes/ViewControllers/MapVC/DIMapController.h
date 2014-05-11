//
//  DIMapController.h
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "RMMapView.h"

@class DIListMapVC;

@interface DIMapController : UIViewController
    <RMMapViewDelegate,
    CLLocationManagerDelegate>

@property (nonatomic, strong) IBOutlet RMMapView *mapView;
@property (nonatomic, strong) DIListMapVC *listMapController;

@end
