//
//  DICloudeMadeManager.h
//  
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DIMapSourceManager.h"

@interface DICloudeMadeManager : NSObject
    <DIMapSourceManager>

#pragma mark - DIMapSourceManager
- (void)setMapSourceForMapView:(RMMapView *)mapView;

@end
