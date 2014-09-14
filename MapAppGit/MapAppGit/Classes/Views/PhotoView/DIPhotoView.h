//
//  DIPhotoView.h
//  Around About
//
//  Created by Dmitry Ivanov on 13.09.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

@protocol DIPhotoViewDelegate;


@interface DIPhotoView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, weak) id<DIPhotoViewDelegate> delegate;

@end


@protocol DIPhotoViewDelegate <NSObject>

@required
- (void)closeButtonPressed:(DIPhotoView *)photoView;

@end
