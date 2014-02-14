//
//  DIMapScrollVC.m
//  
//
//  Created by Dmitry Ivanov on 08.02.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIMapScrollVC.h"

#import "DICloudeMadeManager.h"
#import "DIDefaults.h"
#import "DIHelper.h"

#import "RouteMe.h"


@interface DIMapScrollVC()
{
    CGPoint _lastOffset;
}

@property (nonatomic, strong) DIMapSourceManager *mapSourceManager;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) RMMapContents *mapContents;

@end


@implementation DIMapScrollVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _mapSourceManager = [[DICloudeMadeManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [_mapSourceManager setMapSourceWithMapContents:_mapContents];

    [self setContentOffset];
    if (!_mapContents) {
        _mapContents = [[RMMapContents alloc] initWithView:self.view screenScale:0.];
    }
    
    _scrollView.delegate = self;
    [self setMapZoom:[DIHelper initialZoom]];
    
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 5.;
}

- (void)viewWillLayoutSubviews {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setMapZoom:(NSUInteger)newMapZoom {
    
    if (newMapZoom < [DIHelper minZoom] || newMapZoom > [DIHelper maxZoom])
        return;
    
    CGSize zoomSize = [[DIHelper sharedInstance] viewSizeForZoom:newMapZoom];
    _scrollView.contentSize = zoomSize;
}

- (void)setContentOffset {
    
    [self setContentOffsetForTileRect:[_mapContents tileBounds]];
}

- (void)setContentOffsetForTileRect:(RMTileRect)tileRect {
    
    CGPoint offset = [[DIHelper sharedInstance] contentOffsetForTileRect:tileRect];
    _scrollView.contentOffset = offset;
}


#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    //NSLog(NSStringFromCGPoint(scrollView.contentOffset));
    
    CGSize delta = CGSizeMake(_lastOffset.x - scrollView.contentOffset.x, _lastOffset.y - scrollView.contentOffset.y);

    [_mapContents moveBy:delta];
    
    _lastOffset = scrollView.contentOffset;
}


@end
