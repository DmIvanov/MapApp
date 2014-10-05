//
//  DIDoubleSwipeView.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 10.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIDoubleSwipeView.h"

#define SWAP_VELOCITY_LIMIT         500
#define SLIDE_LIMIT                 SCREEN_SIZE.width/2

#define SWITCHVIEW_CENTER           CGPointMake(SCREEN_SIZE.width-7, SCREEN_SIZE.height/4)


@interface DIDoubleSwipeView ()
{
    CGFloat _initialRightOrigin;
}

@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *secondView;
@property (nonatomic, strong) UIImageView *switchView;

@property (nonatomic) BOOL viewIsSwitching;
@property (nonatomic) CurrentView currentView;

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;

@end


@implementation DIDoubleSwipeView

- (id)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame firstView:nil secondView:nil];;
}

- (id)initWithFrame:(CGRect)frame firstView:(UIView *)first secondView:(UIView *)second {
    
    self = [super initWithFrame:frame];
    if (!self)
        return nil;
    
    _currentView = SecondView;
    
    CGFloat xOrigBigFrame;
    if (_currentView == FirstViev)
        xOrigBigFrame = 0.;
    else    //FIRST_VIEW_ON_SCREEN == SecondView
        xOrigBigFrame = -SCREEN_SIZE.width;
    
    CGRect bigRect = CGRectMake(xOrigBigFrame, 0, frame.size.width*2, frame.size.height);
    
    _bigView = [[UIView alloc] initWithFrame:bigRect];
    //_bigView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _firstView = first;
    _firstView.frame = frame;
    //_firstView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _secondView = second;
    _secondView.frame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
    //_secondView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(panGestureRecognized:)];
    _panRecognizer.delegate = self;
    
    _switchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"map-button-list"]];
    _switchView.center = SWITCHVIEW_CENTER;
    
    [self addSubview:_bigView];
    [_bigView addSubview:_firstView];
    [_bigView addSubview:_secondView];
    [_bigView addSubview:_switchView];
    
    [_bigView addGestureRecognizer:_panRecognizer];
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
//    DLog(@"%@", self);
//    DLog(@"%@", _bigView);
//    DLog(@"%@", _secondView);
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGFloat xLoc = [touch locationInView:_bigView].x;
    CGPoint touchLocation = [touch locationInView:_switchView];
    BOOL shouldReceiveFromLeftView = [_switchView pointInside:touchLocation withEvent:nil];
    BOOL shouldReceiveFromRightView = xLoc < SCREEN_SIZE.width + SWIPE_ZONE && xLoc > SCREEN_SIZE.width;
    if (shouldReceiveFromLeftView || shouldReceiveFromRightView) {
        return YES;
    }
    else
        return NO;
}

- (void)panGestureRecognized:(UIPanGestureRecognizer *)recognizer {
    
    CGRect bigFrame = _bigView.frame;
    CGFloat xCoord = [recognizer translationInView:self].x;
    CGFloat width = SCREEN_SIZE.width;
    CGFloat rightViewX = bigFrame.origin.x + width;
    //NSLog(@"%f",xCoord);
    
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            _initialRightOrigin = rightViewX;
            _viewIsSwitching = YES;
            break;
            
        case UIGestureRecognizerStateChanged:
        {
            rightViewX = _initialRightOrigin + xCoord;
            if (rightViewX < 0.)
                rightViewX = 0.;
            else if (rightViewX > width)
                rightViewX = width;
            bigFrame.origin.x = rightViewX - SCREEN_SIZE.width;
            _bigView.frame = bigFrame;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        {
            BOOL rightView;
            CGFloat slideTime;
            if (fabs([recognizer velocityInView:self].x) > SWAP_VELOCITY_LIMIT) {
                if ([recognizer velocityInView:self].x > 0)
                    rightView = NO;
                else
                    rightView = YES;
                slideTime = 0.1;
            }
            else {
                DLog(@"%f", SLIDE_LIMIT);
                if (rightViewX <= SLIDE_LIMIT) {
                    rightView = YES;
                }
                else {
                    rightView = NO;
                }
                slideTime = 0.3;
            }
            
            if (rightView) {
                bigFrame.origin.x = -SCREEN_SIZE.width;
            }
            else {
                bigFrame.origin.x = 0.;
            }
            
            [UIView animateWithDuration:slideTime
                                  delay:0
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^ {
                                 _bigView.frame = bigFrame;
                             }
                             completion:^(BOOL finished) {
                                 _viewIsSwitching = NO;
                                 _currentView = rightView ? SecondView : FirstViev;
                                 if ([_delegate respondsToSelector:@selector(switchAnimationFinished:)])
                                     [_delegate switchAnimationFinished:self];
                             }
             ];
        }
            break;
            
        default:
            break;
    }
}

- (void)switchToFirstViewAnimated:(BOOL)animated {
    
    if (_currentView == FirstViev)
        return;
    
    [self switchViewsWithComplition:nil
                           animated:animated];
}

- (void)switchViewsWithComplition:(void (^)(BOOL finished))completion animated:(BOOL)animated {
    
    _viewIsSwitching = YES;
    
    CGRect newFrame = _bigView.frame;
    CurrentView newView;
    if (_currentView == FirstViev) {
        newFrame.origin.x = -SCREEN_SIZE.width;
        newView = SecondView;
    }
    else {
        newFrame.origin.x = 0.;
        newView = FirstViev;
    }
    
    void (^newComplition)(BOOL finished) = ^(BOOL finished){
        _viewIsSwitching = NO;
        _currentView = newView;
        if ([_delegate respondsToSelector:@selector(switchAnimationFinished:)])
            [_delegate switchAnimationFinished:self];
        if (completion)
            completion(finished);
    };
    
    if (animated)
        [UIView animateWithDuration:SWITCH_ANIMATION_TIME
                              delay:0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^ {
                             _bigView.frame = newFrame;
                         }
                         completion:newComplition
         ];
    else {
        _bigView.frame = newFrame;
        newComplition(YES);
    }
}

- (void)showMapAnimation {
    
    CGRect newFrame1 = _bigView.frame;
    CGRect newFrame2 = _bigView.frame;
    newFrame1.origin.x += 50;
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _bigView.frame = newFrame1;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.3
                                               delay:0.4
                                             options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              _bigView.frame = newFrame2;
                                          }
                                          completion:nil];
                     }];
}

- (void)moveSwitchViewUp:(BOOL)up {
    
    CGPoint downPositionCenter = CGPointMake(SWITCHVIEW_CENTER.x, (SCREEN_SIZE.height-330.)/2+330.);
    CGPoint newCenter = up ? SWITCHVIEW_CENTER : downPositionCenter;
    [UIView animateWithDuration:0.6
                          delay:0
         usingSpringWithDamping:0.6
          initialSpringVelocity:1.
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         _switchView.center = newCenter;
                     } completion:nil];
}


@end
