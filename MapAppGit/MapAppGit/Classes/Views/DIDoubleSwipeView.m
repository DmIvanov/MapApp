//
//  DIDoubleSwipeView.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 10.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIDoubleSwipeView.h"

#define FIRST_VIEW_ON_SCREEN        SecondView
#define SWAP_VELOCITY_LIMIT         500
#define SLIDE_LIMIT                 SCREEN_SIZE.width/2


@interface DIDoubleSwipeView ()
{
    CGFloat _initialRightOrigin;
}

@property (nonatomic, strong) UIView *bigView;
@property (nonatomic, strong) UIView *firstView;
@property (nonatomic, strong) UIView *secondView;

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
    
    CGFloat xOrigBigFrame;
    if (FIRST_VIEW_ON_SCREEN == FirstViev)
        xOrigBigFrame = 0.;
    else    //FIRST_VIEW_ON_SCREEN == SecondView
        xOrigBigFrame = -SCREEN_SIZE.width;
    _currentView = FIRST_VIEW_ON_SCREEN;
    CGRect bigRect = CGRectMake(xOrigBigFrame, 0, frame.size.width*2, frame.size.height);
    
    _bigView = [[UIView alloc] initWithFrame:bigRect];
    _firstView = first;
    _firstView.frame = frame;
    _secondView = second;
    _secondView.frame = CGRectMake(frame.size.width, 0, frame.size.width, frame.size.height);
    _panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                             action:@selector(panGestureRecognized:)];
    _panRecognizer.delegate = self;
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self addSubview:_bigView];
    [_bigView addSubview:_firstView];
    [_bigView addSubview:_secondView];
    [_bigView addGestureRecognizer:_panRecognizer];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGFloat xLoc = [touch locationInView:_bigView].x;
    if (xLoc > SCREEN_SIZE.width - SWIPE_ZONE && xLoc < SCREEN_SIZE.width + SWIPE_ZONE)
        return YES;
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

- (void)switchViewsWithComplition:(void (^)(BOOL finished))completion {
    
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
        if (completion)
            completion(finished);
        _viewIsSwitching = NO;
        _currentView = newView;
    };
    
    [UIView animateWithDuration:SWITCH_ANIMATION_TIME
                          delay:0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^ {
                         _bigView.frame = newFrame;
                     }
                     completion:newComplition
     ];
}


@end
