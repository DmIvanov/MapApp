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
#import "DISightsManager.h"
#import "DISight.h"
#import "DICell.h"
#import "DILayout.h"
#import "DIHelper.h"

#import "DIMapController.h"


#define VIEW_FRAME                  self.view.frame
#define NAVIBAR_DELTA               44.
#define NAVIBAR_FRAME               CGRectMake(0, 20, SCREEN_SIZE.width, NAVIBAR_DELTA);


@interface ListVC ()
{
    NSMutableArray *_dataArray;
    UINavigationBar *_naviBar;
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


#pragma mark - UICollectionView interation

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return _dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger index = indexPath.item;
    DICell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    UIColor *color;
    int i = index%7;
    switch (i) {
        case 0:
            color = COLOR1;
            break;
        case 1:
            color = COLOR2;
            break;
        case 2:
            color = COLOR3;
            break;
        case 3:
            color = COLOR4;
            break;
        case 4:
            color = COLOR5;
            break;
        case 5:
            color = COLOR6;
            break;
        case 6:
            color = COLOR0;
            break;
        default:
            color = [UIColor lightGrayColor];
            break;
    }
    cell.backgroundColor = color;
    DISight *object = _dataArray[index];
    cell.label.text = [NSString stringWithFormat:@"%ld - %@", (unsigned long)index, object.name];
    cell.imageView.image = [self randomSpbImage];
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    static CGFloat lastOffset = 0.;
    CGFloat contentOffset = scrollView.contentOffset.y;
    _tableViewDeltaOffset = contentOffset - lastOffset;
    
    if (contentOffset > 0)
        [self navibarPositionManaging];
    
    _tableViewDeltaOffset = 0.;
    lastOffset = contentOffset;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
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


#pragma mark - Actions

- (void)barButtonActionTapped:(id)sender {
    
    BOOL hidden = [UIApplication sharedApplication].statusBarHidden;
    [self setStatusBarHiddenWithStaticFrames:!hidden];
}


#pragma mark - Other functions

- (void)navibarPositionManaging {
    
    CGFloat navibarOffset = 0.;
    CGRect frame = _naviBar.frame;
    
    //navibar frame changing
    if (_tableViewDeltaOffset > 0) {
        if (frame.origin.y <= 20. && _naviBar.frame.origin.y > -NAVIBAR_DELTA) {
            [self setStatusBarHiddenWithStaticFrames:YES];
            navibarOffset = (fabs(-NAVIBAR_DELTA - frame.origin.y) >= _tableViewDeltaOffset) ? _tableViewDeltaOffset : fabs(-NAVIBAR_DELTA - frame.origin.y);
        }
        else
            return;
    }
    else {
        if (frame.origin.y < 20.) {
            [self setStatusBarHiddenWithStaticFrames:NO];
            navibarOffset = (frame.origin.y - _tableViewDeltaOffset <= 20.) ? _tableViewDeltaOffset : (frame.origin.y - 20.);
        }
        else
            return;
    }
    frame.origin.y -= navibarOffset;
    _naviBar.frame = frame;
}

- (void)navibarNewFrame:(CGRect)frame {
    
    double scrollViewDelta = self.view.frame.origin.y - (_naviBar.frame.origin.y + _naviBar.frame.size.height);
    if (scrollViewDelta) {
        CGRect scrollFrame = self.view.frame;
        scrollFrame.origin.y -= scrollViewDelta;
        scrollFrame.size.height += scrollViewDelta;
        self.view.frame = scrollFrame;
    }
}

- (UICollectionViewLayout *)collectionViewLayout {
    
    DILayout *layout = [DILayout new];
    //UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
    [layout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [layout setMinimumInteritemSpacing:0.];
    [layout setMinimumLineSpacing:0.];
    [layout setItemSize:CGSizeMake(320, 40)];
    
    return layout;
}

- (void)tableViewAdd {
    
    _tableView = [[UICollectionView alloc] initWithFrame:self.view.frame
                                    collectionViewLayout:[self collectionViewLayout]];
    _tableView.delegate     = self;
    _tableView.dataSource   = self;
    _tableView.contentInset = [self tableViewInset];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.bounces = NO;
    
    [_tableView registerClass:[DICell class] forCellWithReuseIdentifier:CELL_ID];
    UINib *nib = [UINib nibWithNibName:@"DICell" bundle:nil];
    [_tableView registerNib:nib forCellWithReuseIdentifier:CELL_ID];
    
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

- (void)setStatusBarHiddenWithStaticFrames:(BOOL)hidden {
    
    if ([UIApplication sharedApplication].statusBarHidden == hidden)
        return;
    
    CGRect frame = self.view.frame;
    [[UIApplication sharedApplication] setStatusBarHidden:hidden withAnimation:UIStatusBarAnimationNone];
    self.view.frame = frame;
    _naviBar.frame = NAVIBAR_FRAME;
}

- (UIImage *)randomSpbImage {
    
    NSString *name = [NSString stringWithFormat:@"spb%@.jpg", @([DIHelper randomValueBetween:1 and:5])];
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

@end
