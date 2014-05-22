//
//  DISightCardVC.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightCardVC.h"

#import "DIDefaults.h"

#import "DISight.h"
#import "DIBarButton.h"

#define CELL_ID     @"cellID"


@interface DISightCardVC ()
{
    NSArray *_datasource;
}

@property (nonatomic, strong) IBOutlet UIView *mainInfoView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@end

@implementation DISightCardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"html" ofType:@"txt"];
//    NSString *string = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    [_webView loadHTMLString:string baseURL:[[NSBundle mainBundle] bundleURL]];
//    _webView.delegate = self;
    
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


#pragma mark - Navibar customizing

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


#pragma mark - TableView affairs

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 10;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 0.1;
            break;
            
        default:
            return 30;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = indexPath.section;
    switch (section) {
        case 0:
            return _mainInfoView.frame.size.height;
            break;
            
        default:
            return 0.1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = indexPath.section;
    UITableViewCell *cell;
    if (section == 0) {
        cell = [UITableViewCell new];
        [cell.contentView addSubview:_mainInfoView];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
        if (!cell)
            cell = [UITableViewCell new];
    }
    
    return cell;
}



@end
