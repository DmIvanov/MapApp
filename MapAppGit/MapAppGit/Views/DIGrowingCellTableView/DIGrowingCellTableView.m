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

#import "DICell.h"

@implementation DIGrowingCellTableView
{
    NSMutableArray *_scrollingCells;
    DICell *_growingCell;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        float height = CELL_HEIGHT_BIG + 100 + CELL_HEIGHT*([self.delegate itemsCount]-2) + (SCREEN_SIZE.height - CELL_HEIGHT_BIG);
        self.contentSize = CGSizeMake(frame.size.width, height);
        
        _scrollingCells = [NSMutableArray array];
        //_growingCell = _scrollingCells[1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [self fillFirstScreen];
}


- (void)fillFirstScreen {
    
    double y = self.contentOffset.y;
    int cellIndex = 0;

    while (y <= (self.frame.size.height + HEIGHT_LIMIT)) {
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


#pragma mark - Cells adding

- (void)addCell:(DICell *)cell atIndex:(NSInteger)index {
    
    [_scrollingCells insertObject:cell atIndex:index];
    cell.inTableView = YES;
    int t = cell.dataIndex%5;
    ListItem *item = (ListItem *)_dataArray[t];
    cell.titleString = item.name;
    cell.description = item.descriptionString;
    cell.imageData = item.imageData;
    [_tableView addSubview:cell];
}

- (void)addTopCell {
    
    DICell *topCell = _scrollingCells.firstObject;
    NSInteger topCellIndex = topCell.dataIndex;
    if (topCellIndex > 0) {
        NSInteger index = topCellIndex - 1;
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
    NSInteger bottomCellIndex = bottomCell.dataIndex;
    if (bottomCellIndex <= _cellsArray.count-1) {
        NSInteger index = bottomCellIndex + 1;
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
    cell.inTableView = NO;
    //NSLog(@"cell removed at index - %d", index);
}

- (void)removeTopCell {
    
    DICell *topCell = _scrollingCells.firstObject;
    NSInteger topCellIndex = topCell.dataIndex;
    if (topCellIndex < _scrollingCells.count) {
        [self removeCell:topCell];
    }
}

- (void)removeBottomCell {
    
    DICell *bottomCell = _scrollingCells.lastObject;
    NSInteger bottomCellIndex = bottomCell.dataIndex;
    if (bottomCellIndex > 1) {
        [self removeCell:bottomCell];
    }
}

@end
