//
//  DICollectionView.h
//  Around About
//
//  Created by Dmitry Ivanov on 02.08.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DICollectionView : UICollectionView

//ListVC trying to change (adjust) contentOffset while its view is disappearing
//even if automaticallyAdjustsScrollViewInsets == NO
//so we prevent this situation with this property
@property (nonatomic) BOOL noOffsetChanging;

@end
