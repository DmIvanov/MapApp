//
//  DISightCardVC.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightCardVC.h"

#import <objc/runtime.h>

#import "DISight.h"
#import "DIBarButton.h"
#import "DIHeaderView.h"
#import "DICardTVItem.h"

#define CELL_ID             @"cellID"
#define HEADER_ID           @"headerID"
#define HEADER_HEIGHT       76.


@interface DISightCardVC ()
{
    NSMutableArray *_datasource;
    NSMutableDictionary *_tvDataDict;
    UIWebView *_webView;
}

@property (nonatomic, strong) IBOutlet UIView *mainInfoView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

@property (nonatomic, strong) NSDictionary *tvProperties;

@end

@implementation DISightCardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _datasource = [NSMutableArray arrayWithCapacity:20];
        for (NSUInteger i=0; i < 10; i++) {
            DICardTVItem *item = [DICardTVItem new];
            [_datasource addObject:item];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.image = _image;
    
    UINib *header = [UINib nibWithNibName:@"DIHeaderView" bundle:nil];
    [_tableView registerNib:header forHeaderFooterViewReuseIdentifier:HEADER_ID];
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
    
    return _datasource.count + 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 1;
            break;
            
        default: {
            DICardTVItem *item = _datasource[section-1];
            return item.opened ? 1 : 0;
        }
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    switch (section) {
        case 0:
            return 0.1;
            break;
            
        default:
            return HEADER_HEIGHT;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = indexPath.section;
    switch (section) {
        case 0:
            return _mainInfoView.frame.size.height;
            break;
            
        default: {
            CGFloat ret = _webView ? _webView.frame.size.height : 400;
            return ret;
        }
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
        if (!cell) {
            cell = [UITableViewCell new];
            if (!_webView) {
                _webView = [UIWebView new];
                _webView.frame = CGRectMake(0, 0, 320, 1);
                _webView.scrollView.scrollEnabled = NO;
                NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"html" ofType:@"txt"];
                NSString *string = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
                [_webView loadHTMLString:string baseURL:[[NSBundle mainBundle] bundleURL]];
                _webView.delegate = self;
            }
            [cell.contentView addSubview:_webView];

            cell.contentView.backgroundColor = [UIColor yellowColor];
        }
    }
    cell.userInteractionEnabled = NO;
    
    return cell;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    [_tableView reloadData];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (section == 0) {
        UIView *header = [[UIView alloc] init];
        return header;
    }
    
    else {
        DIHeaderView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:HEADER_ID];
        header.delegate = self;
        header.section = section;
        DICardTVItem *item = _datasource[section-1];
        header.item = item;
        return header;
    }
}


#pragma mark - Other functions




#pragma mark - DIHeaderView delegate

- (void)headerTapped:(DIHeaderView *)header {
    
    NSUInteger section = header.section;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    NSArray *indexes = @[indexPath];
    DICardTVItem *item = header.item;
    
    [_tableView beginUpdates];
    if (item.opened) {
        [_tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
    }
    else {
        [_tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationTop];
    }
    item.opened = !item.opened;
    [_tableView endUpdates];
}


#pragma mark - Setters & getters



@end
