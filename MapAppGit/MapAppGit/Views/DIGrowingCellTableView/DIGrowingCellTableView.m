//
//  DIGrowingCellTableView.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 06.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIGrowingCellTableView.h"

#import "ListDefaults.h"
#import "DIDefaults.h"

#import "DIGrowingCell.h"


#define         ITEMS_COUNT             [self.delegate itemsCount]


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


@interface DIGrowingCellTableView ()
{
    NSMutableArray *_scrollingCells;
    DIGrowingCell *_growingCell;
    
    ContentDirection _direction;
    CGFloat _deltaOffset;
}

@property (nonatomic, strong) UIScrollView *scrollView;

@end


@implementation DIGrowingCellTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)awakeFromNib {
    
    [self initialization];
}

- (void)initialization {
    
    _scrollView = [UIScrollView new];
    _scrollView.delegate = self;
    _scrollView.bounces = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    
    _scrollingCells = [NSMutableArray array];
    //_growingCell = _scrollingCells[1];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    _scrollView.frame = rect;
    [self addSubview:_scrollView];
    
    float height = CELL_HEIGHT_BIG + 100 + CELL_HEIGHT*(ITEMS_COUNT-2) + (SCREEN_SIZE.height - CELL_HEIGHT_BIG);
    _scrollView.contentSize = CGSizeMake(rect.size.width, height);
    
    [self fillFirstScreen];
}


- (void)fillFirstScreen {
    
    double y = _scrollView.contentOffset.y;
    int cellIndex = 0;

    while (y <= (self.frame.size.height + HEIGHT_LIMIT)) {
        DIGrowingCell *cell = [self cellAtIndex:cellIndex];
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
            cellIndex++;
            y += cellHeight;
        }
    }
}


#pragma mark - Cells adding

- (DIGrowingCell *)cellAtIndex:(NSUInteger)index {
    
    DIGrowingCell *cell = [_delegate cellForIndex:index];
    
    if (cell) {
        [_scrollingCells insertObject:cell atIndex:index];
        cell.inTableView = YES;
        [_scrollView addSubview:cell];
    }
    
    return cell;
}

- (void)addTopCell {
    
    DIGrowingCell *topCell = _scrollingCells.firstObject;
    NSUInteger topCellIndex = topCell.dataIndex;
    NSUInteger index = topCellIndex - 1;
    
    DIGrowingCell *cell = [self cellAtIndex:index];
    if (cell) {
        float yOrigin = topCell.frame.origin.y - CELL_HEIGHT_BIG;
        CGRect frame = cell.frame;
        frame.size.height = CELL_HEIGHT_BIG;
        frame.origin.y = yOrigin;
        cell.frame = frame;
    }
}

- (void)addBottomCell {
    
    DIGrowingCell *bottomCell = _scrollingCells.lastObject;
    NSInteger bottomCellIndex = bottomCell.dataIndex;
    NSInteger index = bottomCellIndex + 1;
    if (index >= ITEMS_COUNT)
        return;
    
    DIGrowingCell *cell = [self cellAtIndex:index];
    if (cell) {
        float yOrigin = bottomCell.frame.origin.y + CELL_HEIGHT;
        CGRect frame = cell.frame;
        frame.size.height = CELL_HEIGHT;
        frame.origin.y = yOrigin;
        cell.frame = frame;
    }

}


#pragma mark - Cells removing

- (void)removeCell:(DIGrowingCell *)cell {
    
    //int index = [_scrollingCells indexOfObject:cell];
    [cell removeFromSuperview];
    [_scrollingCells removeObject:cell];
    cell.inTableView = NO;
    //NSLog(@"cell removed at index - %d", index);
}

- (void)removeTopCell {
    
    DIGrowingCell *topCell = _scrollingCells.firstObject;
    [self removeCell:topCell];
}

- (void)removeBottomCell {
    
    DIGrowingCell *bottomCell = _scrollingCells.lastObject;
    [self removeCell:bottomCell];
}


#pragma mark - UIScrollViewDelegate methods

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static CGFloat prevOffset = 0.;
    _deltaOffset = _scrollView.contentOffset.y - prevOffset;
    
    if (_deltaOffset >= 0)
        _direction = ContentUP;
    else
        _direction = ContentDown;
    
    [self navibarPositionManaging];
    [self growingCellManaging];
    [self whoIsGrowing];
    
    [self checkLimits];
    
    prevOffset = _scrollView.contentOffset.y;
    
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
    
    DIGrowingCell *cell;
    float cellOriginY;
    float cellHeight;
    
    //NSLog(@"%f", _tableView.contentOffset.y);
    //NSLog(@"%f", _tableView.frame.size.height);
    
    //top limit
    float topLimitY = _scrollView.contentOffset.y - HEIGHT_LIMIT;
    cell = (DIGrowingCell *)_scrollingCells.firstObject;
    cellOriginY = cell.frame.origin.y;
    cellHeight = cell.frame.size.height;
    if (cell.dataIndex != 0 && cellOriginY > topLimitY)
        [self addTopCell];
    if (cellOriginY + cellHeight < topLimitY)
        [self removeTopCell];
    
    //bottom limit
    float bottomLimitY = _scrollView.contentOffset.y + _scrollView.frame.size.height + HEIGHT_LIMIT;
    cell = (DIGrowingCell *)_scrollingCells.lastObject;
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

@end
