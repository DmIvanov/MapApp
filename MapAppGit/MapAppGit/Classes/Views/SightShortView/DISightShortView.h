//
//  DISightShortView.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 19.07.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//


@class DISight;
@protocol DISightShortViewDelegate;

@interface DISightShortView : UIView

@property (nonatomic, weak) DISight *sight;
@property (nonatomic, weak) id<DISightShortViewDelegate> delegate;

- (CGPoint)markerPoint;

@end


@protocol DISightShortViewDelegate <NSObject>

@required
- (void)openSightCardFromView:(DISightShortView *)view;
- (void)dismissView:(DISightShortView *)view;

@end
