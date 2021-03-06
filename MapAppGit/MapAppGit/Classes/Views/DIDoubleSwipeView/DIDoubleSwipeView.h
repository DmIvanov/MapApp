//
//  DIDoubleSwipeView.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 10.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SWITCH_ANIMATION_TIME   0.3
#define SWIPE_ZONE              40.

@class DIDoubleSwipeView;

typedef NS_ENUM(NSInteger, CurrentView) {
    FirstViev,
    SecondView
};


@protocol DIDoubleSwipeViewDelegate <NSObject>

@optional
- (void)switchAnimationFinished:(DIDoubleSwipeView *)doubleSwipeView;

@end


@interface DIDoubleSwipeView : UIView
    <UIGestureRecognizerDelegate>

@property (nonatomic, readonly) BOOL viewIsSwitching;
@property (nonatomic, readonly) CurrentView currentView;
@property (nonatomic, weak) id<DIDoubleSwipeViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame firstView:(UIView *)first secondView:(UIView *)second;

- (void)switchViewsWithComplition:(void (^)(BOOL finished))completion;
- (void)moveSwitchViewUp:(BOOL)up;
- (void)showMapAnimation;

@end
