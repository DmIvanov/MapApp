//
//  ThirdVC.m
//  TableV
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "ThirdVC.h"

#import "DIAppDelegate.h"
#import "DIDefaults.h"
#import "ListDefaults.h"
#import "ListItem.h"

#import "DIMapController.h"

#import "DIGrowingCellTableView.h"

#define VIEW_FRAME                  self.view.frame
#define ITEMS_COUNT                 60
#define NAVIBAR_DELTA               44.
#define NAVIBAR_FRAME               CGRectMake(0, 20, SCREEN_SIZE.width, NAVIBAR_DELTA);


@interface ThirdVC ()
{
    NSMutableArray *_dataArray;
    NSMutableArray *_cellsArray;
    
    UINavigationBar *_naviBar;
    
    
}

@property (nonatomic, strong) DIGrowingCellTableView *tableView;

@end

@implementation ThirdVC

- (id)init {
    
    self = [super init];
    if (self) {
        DIAppDelegate *appDelegate = (DIAppDelegate *)[UIApplication sharedApplication].delegate;
        _dataArray = [NSMutableArray arrayWithArray:[appDelegate dataArray]];
        
        _cellsArray     = [NSMutableArray array];
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
    self.navigationController.navigationBar.frame = NAVIBAR_FRAME;
    
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
    
    return _dataArray.count;
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
    cell.description = item.descriptionString;
    cell.imageData = item.imageData;
    
    return cell;
}

#pragma mark - Other functions

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
