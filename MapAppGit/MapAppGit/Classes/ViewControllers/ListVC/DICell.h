//
//  DICell.h
//  TableV
//
//  Created by Dmitry Ivanov on 19.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DICell;


@protocol DICellDelegate <NSObject>

@required
- (void)cellDidSelect:(DICell *)cell;

@end


@interface DICell : UIControl

@property (nonatomic, weak) id <DICellDelegate> delegate;

@property (nonatomic) NSUInteger dataIndex;

@property (nonatomic, strong) NSString *titleString;
@property (nonatomic, strong) NSString *description;
@property (nonatomic, strong) NSData *imageData;

@end
