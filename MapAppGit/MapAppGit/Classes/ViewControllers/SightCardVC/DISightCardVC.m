//
//  DISightCardVC.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightCardVC.h"

//#import <objc/runtime.h>

#import "DISightExtended.h"
#import "DIBarButton.h"
#import "DIHeaderView.h"
#import "DICardTVItem.h"

#define CELL_ID             @"cellID"
#define HEADER_ID           @"headerID"
#define HEADER_HEIGHT       76.


#define TITLE_VIEW_FRAME            CGRectMake(0, 20, 280, 44)
#define TITLE_LABEL_FRAME           CGRectMake(8, 10, 260, 20)
#define TITLE_FONT                  [UIFont boldSystemFontOfSize:18.]


@interface DISightCardVC ()
{
    NSMutableArray *_datasource;
}

@property (nonatomic, strong) IBOutlet UIView *mainInfoView;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UILabel *firstLabel;

@end

@implementation DISightCardVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _datasource = [NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _imageView.image = [UIImage imageWithData:_sight.originalSight.avatarData];
    //self.navigationItem.title = _sight.originalSight.name;
    
    UIView *titleView = [[UIView alloc] initWithFrame:TITLE_VIEW_FRAME];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:TITLE_LABEL_FRAME];
    titleLabel.text = _sight.originalSight.name;
    titleLabel.textColor = [UIColor colorWithRed:40./255
                                           green:87./255
                                            blue:149./255
                                           alpha:1.];
    titleLabel.font = TITLE_FONT;
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    
    UINib *header = [UINib nibWithNibName:@"DIHeaderView" bundle:nil];
    [_tableView registerNib:header forHeaderFooterViewReuseIdentifier:HEADER_ID];
    
    _firstLabel.text = _sight.originalSight.name;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
}


#pragma mark - Navibar customizing

- (UIImage *)imageForNavibar {
    
    return [[UIImage imageNamed:@"info_buttonbar_bottom_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 20, 0)];
}

- (DIBarButton *)customizeBarButton:(DIBarButton *)button {
    
    if (button.sideMode == SideModeLeft) {
        [button setImage:[UIImage imageNamed:@"info_tittlebar_button_back"] forState:UIControlStateNormal];
        button.insets = UIEdgeInsetsMake(0, 18, 0, 0);
        return button;
    }
    else if (button.sideMode == SideModeRight) {
        [button setImage:[UIImage imageNamed:@"info_tittlebar_button_add_unpressed"] forState:UIControlStateNormal];
        button.insets = UIEdgeInsetsMake(0, 0, 0, 18);
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
            DICardTVItem *item = _datasource[section-1];
            CGFloat ret = item.webView ? item.webView.frame.size.height : 1;
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
        }

        DICardTVItem *item = _datasource[section - 1];
        if (!item.webView)
            [self setWebViewForItem:item];
        [cell.contentView addSubview:item.webView];
    }
    cell.userInteractionEnabled = NO;
    
    return cell;
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
        [header refreshContent];
        return header;
    }
}


#pragma mark - UIWebViewDelegate methods

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    [_tableView reloadData];
}


#pragma mark - DIHeaderView delegate

- (void)headerTapped:(DIHeaderView *)header {
    
    NSUInteger section = header.section;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    NSArray *indexes = @[indexPath];
    DICardTVItem *item = header.item;
    
    [_tableView beginUpdates];
    if (item.opened) {
        [_tableView deleteRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    }
    else {
        [_tableView insertRowsAtIndexPaths:indexes withRowAnimation:UITableViewRowAnimationFade];
    }
    item.opened = !item.opened;
    [_tableView endUpdates];
    
    [header refreshContent];
}




#pragma mark - Other functions

- (void)setWebViewForItem:(DICardTVItem *)item {
    
    UIWebView *webView = [UIWebView new];
    webView.scrollView.scrollEnabled = NO;
    webView.frame = CGRectMake(0, 0, SCREEN_SIZE.width, 1);
    webView.delegate = self;
    [webView loadHTMLString:item.htmlString baseURL:[[NSBundle mainBundle] bundleURL]];
    item.webView = webView;
}

- (void)createPropertyList {
    
    for (NSString *key in [self listProperties]) {
        NSString *htmlValue = [_sight.originalSight valueForKey:key];
        if (htmlValue) {
            DICardTVItem *newItem = [DICardTVItem new];
            newItem.keyString = key;
            newItem.htmlString = htmlValue;
            [_datasource addObject:newItem];
        }
    }
}


#pragma mark - Setters & getters

- (NSArray *)listProperties {

    return @[@"listAbout",
             @"listHistory",
             @"listNow",
             @"listContacts",
             @"listInteresting"];
}

- (void)setSight:(DISightExtended *)sight {
    
    _sight = sight;
    [self createPropertyList];
}


@end
