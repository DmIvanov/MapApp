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

typedef enum {
    ContentUP   = 1,
    ContentDown = 2
} ContentDirection;

typedef enum {
    PositionWrong           = 0,
    PositionAboveGrowing    = 1,
    PositionGgowing         = 2,
    PositionBelowGrowing    = 3
} CellGrowingPosition;

@interface ThirdVC ()
{
    NSMutableArray *_dataArray;
    NSMutableArray *_cellsArray;
    
    ContentDirection _direction;
    
    UINavigationBar *_naviBar;
    
    CGFloat _deltaOffset;
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
    
    _tableView.bounces = NO;
    _tableView.showsVerticalScrollIndicator = NO;
    
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





#pragma mark - UIScrollViewDelegate methods

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static double prevOffset = 0.;
    _deltaOffset = _tableView.contentOffset.y - prevOffset;
    
    if (_deltaOffset >= 0)
        _direction = ContentUP;
    else
        _direction = ContentDown;
    
    [self navibarPositionManaging];
    [self growingCellManaging];
    [self whoIsGrowing];
    
    [self checkLimits];
    
    prevOffset = _tableView.contentOffset.y;
    
    _deltaOffset = 0.; //_deltaOffset make sence only while view is scrolling
}



#pragma mark - ScrollView managing

- (void)navibarPositionManaging {
    
    CGFloat navibarOffset = 0.;
    CGRect frame = _naviBar.frame;

    //navibar frame changing
    if (_direction == ContentUP) {
        if (frame.origin.y <= 20. && _naviBar.frame.origin.y > -NAVIBAR_DELTA) {
            if (![UIApplication sharedApplication].statusBarHidden)
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            navibarOffset = (fabs(-NAVIBAR_DELTA - frame.origin.y) >= _deltaOffset) ? _deltaOffset : fabs(-NAVIBAR_DELTA - frame.origin.y);
        }
        else
            return;
    }
    else { //_direction == ContentDown
        if (frame.origin.y < 20.) {
            if ([UIApplication sharedApplication].statusBarHidden)
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            navibarOffset = (frame.origin.y - _deltaOffset <= 20.) ? _deltaOffset : (frame.origin.y - 20.);
        }
        else
            return;
    }
    frame.origin.y -= navibarOffset;
    _naviBar.frame = frame;
}

- (void)checkLimits {
    
    DICell *cell;
    float cellOriginY;
    float cellHeight;
    
    //NSLog(@"%f", _tableView.contentOffset.y);
    //NSLog(@"%f", _tableView.frame.size.height);
    
    //top limit
    float topLimitY = _tableView.contentOffset.y - HEIGHT_LIMIT;
    cell = (DICell *)_scrollingCells.firstObject;
    cellOriginY = cell.frame.origin.y;
    cellHeight = cell.frame.size.height;
    if (cell.dataIndex != 0 && cellOriginY > topLimitY)
        [self addTopCell];
    if (cellOriginY + cellHeight < topLimitY)
        [self removeTopCell];
    
    //bottom limit
    float bottomLimitY = _tableView.contentOffset.y + _tableView.frame.size.height + HEIGHT_LIMIT;
    cell = (DICell *)_scrollingCells.lastObject;
    cellOriginY = cell.frame.origin.y;
    cellHeight = cell.frame.size.height;
    if (cellOriginY + cellHeight < bottomLimitY)
        [self addBottomCell];
    if (cellOriginY > bottomLimitY)
        [self removeBottomCell];
}

- (CGRect)frameInView:(DICell *)cell {
    
    return [cell.superview convertRect:cell.frame toView:self.view];
}

double deltaHeight (double origY, double height) {

    if (origY <= START_TRANSFORM_POSITION) {
        return CELL_HEIGHT_BIG - CELL_HEIGHT;
    }
    else {
        double y = END_TRANSFORM_POSITION - origY;
        double delta = y * CELL_HEIGHT_BIG / CELL_HEIGHT - height;
        return delta;
    }
}

- (void)growingCellManaging {
    
    //NSLog(@"cell - %2d %@", _growingCell.dataIndex, _growingCell);
    
    CGRect frameInView = [self frameInView:_growingCell];
    double growingCellCoordY = frameInView.origin.y;
    
    CGRect frame = _growingCell.frame;
    double currentHeight = frame.size.height;
    double origYNextCell = growingCellCoordY + currentHeight;
    
    double delta = deltaHeight(origYNextCell, currentHeight);
    
    BOOL nextCell = NO;
    BOOL prevCell = NO;
    if (frame.size.height + delta < CELL_HEIGHT) {
        if (_direction == ContentDown) {
            prevCell = YES;
        }
        delta = CELL_HEIGHT - frame.size.height;
    }
    else if (frame.size.height + delta > CELL_HEIGHT_BIG) {
        if (_direction == ContentUP) {
            nextCell = YES;
        }
        delta = CELL_HEIGHT_BIG - frame.size.height;
    }
    
    if (delta) {
        frame.size.height += delta;
        frame.origin.y -= delta;
        _growingCell.frame = frame;
        
        for (DICell *cell in _scrollingCells) {
            if (cell.dataIndex < _growingCell.dataIndex) {
                CGRect frame = cell.frame;
                frame.origin.y -= delta;
                cell.frame = frame;
            }
        }
    }
    
//    if (prevCell)
//        [self setPrevCellAsGrowing];
//    else if (nextCell)
//        [self setNextCellAsGrowing];
}

- (void)whoIsGrowing {
    
    CellGrowingPosition posOfCurrentGrowingCell = [self growingPositionForCell:_growingCell];
    if (posOfCurrentGrowingCell == PositionGgowing)
        return;
    
    NSUInteger growingDataIndex = [_cellsArray indexOfObject:_growingCell];
    if (posOfCurrentGrowingCell == PositionAboveGrowing) {
        NSUInteger nextDataIndex = growingDataIndex + 1;
        if (!nextDataIndex || nextDataIndex >= _cellsArray.count)
            return;
        for (; nextDataIndex < _cellsArray.count; ++nextDataIndex) {
            DICell *cell = _cellsArray[nextDataIndex];
            if (!cell.inTableView)
                break;
            if ([self growingPositionForCell:cell] == PositionAboveGrowing) {
                CGRect frame = cell.frame;
                CGFloat delta = CELL_HEIGHT_BIG - frame.size.height;
                if (delta) {
                    frame.size.height += delta;
                    frame.origin.y -= delta;
                    cell.frame = frame;
                }
            }
        }
    }
    
    else if (posOfCurrentGrowingCell == PositionBelowGrowing) {
        NSUInteger prevDataIndex = growingDataIndex - 1;
        if (!prevDataIndex || prevDataIndex <= 0)
            return;
        for (; prevDataIndex > 0; --prevDataIndex) {
            DICell *cell = _cellsArray[prevDataIndex];
            if (!cell.inTableView)
                break;
            if ([self growingPositionForCell:cell] == PositionBelowGrowing) {
                CGRect frame = cell.frame;
                CGFloat delta = CELL_HEIGHT - frame.size.height;
                if (delta) {
                    frame.size.height += delta;
                    frame.origin.y -= delta;
                    cell.frame = frame;
                }
            }
        }
    }

    //DLog(@"start - %@   end - %@ next - %@  yCoordNext - %@", @(START_TRANSFORM_POSITION), @(END_TRANSFORM_POSITION), @(nextDataIndex), @(frameInView.origin.y));
}

- (void)setNextCellAsGrowing {
    
    NSInteger nextIndex = [_scrollingCells indexOfObject:_growingCell] + 1;
    if (_scrollingCells.count > nextIndex) {
        _growingCell = _scrollingCells[nextIndex];
    }
}

- (void)setPrevCellAsGrowing {
    
    NSInteger prevIndex = [_scrollingCells indexOfObject:_growingCell] - 1;
    if (prevIndex > 0) {
        _growingCell = _scrollingCells[prevIndex];
    }
}

- (DICell *)cellForIndex:(NSUInteger)index {
    
    if (index >= ITEMS_COUNT)
        return nil;
    
    DICell *cell;
    if (index >= _cellsArray.count) {
        cell = [[DICell alloc] init];
        cell.dataIndex = index;
        cell.delegate = self;
        [_cellsArray addObject:cell];
    }
    else {
        cell = _cellsArray[index];
    }
    
    return cell;
}

- (CellGrowingPosition)growingPositionForCell:(DICell *)cell {
    
    if (!cell.inTableView)
        return PositionWrong;
    
    NSUInteger nextCellIndex = [_scrollingCells indexOfObject:cell] + 1;
    if (nextCellIndex > _scrollingCells.count)
        return  PositionWrong;
    
    //DICell *nextCell = _scrollingCells[nextCellIndex];
    CGRect frame = [self frameInView:cell];
    CGFloat yCoord = CGRectGetMaxY(frame);
    if (yCoord <= START_TRANSFORM_POSITION)
        return PositionAboveGrowing;
    else if (yCoord > START_TRANSFORM_POSITION && yCoord <= END_TRANSFORM_POSITION) {
        if (_growingCell != cell)
            _growingCell = cell;
        return PositionGgowing;
    }
    else if (yCoord > END_TRANSFORM_POSITION)
        return PositionBelowGrowing;
    
    return PositionWrong;
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
