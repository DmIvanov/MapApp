//
//  DIListMapVC.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 10.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIBaseVC.h"
#import "DIDoubleSwipeView.h"


@interface DIListMapVC : DIBaseVC <DIDoubleSwipeViewDelegate>

- (void)navibarPositionManagingWithOffset:(CGFloat)offset;
- (void)setStatusbarNavibarHidden:(BOOL)hidden;
- (void)sightViewIsShowingOnMap:(BOOL)showing;

@end
