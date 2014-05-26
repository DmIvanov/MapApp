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


@interface ListVC ()
{
    NSMutableArray *_dataArray;
    CGFloat _tableViewDeltaOffset;
}

@property (nonatomic, strong) UICollectionView *tableView;

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
    
    [self tableViewAdd];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UICollectionView interation

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
    cell.image = [self randomSpbImage];
    [cell refreshContent];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger index = indexPath.item;
    DISight *object = _dataArray[index];
    DISightCardVC *sightCard = [DISightCardVC new];
    sightCard.sight = object;
    //DICell *cell = (DICell *)[collectionView cellForItemAtIndexPath:indexPath];
    sightCard.image = [self randomSpbImage];
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


#pragma mark - DICell actions

- (void)cellButtonAddPressed:(DICell *)cell {
    
    NSUInteger index = [_tableView indexPathForCell:cell].item;
    DISight *sight = _dataArray[index];
    sight.sightType = SightTypeChosen;
    [cell refreshContent];
}


#pragma mark - Other functions

- (UICollectionViewLayout *)collectionViewLayout {
    
    DILayout *layout = [DILayout new];
    //UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
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
    _tableView.contentInset = [self tableViewInset];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.bounces = NO;
    
    [_tableView registerClass:[DICell class] forCellWithReuseIdentifier:CELL_ID];
    UINib *nib = [UINib nibWithNibName:@"DICell" bundle:nil];
    [_tableView registerNib:nib forCellWithReuseIdentifier:CELL_ID];
    nib = [UINib nibWithNibName:@"DICell2" bundle:nil];
    [_tableView registerNib:nib forCellWithReuseIdentifier:CELL_ID_2];
    
    [self.view addSubview:_tableView];
}

- (void)tableViewReload {
    
    _tableView.contentInset = [self tableViewInset];
    [_tableView reloadData];
}

- (UIEdgeInsets)tableViewInset {
    
    CGFloat yInset = (CELL_HEIGHT_BIG + CELL_HEIGHT_SECOND - 2*CELL_HEIGHT) + (SCREEN_SIZE.height - CELL_HEIGHT_BIG);
    return UIEdgeInsetsMake(0, 0, yInset, 0);
}


- (UIImage *)randomSpbImage {
    
    NSString *name = [NSString stringWithFormat:@"spb%@.jpg", @([DIHelper randomValueBetween:1 and:5])];
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

@end
