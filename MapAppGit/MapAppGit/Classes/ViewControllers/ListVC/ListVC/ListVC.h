//
//  ListVC.h
//  
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "DICell.h"

@class DIListMapVC;

@interface ListVC : UIViewController
    <UICollectionViewDelegate,
    UICollectionViewDataSource>

@property (nonatomic, strong) DIListMapVC *listMapController;

@end
