//
//  DIPhotoView.m
//  Around About
//
//  Created by Dmitry Ivanov on 13.09.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIPhotoView.h"

@interface DIPhotoView() <UIScrollViewDelegate>

@property (nonatomic, strong) UIImageView *imgView;
@property (nonatomic, strong) UIScrollView *scrollView;

@end

@implementation DIPhotoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (!self)
        return nil;
    
    [self initialization];
    
    return self;
}

- (void)initialization {
    
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.9];
}

- (void)drawRect:(CGRect)rect
{
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _imgView = [[UIImageView alloc] initWithImage:_image];
    _scrollView.contentSize = _image.size;
    CGFloat minScale = SCREEN_SIZE.width/_image.size.width;
    _scrollView.minimumZoomScale = minScale;
    _scrollView.maximumZoomScale = 1;
    _scrollView.delegate = self;
    
    [_scrollView addSubview:_imgView];
    [self addSubview:_scrollView];
    [self setCloseButton];
    
    _scrollView.zoomScale = minScale;
}

- (void)setCloseButton {
    
    UIButton *buttonClose = [[UIButton alloc] initWithFrame:CGRectMake(10, 30, 80, 30)];
    [buttonClose addTarget:self
                    action:@selector(buttonClosePressed:)
          forControlEvents:UIControlEventTouchUpInside];
    [buttonClose setTitle:DILocalizedString(@"close")
                 forState:UIControlStateNormal];
    [buttonClose setTitleColor:[UIColor whiteColor]
                      forState:UIControlStateNormal];
    [buttonClose setTitleColor:[UIColor lightGrayColor]
                      forState:UIControlStateHighlighted];
    [buttonClose setTitleShadowColor:[UIColor blackColor]
                            forState:UIControlStateNormal];
    buttonClose.titleLabel.shadowOffset = CGSizeMake(1, 1);
    [self addSubview:buttonClose];
}

- (void)buttonClosePressed:(UIButton *)button {
    
    [_delegate closeButtonPressed:self];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return _imgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    
    CGFloat offsetX = MAX((scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5, 0.0);
    CGFloat offsetY = MAX((scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5, 0.0);
    
    _imgView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                 scrollView.contentSize.height * 0.5 + offsetY);
}

@end
