//
//  ThirdVC.m
//  TableV
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "ThirdVC.h"

#import "DIAppDelegate.h"
#import "ListDefaults.h"
#import "ListItem.h"

#import "DIMapController.h"

#define VIEW_FRAME                  self.view.frame
#define ITEMS_COUNT                 30

typedef enum {
    ContentUP   = 1,
    ContentDown = 2
} ContentDirection;

@interface ThirdVC ()
{
    NSMutableArray *_dataArray;
    NSMutableArray *_cellsArray;
    NSMutableArray *_scrollingCells;
    
    DICell *_topVisibleCell;
    DICell *_growingCell;
    
    ContentDirection _direction;
    
    UINavigationBar *_naviBar;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end

@implementation ThirdVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        DIAppDelegate *appDelegate = (DIAppDelegate *)[UIApplication sharedApplication].delegate;
        _dataArray = [NSMutableArray arrayWithArray:[appDelegate dataArray]];
        
        
        _cellsArray     = [NSMutableArray array];
        _scrollingCells = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Scroll Bands";
    self.edgesForExtendedLayout = UIRectEdgeNone;

    float height = CELL_HEIGHT_BIG + 100 + CELL_HEIGHT*(ITEMS_COUNT-2) + (SCREEN_SIZE.height - CELL_HEIGHT_BIG);
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
    
    [self fillFirstScreen];
    
    _topVisibleCell = _scrollingCells[0];
    _growingCell = _scrollingCells[1];
    
    _scrollView.bounces = NO;
    _naviBar = self.navigationController.navigationBar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fillFirstScreen {
    
    double y = _scrollView.contentOffset.y;
    int cellIndex = 0;
    
    //NSLog(@"%f", SCREEN_SIZE.height);
    while (y <= (SCREEN_SIZE.height + HEIGHT_LIMIT)) {
        DICell *cell = [self cellForIndex:cellIndex];
        if (cell) {
            double cellHeight;
            if (cellIndex == 0)
                cellHeight = CELL_HEIGHT_BIG;
            else if (cellIndex == 1)
                cellHeight = CELL_HEIGHT + deltaHeight(THIRD_CELL_ORIGIN, CELL_HEIGHT);
            else
                cellHeight = CELL_HEIGHT;
            
            CGRect frame = cell.frame;
            frame.size.height = cellHeight;
            frame.origin.y = y;
            cell.frame = frame;
            [self addCell:cell atIndex:cellIndex];
            cellIndex++;
            y += cellHeight;
        }
    }
}


#pragma mark - ScrollView managing

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static double prevOffset = 0.;
    double deltaOffset = _scrollView.contentOffset.y - prevOffset;
    
    if (deltaOffset >= 0)
        _direction = ContentUP;
    else
        _direction = ContentDown;
    
    if (_direction == ContentUP) {
        if (_naviBar.frame.origin.y <= 20. && _naviBar.frame.origin.y > -44.) {
            if (![UIApplication sharedApplication].statusBarHidden)
                [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
            CGRect frame = _naviBar.frame;
            deltaOffset = (fabs(-44. - frame.origin.y) >= deltaOffset) ? deltaOffset : fabs(-44. - frame.origin.y);
            frame.origin.y -= deltaOffset;
            _naviBar.frame = frame;
        }
    }
    else { //_direction == ContentDown
        if (_naviBar.frame.origin.y < 20.) {
            if ([UIApplication sharedApplication].statusBarHidden)
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            CGRect frame = _naviBar.frame;
            double naviOffset = (frame.origin.y + fabs(deltaOffset) <= 20.) ? deltaOffset : (20. - frame.origin.y);
            frame.origin.y -= naviOffset;
            _naviBar.frame = frame;
        }
    }
    
    double scrollViewDelta = _scrollView.superview.frame.origin.y - (_naviBar.frame.origin.y + _naviBar.frame.size.height);
    if (scrollViewDelta) {
        CGRect scrollFrame = _scrollView.superview.frame;
        scrollFrame.origin.y -= scrollViewDelta;
        scrollFrame.size.height += scrollViewDelta;
        _scrollView.superview.frame = scrollFrame;
    }
    
    [self growingCellManaging];
    [self checkLimits];
    
    //DICell *cell = (DICell *)_scrollingCells.lastObject;
    //NSLog(@"contentHeight = %f", _scrollView.contentSize.height);
    //NSLog(@"last cell = %d, orig = %f", cell.dataIndex, cell.frame.origin.y);
    
    prevOffset = _scrollView.contentOffset.y;
}

- (void)checkLimits {
    
    DICell *cell;
    float cellOriginY;
    float cellHeight;
    
    //NSLog(@"%f", _scrollView.contentOffset.y);
    //NSLog(@"%f", _scrollView.frame.size.height);
    
    //top limit
    float topLimitY = _scrollView.contentOffset.y - HEIGHT_LIMIT;
    cell = (DICell *)_scrollingCells.firstObject;
    cellOriginY = cell.frame.origin.y;
    cellHeight = cell.frame.size.height;
    if (cell.dataIndex != 0 && cellOriginY > topLimitY)
        [self addTopCell];
    if (cellOriginY + cellHeight < topLimitY)
        [self removeTopCell];
    
    //bottom limit
    float bottomLimitY = _scrollView.contentOffset.y + _scrollView.frame.size.height + HEIGHT_LIMIT;
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
    
    if (prevCell)
        [self setPrevCellAsGrowing];
    else if (nextCell)
        [self setNextCellAsGrowing];
}

- (void)setNextCellAsGrowing {
    
    int nextIndex = [_scrollingCells indexOfObject:_growingCell] + 1;
    if (_scrollingCells.count > nextIndex) {
        _growingCell = _scrollingCells[nextIndex];
    }
}

- (void)setPrevCellAsGrowing {
    
    int prevIndex = [_scrollingCells indexOfObject:_growingCell] - 1;
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
    }
    else {
        cell = _cellsArray[index];
    }
    
    return cell;
}


#pragma mark - Cells adding

- (void)addCell:(DICell *)cell atIndex:(int)index {
    
    [_scrollingCells insertObject:cell atIndex:index];
    //cell.titleString = [NSString stringWithFormat:@"%d", cell.dataIndex];
    int t = cell.dataIndex%5;
    ListItem *item = (ListItem *)_dataArray[t];
    cell.titleString = item.name;
    cell.description = item.descriptionString;
    cell.imageData = item.imageData;
    [_scrollView addSubview:cell];
    //NSLog(@"cell added at index - %d", index);
}

- (void)addTopCell {
    
    DICell *topCell = _scrollingCells.firstObject;
    int topCellIndex = topCell.dataIndex;
    if (topCellIndex > 0) {
        int index = topCellIndex - 1;
        DICell *cell = [self cellForIndex:index];
        if (cell) {
            float yOrigin = topCell.frame.origin.y - CELL_HEIGHT_BIG;
            CGRect frame = cell.frame;
            frame.size.height = CELL_HEIGHT_BIG;
            frame.origin.y = yOrigin;
            cell.frame = frame;
            [self addCell:cell atIndex:0];
        }
    }
}

- (void)addBottomCell {
    
    DICell *bottomCell = _scrollingCells.lastObject;
    int bottomCellIndex = bottomCell.dataIndex;
    if (bottomCellIndex < _cellsArray.count-1) {
        int index = bottomCellIndex + 1;
        DICell *cell = [self cellForIndex:index];
        if (cell) {
            float yOrigin = bottomCell.frame.origin.y + CELL_HEIGHT;
            CGRect frame = cell.frame;
            frame.size.height = CELL_HEIGHT;
            frame.origin.y = yOrigin;
            cell.frame = frame;
            [self addCell:cell atIndex:_scrollingCells.count];
        }
    }
}


#pragma mark - Cells removing

- (void)removeCell:(DICell *)cell {
    
    //int index = [_scrollingCells indexOfObject:cell];
    [cell removeFromSuperview];
    [_scrollingCells removeObject:cell];
    //NSLog(@"cell removed at index - %d", index);
}

- (void)removeTopCell {
    
    DICell *topCell = _scrollingCells.firstObject;
    int topCellIndex = topCell.dataIndex;
    if (topCellIndex < _scrollingCells.count) {
        [self removeCell:topCell];
    }
}

- (void)removeBottomCell {
    
    DICell *bottomCell = _scrollingCells.lastObject;
    int bottomCellIndex = bottomCell.dataIndex;
    if (bottomCellIndex > 1) {
        [self removeCell:bottomCell];
    }
}


#pragma mark - DICellDelegate methods

- (void)cellDidSelect:(DICell *)cell {
    
    DIMapController *mapController = [[DIMapController alloc] init];
    [self.navigationController pushViewController:mapController animated:YES];
}


@end
