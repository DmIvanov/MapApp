//
//  ListVC.h
//  
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DICell;

@class DIListMapVC;

@interface ListVC : UIViewController
    <UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIGestureRecognizerDelegate>

@property (nonatomic, strong) DIListMapVC *listMapController;

//for DICell
- (void)cellButtonAddPressed:(DICell *)cell;

@end
