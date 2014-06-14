//
//  DISightCardVC.h
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIBaseVC.h"

#import "DIHeaderView.h"

@class DISightExtended;

@interface DISightCardVC : DIBaseVC
    <UITableViewDelegate,
    UITableViewDataSource,
    UIWebViewDelegate,
    DIHeaderViewDelegate>

@property (nonatomic, strong) DISightExtended *sight;

@end
