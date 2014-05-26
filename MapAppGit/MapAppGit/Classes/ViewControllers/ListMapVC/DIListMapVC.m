//
//  DIListMapVC.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 10.05.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIListMapVC.h"

#import "DIDoubleSwipeView.h"
#import "ListVC.h"
#import "DIMapController.h"
#import "DIBarButton.h"

#define VIEW_FRAME                  self.view.frame
#define NAVIBAR_DELTA               44.


@interface DIListMapVC ()
{
    UINavigationBar *_naviBar;
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
    
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _firstController = [DIMapController new];
    _firstController.listMapController = self;
    [[_firstController view] setFrame:[[self view] bounds]];
    
    _secondController = [ListVC new];
    _secondController.listMapController = self;
    [[_secondController view] setFrame:[[self view] bounds]];
    
    _bigView = [[DIDoubleSwipeView alloc] initWithFrame:self.view.frame
                                              firstView:_firstController.view
                                             secondView:_secondController.view];
    self.view = _bigView;
    
    self.navigationItem.title = @"Awesome Title!!";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _naviBar = self.navigationController.navigationBar;
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


#pragma mark - Actions

- (void)barButtonRightPressed {
    
}

- (void)barButtonLeftPressed {

    [_bigView switchViewsWithComplition:^(BOOL finished) {
        [self setStatusBarHiddenWithStaticFrames:YES];
    }];
    
    CGRect frame = _naviBar.frame;
    frame.origin.y = -NAVIBAR_DELTA;
    [UIView animateWithDuration:SWITCH_ANIMATION_TIME
                     animations:^{
                         _naviBar.frame = frame;
                     }];
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == _naviBar) {
        if ([keyPath isEqualToString:@"frame"]) {
            CGRect newFrame = [change[NSKeyValueChangeNewKey] CGRectValue];
            [self navibarNewFrame:newFrame];
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

- (void)navibarPositionManagingWithOffset:(CGFloat)offset {
    
    CGFloat navibarOffset = 0.;
    CGRect frame = _naviBar.frame;
    
    //navibar frame changing
    if (offset > 0) {
        if (frame.origin.y <= 20. && _naviBar.frame.origin.y > -NAVIBAR_DELTA) {
            [self setStatusBarHiddenWithStaticFrames:YES];
            navibarOffset = (fabs(-NAVIBAR_DELTA - frame.origin.y) >= offset) ? offset : fabs(-NAVIBAR_DELTA - frame.origin.y);
        }
        else
            return;
    }
    else {
        if (frame.origin.y < 20.) {
            [self setStatusBarHiddenWithStaticFrames:NO];
            navibarOffset = (frame.origin.y - offset <= 20.) ? offset : (frame.origin.y - 20.);
        }
        else
            return;
    }
    frame.origin.y -= navibarOffset;
    _naviBar.frame = frame;
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
    else if (button.sideMode == SideModeRight) {
        [button setImage:[UIImage imageNamed:@"list_button_menu"] forState:UIControlStateNormal];
        return button;
    }
    
    return nil;
}


@end
