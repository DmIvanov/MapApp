//
//  ListVC.m
//
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "ListVC.h"

#import "DIDefaults.h"
#import "ListDefaults.h"
#import "ListItem.h"
#import "DISightsManager.h"

#import "DIMapController.h"

#import "DIGrowingCellTableView.h"

#define VIEW_FRAME                  self.view.frame
#define ITEMS_COUNT                 60
#define NAVIBAR_DELTA               44.
#define NAVIBAR_FRAME               CGRectMake(0, 20, SCREEN_SIZE.width, NAVIBAR_DELTA);


@interface ListVC ()
{
    NSMutableArray *_dataArray;
    UINavigationBar *_naviBar;
}

@property (nonatomic, strong) DIGrowingCellTableView *tableView;

@end

@implementation ListVC


#pragma mark - Controller life cycle

- (id)init {
    
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray arrayWithArray:[[DISightsManager sharedInstance] dataArray]];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tableView = [[DIGrowingCellTableView alloc] initWithFrame:self.view.frame];
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    
    self.navigationItem.title = @"Scroll Bands";
    UIBarButtonItem *rightBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                                                                    target:self
                                                                                    action:@selector(barButtonActionTapped:)];
    [self.navigationItem setRightBarButtonItem:rightBarButton];
    
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

- (void)viewWillAppear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    _naviBar.frame = NAVIBAR_FRAME;
    
}

- (void)dealloc {
    
    [_naviBar removeObserver:self
                  forKeyPath:@"frame"];
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


#pragma mark - DICellDelegate methods

- (void)cellDidSelect:(DICell *)cell {
    
    DIMapController *mapController = [[DIMapController alloc] init];
    [self.navigationController pushViewController:mapController animated:YES];
}


#pragma mark - DIGrowingCellTableViewDelegate methods

- (NSUInteger)itemsCount {
    
    return ITEMS_COUNT;
}

- (DIGrowingCell *)cellForIndex:(NSUInteger)index {
    
    //init
    DICell *cell = [[DICell alloc] init];
    cell.dataIndex = index;
    cell.delegate = self;
    
    //fill
    int t = cell.dataIndex%5;
    ListItem *item = (ListItem *)_dataArray[t];
    cell.titleString = item.name;
    cell.descriptionString = item.descriptionString;
    cell.imageData = item.imageData;
    
    return cell;
}

- (void)tableViewIsScrolling:(DIGrowingCellTableView *)tableView {
    
    [self navibarPositionManaging];
}


#pragma mark - Actions

- (void)barButtonActionTapped:(id)sender {
    
    [_tableView reload];
}


#pragma mark - Other functions

- (void)navibarPositionManaging {
    
    CGFloat navibarOffset = 0.;
    CGRect frame = _naviBar.frame;
    CGFloat offset = _tableView.deltaOffset;
    
    //navibar frame changing
    if (_tableView.direction == ContentUP) {
        if (frame.origin.y <= 20. && _naviBar.frame.origin.y > -NAVIBAR_DELTA) {
            if (![UIApplication sharedApplication].statusBarHidden)
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            navibarOffset = (fabs(-NAVIBAR_DELTA - frame.origin.y) >= offset) ? offset : fabs(-NAVIBAR_DELTA - frame.origin.y);
        }
        else
            return;
    }
    else { //_direction == ContentDown
        if (frame.origin.y < 20.) {
            if ([UIApplication sharedApplication].statusBarHidden)
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            navibarOffset = (frame.origin.y - offset <= 20.) ? offset : (frame.origin.y - 20.);
        }
        else
            return;
    }
    frame.origin.y -= navibarOffset;
    _naviBar.frame = frame;
}

- (void)navibarNewFrame:(CGRect)frame {
    
    //scroll view frame changing
    double scrollViewDelta = _tableView.superview.frame.origin.y - (_naviBar.frame.origin.y + _naviBar.frame.size.height);
    if (scrollViewDelta) {
        CGRect scrollFrame = _tableView.superview.frame;
        scrollFrame.origin.y -= scrollViewDelta;
        scrollFrame.size.height += scrollViewDelta;
        _tableView.superview.frame = scrollFrame;
    }
}

@end
