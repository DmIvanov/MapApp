//
//  DIListMapVC.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 10.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIListMapVC.h"

#import "ListVC.h"
#import "DIMapController.h"
#import "DIBarButton.h"

#define VIEW_FRAME                  self.view.frame
#define NAVIBAR_DELTA               44.
#define NAVIBAR_MOVE_INTERACTIVE    NO
#define MAX_START_ANIMATION_COUNT   10

#define TITLE_VIEW_FRAME            CGRectMake(0, 20, 280, 44)
#define TITLE_LABEL_FRAME           CGRectMake(8, 10, 260, 20)
#define TITLE_FONT                  [UIFont boldSystemFontOfSize:18.]


@interface DIListMapVC ()
{
    UINavigationBar *_naviBar;
    BOOL _startAnimationHasShown;
}

@property (nonatomic, strong) DIMapController *firstController;
@property (nonatomic, strong) ListVC *secondController;

@property (nonatomic, strong) DIDoubleSwipeView *bigView;

@end


@implementation DIListMapVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _firstController = [DIMapController new];
        _firstController.listMapController = self;
        _secondController = [ListVC new];
        _secondController.listMapController = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[_firstController view] setFrame:[[self view] bounds]];
    [[_secondController view] setFrame:[[self view] bounds]];
    
    _bigView = [[DIDoubleSwipeView alloc] initWithFrame:self.view.frame
                                              firstView:_firstController.view
                                             secondView:_secondController.view];
    _bigView.delegate = self;
    self.view = _bigView;
    
    UIView *titleView = [[UIView alloc] initWithFrame:TITLE_VIEW_FRAME];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:TITLE_LABEL_FRAME];
    titleLabel.text = @"Around About";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = TITLE_FONT;
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _naviBar = self.navigationController.navigationBar;
    
    if (NAVIBAR_MOVE_INTERACTIVE)
        [_naviBar addObserver:self
                   forKeyPath:@"frame"
                      options:NSKeyValueObservingOptionNew
                      context:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [_naviBar removeObserver:self
                  forKeyPath:@"frame"];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [self checkStatusbarNavibar];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    if (!_startAnimationHasShown) {
        [self startAnimation];
        _startAnimationHasShown = YES;
    }
}


#pragma mark - Actions

- (void)barButtonRightPressed {
    
}

- (void)barButtonLeftPressed {

    [_bigView switchViewsWithComplition:nil];
    [self setStatusbarNavibarHidden:YES];
}

//
//#pragma mark - KVO
//
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (NAVIBAR_MOVE_INTERACTIVE) {
        if (object == _naviBar) {
            if ([keyPath isEqualToString:@"frame"]) {
                CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
                [self navibarNewFrame:newFrame];
            }
        }
    }
}


#pragma mark - Navibar/Statusbar cutomization

- (void)setStatusBarHiddenWithStaticFrames:(BOOL)hidden {
    
    if ([UIApplication sharedApplication].statusBarHidden == hidden)
        return;
    
    CGRect frame = self.view.frame;
    CGRect navibarFrame = _naviBar.frame;
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
    self.view.frame = frame;
    _naviBar.frame = navibarFrame;
}

- (void)setStatusbarNavibarHidden:(BOOL)hidden {
    
    if (NAVIBAR_MOVE_INTERACTIVE) {
        [self setStatusBarHiddenWithStaticFrames:hidden];
    }
    else {
        [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationFade];
        [self.navigationController setNavigationBarHidden:hidden animated:YES];
    }
}

- (void)checkStatusbarNavibar {
    
    BOOL setHidden;
    if (_bigView.currentView == FirstViev)
        setHidden = YES;
    else
        setHidden = NO;
    
    [self setStatusbarNavibarHidden:setHidden];
}

- (void)navibarPositionManagingWithOffset:(CGFloat)offset {
    
    if (NAVIBAR_MOVE_INTERACTIVE) {
        CGFloat navibarOffset = 0.;
        CGRect frame = _naviBar.frame;
        
        //navibar frame changing
        if (offset > 0) {
            if (frame.origin.y <= 20. && _naviBar.frame.origin.y > -NAVIBAR_DELTA) {
                [self setStatusBarHiddenWithStaticFrames:YES];
                navibarOffset = (fabs(-NAVIBAR_DELTA - frame.origin.y) >= offset) ? offset : fabs(-NAVIBAR_DELTA - frame.origin.y);
                //[self setStatusbarNavibarHidden:YES];
            }
            else
                return;
        }
        else {
            if (frame.origin.y < 20.) {
                [self setStatusBarHiddenWithStaticFrames:NO];
                navibarOffset = (frame.origin.y - offset <= 20.) ? offset : (frame.origin.y - 20.);
                //[self setStatusbarNavibarHidden:NO];
            }
            else
                return;
        }
        frame.origin.y -= navibarOffset;
        _naviBar.frame = frame;
    }
    
    else {  //not NAVIBAR_MOVE_INTERACTIVE
        if (offset > 0) {
            if (!self.navigationController.navigationBarHidden) {
                [self setStatusbarNavibarHidden:YES];
            }
            else
                return;
        }
        else {
            if (self.navigationController.navigationBarHidden) {
                [self setStatusbarNavibarHidden:NO];
            }
            else
                return;
        }
    }
}

- (void)navibarNewFrame:(CGRect)frame {
    
    double scrollViewDelta = self.view.frame.origin.y - (_naviBar.frame.origin.y + _naviBar.frame.size.height);
    if (scrollViewDelta) {
        CGRect scrollFrame = self.view.frame;
        scrollFrame.origin.y -= scrollViewDelta;
        scrollFrame.size.height += scrollViewDelta;
        self.view.frame = scrollFrame;
    }
}

- (DIBarButton *)customizeBarButton:(DIBarButton *)button {
    
    if (button.sideMode == SideModeLeft) {
        [button setImage:[UIImage imageNamed:@"list_button_toMap"] forState:UIControlStateNormal];
        return button;
    }
/*    else if (button.sideMode == SideModeRight) {
        [button setImage:[UIImage imageNamed:@"list_button_menu"] forState:UIControlStateNormal];
        return button;
    }
*/    
    return nil;
}


#pragma mark - DIDoubleSwipeViewDelegate methods

- (void)switchAnimationFinished:(DIDoubleSwipeView *)doubleSwipeView {
    
    if (doubleSwipeView == _bigView)
        [self checkStatusbarNavibar];
}


#pragma mark

- (void)sightViewIsShowingOnMap:(BOOL)showing {
    
    [_bigView moveSwitchViewUp:!showing];
}


#pragma mark - Other functions

- (void)startAnimation {
    
    NSString *keyString = @"animationCounter";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSUInteger animationCounter = [defaults integerForKey:keyString];
    if (animationCounter >= MAX_START_ANIMATION_COUNT)
        return;
    animationCounter ++;
    [[NSUserDefaults standardUserDefaults] setInteger:animationCounter
                                               forKey:keyString];
    [defaults synchronize];
    
#if 0
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:1.4
                                  delay:0
                 usingSpringWithDamping:0.6
                  initialSpringVelocity:1
                                options:UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 [_bigView switchViewsWithComplition:^(BOOL finished) {
                                     [self checkStatusbarNavibar];
                                 }];
                             }
                             completion:nil];
        });
    });
#elif 1
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [_bigView showMapAnimation];
        });
    });
#endif
}


@end
