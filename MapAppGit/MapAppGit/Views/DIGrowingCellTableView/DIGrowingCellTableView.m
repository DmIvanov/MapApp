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
    PositionWrong           = 0,
    PositionAboveGrowing    = 1,
    PositionGgowing         = 2,
    PositionBelowGrowing    = 3
} CellGrowingPosition;


@interface DIGrowingCellTableView ()
{
    NSMutableArray *_scrollingCells;
    DIGrowingCell *_growingCell;
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

    while (y <= (self.frame.size.height + HEIGHT_LIMIT_DOWN)) {
        DIGrowingCell *cell = [self addBottomCell]; //definition of cell's frame
        if (cell) { //redefinition of cell's frame - not good
            CGFloat cellHeight = [self cellHeightForFirstScreenCell:cell.dataIndex];
            CGRect frame = cell.frame;
            frame.size.height = cellHeight;
            frame.origin.y = y;
            cell.frame = frame;
            cellIndex++;
            y += cellHeight;
        }
    }
    
    if (_scrollingCells.count > 1)
        _growingCell = _scrollingCells[1];
}


#pragma mark - Cells adding

- (DIGrowingCell *)addTopCell {
    
    DIGrowingCell *topCell = _scrollingCells.firstObject;
    NSUInteger topCellIndex = topCell.dataIndex;
    NSUInteger index = topCellIndex - 1;
    
    DIGrowingCell *cell = [_delegate cellForIndex:index];
    if (cell) {
        float yOrigin = topCell.frame.origin.y - CELL_HEIGHT_BIG;
        CGRect frame = cell.frame;
        frame.size.height = CELL_HEIGHT_BIG;
        frame.origin.y = yOrigin;
        cell.frame = frame;
        //DLog(@">>>>> add top cell %d to frame %@", cell.dataIndex, NSStringFromCGRect(frame));
        
        cell.inTableView = YES;
        [_scrollView addSubview:cell];
        [_scrollingCells insertObject:cell atIndex:0];
        return cell;
    }
    
    return nil;
}

- (DIGrowingCell *)addBottomCell {
    
    DIGrowingCell *bottomCell = _scrollingCells.lastObject;
    NSInteger index;
    if (bottomCell) {
        NSInteger bottomCellIndex = bottomCell.dataIndex;
        index = bottomCellIndex + 1;
        if (index >= ITEMS_COUNT)
            return nil;
    }
    else {
        index = 0;
    }
    
    DIGrowingCell *cell = [_delegate cellForIndex:index];
    if (cell) {
        float yOrigin = bottomCell.frame.origin.y + CELL_HEIGHT;
        CGRect frame = cell.frame;
        frame.size.height = CELL_HEIGHT;
        frame.origin.y = yOrigin;
        cell.frame = frame;
        //DLog(@">>>>> add bottom cell");
        
        cell.inTableView = YES;
        [_scrollView addSubview:cell];
        [_scrollingCells addObject:cell];
        return  cell;
    }
    
    return nil;
}


#pragma mark - Cells removing

- (void)removeCell:(DIGrowingCell *)cell {
    
    //int index = [_scrollingCells indexOfObject:cell];
    [cell removeFromSuperview];
    [_scrollingCells removeObject:cell];
    cell.inTableView = NO;
}

- (void)removeTopCell {
    
    DIGrowingCell *topCell = _scrollingCells.firstObject;
    //DLog(@">>>>> remove top cell: %d", topCell.dataIndex);
    [self removeCell:topCell];
}

- (void)removeBottomCell {
    
    DIGrowingCell *bottomCell = _scrollingCells.lastObject;
    //DLog(@">>>>> remove bottom cell: %d", bottomCell.dataIndex);
    [self removeCell:bottomCell];
}


#pragma mark - UIScrollViewDelegate methods

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    
    return NO;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static CGFloat prevOffset = 0.;
    _deltaOffset = _scrollView.contentOffset.y - prevOffset;
    
    if (_deltaOffset > 0)
        _direction = ContentUP;
    else
        _direction = ContentDown;
    
    if ([_delegate respondsToSelector:@selector(tableViewIsScrolling:)])
        [_delegate tableViewIsScrolling:self];      //for navibar frame changing, for example
    
    [self growingCellManaging];
    [self whoIsGrowing];
    
    [self checkLimits];
    
    prevOffset = _scrollView.contentOffset.y;
    
    _deltaOffset = 0.; //_deltaOffset make sence only while view is scrolling
    
    //DLog(@"scrolling cells - %d", _scrollingCells.count);
}


#pragma mark - ScrollView managing

- (void)checkLimits {
    
    DIGrowingCell *cell;
    float cellOriginY;
    float cellHeight;
    
    //NSLog(@"%f", _tableView.contentOffset.y);
    //NSLog(@"%f", _tableView.frame.size.height);
    
    //top limit
    float topLimitY = _scrollView.contentOffset.y - HEIGHT_LIMIT_UP;
    cell = (DIGrowingCell *)_scrollingCells.firstObject;
    cellOriginY = cell.frame.origin.y;
    cellHeight = cell.frame.size.height;
    if (cell.dataIndex != 0 && cellOriginY > topLimitY)
        [self addTopCell];
    if (cellOriginY + cellHeight < topLimitY)
        [self removeTopCell];
    
    //bottom limit
    float bottomLimitY = _scrollView.contentOffset.y + _scrollView.frame.size.height + HEIGHT_LIMIT_DOWN;
    cell = (DIGrowingCell *)_scrollingCells.lastObject;
    cellOriginY = cell.frame.origin.y;
    cellHeight = cell.frame.size.height;
    if (cellOriginY + cellHeight < bottomLimitY)
        [self addBottomCell];
    if (cellOriginY > bottomLimitY)
        [self removeBottomCell];
}

- (CGRect)frameInView:(DIGrowingCell *)cell {
    
    return [cell.superview convertRect:cell.frame toView:self];
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
        
        for (DIGrowingCell *cell in _scrollingCells) {
            if (cell.dataIndex < _growingCell.dataIndex) {
                CGRect frame = cell.frame;
                frame.origin.y -= delta;
                cell.frame = frame;
            }
        }
    }
}

- (void)whoIsGrowing {
    
    CellGrowingPosition posOfCurrentGrowingCell = [self growingPositionForCell:_growingCell];
    if (posOfCurrentGrowingCell == PositionGgowing)
        return;
    
    NSUInteger growingDataIndex = _growingCell.dataIndex;
    if (posOfCurrentGrowingCell == PositionAboveGrowing) {
        NSUInteger nextDataIndex = growingDataIndex + 1;
        if (nextDataIndex >= ITEMS_COUNT)
            return;
        CGFloat deltaSum = 0.;
        for (; nextDataIndex < ITEMS_COUNT; ++nextDataIndex) {
            DIGrowingCell *cell = [self cellForIndex:nextDataIndex];
            if (!cell.inTableView)
                break;
            if (deltaSum) {
                CGRect frame = cell.frame;
                frame.origin.y -= deltaSum;
                cell.frame = frame;
            }
            if ([self growingPositionForCell:cell] == PositionAboveGrowing) {
                CGRect frame = cell.frame;
                CGFloat delta = CELL_HEIGHT_BIG - frame.size.height;
                if (delta) {
                    frame.size.height += delta;
                    frame.origin.y -= delta;
                    cell.frame = frame;
                    deltaSum += delta;
                }
            }
        }
    }
    
    else if (posOfCurrentGrowingCell == PositionBelowGrowing) {
        NSUInteger prevDataIndex = growingDataIndex - 1;
        if (!prevDataIndex || prevDataIndex <= 0)
            return;
        CGFloat deltaSum = 0.;
        for (; prevDataIndex > 0; --prevDataIndex) {
            DIGrowingCell *cell = [self cellForIndex:prevDataIndex];
            if (!cell.inTableView)
                break;
            if (deltaSum) {
                CGRect frame = cell.frame;
                frame.origin.y -= deltaSum;
                cell.frame = frame;
            }
            if ([self growingPositionForCell:cell] == PositionBelowGrowing) {
                CGRect frame = cell.frame;
                CGFloat delta = CELL_HEIGHT - frame.size.height;
                if (delta) {
                    frame.size.height += delta;
                    frame.origin.y -= delta;
                    cell.frame = frame;
                    deltaSum += delta;
                }
            }
        }
    }
}

- (CellGrowingPosition)growingPositionForCell:(DIGrowingCell *)cell {
    
    if (!cell.inTableView)
        return PositionWrong;
    
    NSUInteger nextCellIndex = [_scrollingCells indexOfObject:cell] + 1;
    if (nextCellIndex > _scrollingCells.count)
        return  PositionWrong;

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

- (DIGrowingCell *)cellForIndex:(NSUInteger)index {
    
    NSUInteger returnIndex = [_scrollingCells indexOfObjectPassingTest:^BOOL(DIGrowingCell *cell, NSUInteger idx, BOOL *stop) {
        return cell.dataIndex == index;
    }];
    
    if (returnIndex == NSNotFound)
        return nil;
    else
        return _scrollingCells[returnIndex];
}

- (CGFloat)cellHeightForFirstScreenCell:(NSUInteger)index {

    CGFloat cellHeight;
    if (index == 0)
        cellHeight = CELL_HEIGHT_BIG;
    else if (index == 1) {
        cellHeight = CELL_HEIGHT + deltaHeight(THIRD_CELL_ORIGIN, CELL_HEIGHT);
    }
    else
        cellHeight = CELL_HEIGHT;
    
    return cellHeight;
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
