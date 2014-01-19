//
//  DICell.h
//  TableV
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICell : UIView

@property (nonatomic) NSUInteger dataIndex;
@property (nonatomic, strong) NSString *titleString;

- (void)setCellHight:(float)hight;
- (void)moveToY:(float)y;
- (void)moveToDeltaY:(float)deltaY;

@end
