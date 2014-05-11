//
//  DISightCardVC.h
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DISight;

@interface DISightCardVC : UIViewController <UITextViewDelegate>

@property (nonatomic, strong) DISight *sight;
@property (nonatomic, strong) UIImage *image;

@end
