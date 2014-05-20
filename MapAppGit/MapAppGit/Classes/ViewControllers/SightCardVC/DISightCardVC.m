//
//  DISightCardVC.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightCardVC.h"

#import "DISight.h"
#import "DIBarButton.h"

@interface DISightCardVC ()

@property (nonatomic, strong) IBOutlet UITextView *textView;
@property (nonatomic, strong) IBOutlet UIWebView *webView;
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
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"html" ofType:@"txt"];
    NSString *string = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [_webView loadHTMLString:string baseURL:[[NSBundle mainBundle] bundleURL]];
    _webView.delegate = self;
    
    //self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIImage *)imageForNavibar {
    
    return [[UIImage imageNamed:@"info_buttonbar_bottom_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 20, 0)];
}

- (DIBarButton *)customizeBarButton:(DIBarButton *)button {
    
    if (button.sideMode == SideModeLeft) {
        [button setImage:[UIImage imageNamed:@"info_tittlebar_button_back"] forState:UIControlStateNormal];
        return button;
    }
    else if (button.sideMode == SideModeRight) {
        [button setImage:[UIImage imageNamed:@"info_tittlebar_button_add_unpressed"] forState:UIControlStateNormal];
        return button;
    }
    
    return nil;
}

- (void)barButtonLeftPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)barButtonRightPressed {
    
}

@end
