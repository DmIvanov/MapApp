//
//  DISightCardVC.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightCardVC.h"

#import "DISight.h"

@interface DISightCardVC ()

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIScrollView *scroll;

@end

@implementation DISightCardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _textView.delegate = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (_sight) {
        _textView.text = [NSString stringWithFormat:@"HISTORY\n%@", _sight.history];
        self.navigationItem.title = _sight.name;
    }
    _scroll.contentSize = CGSizeMake(320, 1000);
    _imageView.image = _image;
    //self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
