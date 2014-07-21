//
//  DISimpleMarker.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 19.07.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISimpleMarker.h"

#import "DIMapController.h"

@implementation DISimpleMarker

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [_mapController markerTapped:self
                     withTouches:touches
                           event:event];
}

@end
