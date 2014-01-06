//
//  DIMapSourceManager.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMapView.h"

@protocol DIMapSourceManager <NSObject>

@required
- (void)setMapSourceForMapView:(RMMapView *)mapView;

@end
