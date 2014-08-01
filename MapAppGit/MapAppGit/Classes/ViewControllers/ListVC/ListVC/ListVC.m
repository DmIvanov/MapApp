//
//  ListVC.m
//
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "ListVC.h"

#import "ListDefaults.h"
#import "DISightsManager.h"
#import "DISight.h"
#import "DICell.h"
#import "DILayout.h"
#import "DIHelper.h"

#import "DIListMapVC.h"
#import "DISightCardVC.h"
#import "DIDoubleSwipeView.h"   //for SWIPE_ZONE only


#define NATIVE_SCROLL       NO


@interface ListVC ()
{
    NSMutableArray *_dataArray;
    CGFloat _tableViewDeltaOffset;
}

@property (nonatomic, strong) UICollectionView *tableView;
@property (nonatomic) CGFloat contentHeight;

@end

@implementation ListVC


#pragma mark - Controller life cycle

- (id)init {
    
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray arrayWithArray:[[DISightsManager sharedInstance] dataArray]];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(sightStateChanged:)
                                                     name:DINOTIFICATION_SIGHT_STATE_CHANGED
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self tableViewAdd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - UICollectionView interaction

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _dataArray.count+1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger index = indexPath.item;
    
    if (index >= _dataArray.count) {
        DICell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID_2 forIndexPath:indexPath];
        return cell;
    }
    
    DICell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    cell.listVC = self;
    DISight *object = _dataArray[index];
    cell.sight = object;
    cell.index = index;
    
    [cell refreshContent];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger index = indexPath.item;
    if (index >= _dataArray.count)
        return;
    
    [_listMapController setStatusbarNavibarHidden:NO];
    DISight *object = _dataArray[index];
    DISightCardVC *sightCard = [DISightCardVC new];
    sightCard.sight = object;
    [self.listMapController.navigationController pushViewController:sightCard
                                                           animated:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static CGFloat lastOffset = 0.;
    CGFloat contentOffset = scrollView.contentOffset.y;
    _tableViewDeltaOffset = contentOffset - lastOffset;
    if (contentOffset > 0)
        [_listMapController navibarPositionManagingWithOffset:_tableViewDeltaOffset];
    
    _tableViewDeltaOffset = 0.;
    lastOffset = contentOffset;
}

- (void)tableViewReload {
    
    if (NATIVE_SCROLL)
        _tableView.contentInset = [self tableViewInset];
    else
        _contentHeight = self.contentHeight;
    
    [_tableView reloadData];
}

- (UIEdgeInsets)tableViewInset {
    
    CGFloat yInset = (CELL_HEIGHT_BIG + CELL_HEIGHT_SECOND - 2*CELL_HEIGHT) + (SCREEN_SIZE.height - CELL_HEIGHT_BIG);
    return UIEdgeInsetsMake(0, 0, yInset, 0);
}

- (CGFloat)contentHeight {
    
    CGFloat height = (_dataArray.count-1)*CELL_HEIGHT;
    return height;
}


#pragma mark - DICell actions

- (void)cellButtonAddPressed:(DICell *)cell {
    
    DISight *sight = cell.sight;
    switch (sight.sightType) {
        case SightTypeChosen:
            sight.sightType = SightTypeInteresting;
            break;
        case SightTypeInteresting:
            sight.sightType = SightTypeChosen;
            break;
        default:
            break;
    }
    
    [cell refreshContent];
}


#pragma mark - Other functions

- (UICollectionViewLayout *)collectionViewLayout {

    DILayout *layout = [DILayout new];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumInteritemSpacing:0.];
    [layout setMinimumLineSpacing:0.];
    [layout setItemSize:CGSizeMake(SCREEN_SIZE.width, CELL_HEIGHT)];

    return layout;
}

- (void)tableViewAdd {
    
    _tableView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                    collectionViewLayout:[self collectionViewLayout]];
    _tableView.delegate     = self;
    _tableView.dataSource   = self;
    _tableView.backgroundColor = [UIColor colorWithRed:240./255 green:240./255 blue:240./255 alpha:1.]; //grey
    //_tableView.backgroundColor = [UIColor colorWithRed:40./255 green:87./255 blue:149./255 alpha:1.];   //blue
    _tableView.bounces = NO;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
   
    _contentHeight = self.contentHeight;
    
    [_tableView registerClass:[DICell class] forCellWithReuseIdentifier:CELL_ID];
    UINib *nib = [UINib nibWithNibName:@"DICell" bundle:nil];
    [_tableView registerNib:nib forCellWithReuseIdentifier:CELL_ID];
    nib = [UINib nibWithNibName:@"DICell2" bundle:nil];
    [_tableView registerNib:nib forCellWithReuseIdentifier:CELL_ID_2];
    
    [self.view addSubview:_tableView];
    
    if (NATIVE_SCROLL) {
        _tableView.contentInset = [self tableViewInset];
    }
    else {
        _tableView.scrollEnabled = NO;
        UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(recognized:)];
        recognizer.delegate = self;
        [_tableView addGestureRecognizer:recognizer];
    }
}

- (void)sightStateChanged:(NSNotification *)notification {
    
    DISight *notifSight = notification.userInfo[@"sight"];
    if (notifSight) {
        NSArray *cells = [_tableView visibleCells];
        for (DICell *cell in cells) {
            if (cell.sight == notifSight) {
                [cell refreshContent];
                break;
            }
        }
    }
}


#pragma mark - UIGestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    
    CGFloat xLoc = [touch locationInView:self.view].x;
    if (xLoc < SWIPE_ZONE)
        return NO;
    else
        return YES;
}

- (void)recognized:(UIPanGestureRecognizer *)recognizer {
    
    static CGPoint point;
    CGFloat coef = 0.2;
    CGPoint currentPoint = [recognizer translationInView:self.view];
    CGPoint offset = _tableView.contentOffset;
    //DLog(@"offset - %f, height - %f", offset.y, _contentHeight);
    static CGFloat delta;
    CGFloat velocity = [recognizer velocityInView:_tableView].y;
    //DLog(@"%f", velocity);
    if (fabs(velocity) >= 500)
        coef = 1.0;
    //DLog(@"coef - %f", coef);
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            point = currentPoint;
            break;
         
        case UIGestureRecognizerStateChanged:
            
            //DLog(NSStringFromCGPoint(currentPoint));
            delta = currentPoint.y - point.y;
            delta *= coef;
            //if (fabs(delta) >= 0.5) {
                offset.y -= delta;
                if (offset.y < 0)
                    offset.y = 0;
                if (offset.y > _contentHeight)
                    offset.y = _contentHeight;
                _tableView.contentOffset = offset;
                point = currentPoint;
            //}
            break;
            
        case UIGestureRecognizerStateEnded:
        default:
            break;
    }
}

@end
