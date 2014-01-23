//
//  ThirdVC.m
//  TableV
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "ThirdVC.h"

#import "ListDefaults.h"
#import "DICell.h"

#define VIEW_FRAME                  self.view.frame

@interface ThirdVC ()
{
    NSArray *_dataArray;
    NSMutableArray *_cellsArray;
    NSMutableArray *_scrollingCells;
    
    DICell *_topCell;
    DICell *_topVisibleCell;
    DICell *_growingCell;
    DICell *_bottomCell;
    
    float _previousGrowingCellHight;
}

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@end

@implementation ThirdVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _dataArray      = @[@"The Beatles", @"Pink Floyd", @"The Rolling Stones", @"The Doors", @"Led Zepellin", @"Dire Straits", @"The Strokes", @"Velvet undeground", @"Deep purple", @"The Beatles", @"Pink Floyd", @"The Rolling Stones", @"The Doors", @"Led Zepellin", @"Dire Straits", @"The Strokes", @"Velvet undeground", @"Deep purple", @"The Beatles", @"Pink Floyd", @"The Rolling Stones", @"The Doors", @"Led Zepellin", @"Dire Straits", @"The Strokes", @"Velvet undeground", @"Deep purple"];
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

    
    //_growingCellHight = [self growingCellHightForYPosition:CELL_HIGH_BIG];
    float height = CELL_HIGH_BIG*2 + 100 + CELL_HIGH*_dataArray.count + (self.view.frame.size.height - CELL_HIGH_BIG);
    _scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
    
    [self fillFirstScreen];
    
    _topCell = _topVisibleCell = _scrollingCells[0];
    _growingCell = _scrollingCells[1];
    _previousGrowingCellHight = _growingCell.frame.size.height;
    _bottomCell = _scrollingCells.lastObject;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - ScrollView managing

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //[self checkLimits];
    [self growingCellManaging];
    
    
}

- (void)checkLimits {
    
    DICell *cell;
    float cellOriginY;
    float cellHight;
    
    //NSLog(@"%f", _scrollView.contentOffset.y);
    //NSLog(@"%f", _scrollView.frame.size.height);
    
    //top limit
    float topLimitY = _scrollView.contentOffset.y - HIGHT_LIMIT;
    cell = (DICell *)_scrollingCells.firstObject;
    cellOriginY = cell.frame.origin.y;
    cellHight = cell.frame.size.height;
    if (cellOriginY > topLimitY)
        [self addTopCell];
    if (cellOriginY + cellHight < topLimitY)
        [self removeTopCell];
    
    //bottom limit
    float bottomLimitY = _scrollView.contentOffset.y + _scrollView.frame.size.height + HIGHT_LIMIT;
    cell = (DICell *)_scrollingCells.lastObject;
    cellOriginY = cell.frame.origin.y;
    cellHight = cell.frame.size.height;
    if (cellOriginY + cellHight < bottomLimitY)
        [self addBottomCell];
    if (cellOriginY > bottomLimitY)
        [self removeBottomCell];
}


//double deltaHeight (double origY, double height) {
//    
//    if (origY <= START_TRANSFORM_POSITION) {
//        return CELL_HIGH_BIG - CELL_HIGH;
//    }
//    else if (origY > END_TRANSFORM_POSITION) {
//        return 0.;
//    }
//    else {
//        height = height > 0 ? height : CELL_HIGH;
//        double deltaPath = fabsf(END_TRANSFORM_POSITION - START_TRANSFORM_POSITION);
//        double deltaHeight = CELL_HIGH_BIG - CELL_HIGH;
//        double ratio = deltaHeight / deltaPath;
//        double arg1 = MAX(ratio * (END_TRANSFORM_POSITION - origY), height);
//        double arg2 = MIN(ratio * (END_TRANSFORM_POSITION - origY), height);
//        double delta = arg1 - arg2;
//        if (height + delta < CELL_HIGH_BIG && height + delta > CELL_HIGH) {
//            NSLog(@"%f", delta);
//        }
//        return delta;
//    }
//}

double deltaHeight (double origY, double height) {
    
    if (origY <= END_TRANSFORM_POSITION) {
        return CELL_HIGH_BIG - CELL_HIGH;
    }
    else if (origY > END_TRANSFORM_POSITION+CELL_HIGH) {
        return 0.;
    }
    else {
        double y = END_TRANSFORM_POSITION + CELL_HIGH - origY;
        double delta = y * CELL_HIGH_BIG / CELL_HIGH - height;
        return delta;
    }
}


- (void)growingCellManaging {
    
    static float prevHeight = 0;
    
    CGRect frameInView = [_growingCell.superview convertRect:_growingCell.frame toView:self.view];
    double growingCellCoordY = frameInView.origin.y;
    
    CGRect frame = _growingCell.frame;
    double currentHight = frame.size.height;
    double origYNextCell = growingCellCoordY + currentHight;
    
    double delta = deltaHeight(origYNextCell, currentHight);
    //float deltaPath = fabsf(growingCellCoordY - START_TRANSFORM_POSITION);
    //deltaPath = deltaPath > 1 ? deltaPath : 1;
    //float deltaHeight = CELL_HIGH_BIG - currentHight;
    //float deltaOffset = _scrollView.contentOffset.y - prevOffset;
    //float delta = deltaOffset * deltaHeight / deltaPath;
    //delta = delta < deltaPath ? delta : deltaPath;

    //NSLog(@"delta = %.3f * %.3f / %.3f", (_scrollView.contentOffset.y - prevOffset), (CELL_HIGH_BIG - currentHight), (START_TRANSFORM_POSITION - growingCellCoordY));
    //NSLog(@"growingCellCoordY - %.3f", growingCellCoordY);
    //NSLog(@"deltaPath - %.3f", deltaPath);
    //NSLog(@"deltaHeight - %.3f", deltaHeight);
    //NSLog(@"deltaOffset - %.3f", deltaOffset);
    //NSLog(@"delta - %.3f", delta);
    //NSLog(@"hight - %.3f", frame.size.height);
    
    if (frame.size.height + delta < CELL_HIGH) {
        //[self setPrevCellAsGrowing];
    }
    else if (frame.size.height + delta > CELL_HIGH_BIG) {
        //[self setNextCellAsGrowing];
    }
    else {
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

//    float oldHeight = _growingCell.frame.size.height;
    
    //NSLog(@"================");
    //NSLog(@"coord - %f", growingCellCoordY);
    
    
    //float newHight = [self growingCellHightForYPosition:growingCellCoordY];
    
    
    //NSLog(@"new hight - %f", newHight);
    //NSLog(@"================");
    
    
    

//    //next cell starts changing its hight
//    if (growingCellCoordY < START_TRANSFORM_POSITION) {
//        int nextCellIndex = _growingCell.dataIndex + 1;
//        if (nextCellIndex < _scrollingCells.count)
//            _growingCell = _scrollingCells[nextCellIndex];
//    }
//    
//    //previous cell starts changing its hight
//    else if (growingCellCoordY > END_TRANSFORM_POSITION) {
//        int prevCellIndex = _growingCell.dataIndex - 1;
//        if (prevCellIndex > 0)
//            _growingCell = _scrollingCells[prevCellIndex];
//    }
//    
//    //the same cell is changing its hight
//    else {
//        float newHight = [self growingCellHightForYPosition:growingCellCoordY];
//        float delta = newHight - _previousGrowingCellHight;
//        CGRect frame = _growingCell.frame;
//        frame.origin.y -= delta;
//        frame.size.height += delta;
//        _previousGrowingCellHight = frame.size.height;
//        _growingCell.frame = frame;

//    }
    
    //prevOffset = _scrollView.contentOffset.y;
}

- (void)setNextCellAsGrowing {
    
    int nextIndex = _growingCell.dataIndex + 1;
    if (_scrollingCells.count > nextIndex) {
        _growingCell = _scrollingCells[nextIndex];
    }
}

- (void)setPrevCellAsGrowing {
    
    int prevIndex = _growingCell.dataIndex - 1;
    if (prevIndex > 0) {
        _growingCell = _scrollingCells[prevIndex];
    }
}


- (void)fillFirstScreen {
    
    double y = _scrollView.contentOffset.y;
    int cellIndex = 0;
    
    //NSLog(@"%f", SCREEN_SIZE.height);
    while (y <= (SCREEN_SIZE.height + HIGHT_LIMIT)) {
        DICell *cell = [self cellForIndex:cellIndex];
        double cellHight;
        if (cellIndex == 0)
            cellHight = CELL_HIGH_BIG;
        else if (cellIndex == 1)
            cellHight = CELL_HIGH + deltaHeight(END_TRANSFORM_POSITION+CELL_HIGH/2, CELL_HIGH);
        else
            cellHight = CELL_HIGH;
         
        CGRect frame = cell.frame;
        frame.size.height = cellHight;
        frame.origin.y = y;
        cell.frame = frame;
        [self addCell:cell atIndex:cellIndex];
        _bottomCell = cell;
        cellIndex++;
        y += cellHight;
    }
}
//
//- (float)cellHightForYOrigin:(float)yOrigin {
//
//    if (yOrigin <= START_TRANSFORM_POSITION) {
//        return CELL_HIGH_BIG;
//    }
//    else if (yOrigin <= END_TRANSFORM_POSITION) {
//        return [self growingCellHightForYPosition:yOrigin];
//    }
//    else {
//        return CELL_HIGH;
//    }
//}

- (DICell *)cellForIndex:(NSUInteger)index {
    
    DICell *cell;
    if (index >= _cellsArray.count) {
        cell = [[DICell alloc] init];
        cell.dataIndex = index;
    }
    else {
        cell = _cellsArray[index];
    }
    
    return cell;
}
//
//- (CGRect)currentScrollFrame {
//    
//    return CGRectMake(0, _scrollView.contentOffset.y, VIEW_FRAME.size.width, VIEW_FRAME.size.height);
//}

- (double)growingCellHightForYPosition:(double)yPosition {
    
    //NSLog(@"yPos - %f", yPosition);
    //NSLog(@"returning hight - %f", CELL_HIGH_BIG * (END_TRANSFORM_POSITION - yPosition)/(END_TRANSFORM_POSITION - START_TRANSFORM_POSITION));
    return CELL_HIGH_BIG * (END_TRANSFORM_POSITION - yPosition)/(END_TRANSFORM_POSITION - START_TRANSFORM_POSITION);
}


#pragma mark - Cells adding

- (void)addCell:(DICell *)cell atIndex:(int)index {
    
    [_scrollingCells insertObject:cell atIndex:index];
    [_scrollView addSubview:cell];
    NSLog(@"cell added at index - %d", index);
}

- (void)addTopCell {
    
    int topCellIndex = _topCell.dataIndex;
    if (topCellIndex > 0) {
        int index = topCellIndex - 1;
        DICell *cell = [self cellForIndex:index];
        float yOrigin = _topCell.frame.origin.y - CELL_HIGH_BIG - 1;
        CGRect frame = cell.frame;
        frame.size.height = CELL_HIGH_BIG;
        frame.origin.y = yOrigin;
        cell.frame = frame;
        [self addCell:cell atIndex:0];
        
        _topCell = cell;
    }
}

- (void)addBottomCell {
    
    int bottomCellIndex = _bottomCell.dataIndex;
    if (bottomCellIndex < _cellsArray.count-1) {
        int index = bottomCellIndex + 1;
        DICell *cell = [self cellForIndex:index];
        float yOrigin = _bottomCell.frame.origin.y + CELL_HIGH + 1;
        CGRect frame = cell.frame;
        frame.size.height = CELL_HIGH;
        frame.origin.y = yOrigin;
        cell.frame = frame;
        [self addCell:cell atIndex:_scrollingCells.count];
        
        _bottomCell = cell;
    }
}


#pragma mark - Cells removing

- (void)removeCell:(DICell *)cell {
    
    int index = [_scrollingCells indexOfObject:cell];
    [cell removeFromSuperview];
    [_scrollingCells removeObject:cell];
     NSLog(@"cell removed at index - %d", index);
}

- (void)removeTopCell {
    
    int topCellIndex = _topCell.dataIndex;
    if (topCellIndex > 0 && topCellIndex < _scrollingCells.count) {
        DICell *removingCell = _topCell;
        _topCell = _scrollingCells[topCellIndex + 1];
        [self removeCell:removingCell];
    }
}

- (void)removeBottomCell {
    
    int bottomCellIndex = _bottomCell.dataIndex;
    if (bottomCellIndex > 1) {
        DICell *removingCell = _bottomCell;
        _bottomCell = _scrollingCells[bottomCellIndex - 1];
        [self removeCell:removingCell];
    }
}


@end
