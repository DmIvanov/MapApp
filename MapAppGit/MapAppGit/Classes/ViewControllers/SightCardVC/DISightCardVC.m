//
//  DISightCardVC.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightCardVC.h"

#import "NSString+RectForSize.h"

#import "DISightsManager.h"
#import "DISight.h"
#import "DIBarButton.h"
#import "DIHeaderView.h"
#import "DICardTVItem.h"

#define CELL_ID                         @"cellID"
#define HEADER_ID                       @"headerID"
#define HEADER_HEIGHT                   76.
#define SCHEDULE_ROW_HEIGHT             30.

#define TITLE_VIEW_FRAME            CGRectMake(0, 20, 280, 44)
#define TITLE_LABEL_FRAME           CGRectMake(8, 10, 260, 20)
#define TITLE_FONT                  [UIFont boldSystemFontOfSize:18.]


@interface DISightCardVC ()
{
    NSMutableArray *_datasource;
    NSIndexPath *_loadingWebViewIndexPath;
    NSArray *_sevenDaysWH;
    NSDictionary *_todayWH;
    NSString *_displayedToday;
}

@property (nonatomic, strong) IBOutlet UIView       *mainInfoView;
@property (nonatomic, strong) IBOutlet UITableView  *tableView;
@property (nonatomic, strong) IBOutlet UIImageView  *imageViewPicture;
@property (nonatomic, strong) IBOutlet UILabel      *firstLabel;

@property (nonatomic, strong) IBOutlet UIImageView  *imageViewPrice;
@property (nonatomic, strong) IBOutlet UILabel      *labelPrice;
@property (nonatomic, strong) IBOutlet UIImageView  *imageViewWorkHours;
@property (nonatomic, strong) IBOutlet UILabel      *labelWorkHours;
@property (nonatomic, strong) IBOutlet UIImageView  *imageRubles;

@property (nonatomic, strong) IBOutlet UILabel      *labelShortDescr;

@property (nonatomic, strong) UIView *scheduleListView;

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
        
    UIView *titleView = [[UIView alloc] initWithFrame:TITLE_VIEW_FRAME];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:TITLE_LABEL_FRAME];
    titleLabel.text = DILocalizedString(@"sightCardNavibarName");
    titleLabel.textColor = [UIColor colorWithRed:40./255
                                           green:87./255
                                            blue:149./255
                                           alpha:1.];
    titleLabel.font = TITLE_FONT;
    [titleView addSubview:titleLabel];
    self.navigationItem.titleView = titleView;
    
    UINib *header = [UINib nibWithNibName:@"DIHeaderView" bundle:nil];
    [_tableView registerNib:header forHeaderFooterViewReuseIdentifier:HEADER_ID];
    
    [self adjustMainHeader];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO
                                                 animated:YES];
    }
    [self workHoursConfig];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    [self workHoursConfig];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark -

- (void)adjustMainHeader {
    
    NSString *shortDescr = _sight.shortDescr;
    _labelShortDescr.text = shortDescr;
    _tableView.tableHeaderView = _mainInfoView;
    _firstLabel.text = _sight.name;
    _imageViewPicture.image = [UIImage imageWithData:_sight.avatarData];
}

- (void)adjustIconView:(UIView *)iconView {
    
    CGFloat imageSize = 24.;
    CGFloat gap = 12.;
    CGFloat iconOrig = 10.;
    CGFloat xCoord = 0;
    
    UIImage *photoImage;
    switch ([_sight.foto integerValue]) {
        case 0:
            photoImage = [UIImage imageNamed:@"ico_photo_no"];
            break;
        case 1:
            photoImage = [UIImage imageNamed:@"ico_photo"];
            break;
        case 2:
            photoImage = [UIImage imageNamed:@"ico_photo_pay"];
            break;
        case 3:
            photoImage = [UIImage imageNamed:@"ico_photo_free"];
            break;
        default:
            photoImage = [UIImage imageNamed:@"ico_photo"];
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:photoImage];
    imageView.frame = CGRectMake(xCoord, iconOrig, imageSize, imageSize);
    [iconView addSubview:imageView];
    xCoord += (imageSize + gap);
    
    UIImage *wifiImage;
    BOOL noImage = NO;
    switch ([_sight.wifi integerValue]) {
        case 0:
            photoImage = [UIImage imageNamed:@""];
            noImage = YES;
            break;
        case 1:
            wifiImage = [UIImage imageNamed:@"ico_wifi"];
            break;
        case 2:
            photoImage = [UIImage imageNamed:@"ico_wifi_pay"];
            break;
        case 3:
            photoImage = [UIImage imageNamed:@"ico_wifi_free"];
            break;
        default:
            wifiImage = [UIImage imageNamed:@"ico_wifi"];
    }
    if (!noImage) {
        imageView = [[UIImageView alloc] initWithImage:wifiImage];
        imageView.frame = CGRectMake(xCoord, iconOrig, imageSize, imageSize);
        [iconView addSubview:imageView];
        xCoord += (imageSize + gap);
    }
    
    UIImage *audioImage;
    noImage = NO;
    switch ([_sight.audioguide integerValue]) {
        case 0:
            photoImage = [UIImage imageNamed:@""];
            noImage = YES;
            break;
        case 1:
            audioImage = [UIImage imageNamed:@"ico_audioguide"];
            break;
        case 2:
            photoImage = [UIImage imageNamed:@"ico_audioguide_pay"];
            break;
        case 3:
            photoImage = [UIImage imageNamed:@"ico_audioguide_free"];
            break;
        default:
            audioImage = [UIImage imageNamed:@"ico_audioguide"];
    }
    if (!noImage) {
        imageView = [[UIImageView alloc] initWithImage:audioImage];
        imageView.frame = CGRectMake(xCoord, iconOrig, imageSize, imageSize);
        [iconView addSubview:imageView];
        xCoord += (imageSize + gap);
    }
}

- (void)workHoursConfig {
    
    NSDate *today = [NSDate date];
    NSString *todayString = [[DISightsManager sharedInstance] insideDateStringFromDate:today];
    if (![todayString isEqualToString:_displayedToday]) {
        _todayWH = [_sight todayWHDict];
        if (_todayWH) {
            _displayedToday = todayString;
            _sevenDaysWH = [_sight sevenDaysWH];
            [self refreshDateTimeInfo];
        }
    }
}

- (void)refreshDateTimeInfo {
    
    NSString *price;
    if (_sight.isFreeToday) {
        price = DILocalizedString(@"sightCardFree");
        _imageRubles.hidden = YES;
    }
    else {
        CGFloat priceFloat = [_sight.price floatValue];
        price = [NSString stringWithFormat:@"%lu", (unsigned long)priceFloat];
        _imageRubles.hidden = NO;
    }
    CGSize size = [price rectForSize:_labelPrice.frame.size
                                font:_labelPrice.font
                       lineBreakMode:NSLineBreakByWordWrapping].size;
    _labelPrice.text = price;
    CGRect frame = _labelPrice.frame;
    frame.size = size;
    _labelPrice.frame = frame;
    CGFloat xMax = CGRectGetMaxX(frame);
    frame = _imageRubles.frame;
    frame.origin.x = xMax + 6;
    _imageRubles.frame = frame;
    
    if ([_sight isClosedNow]) {
        _labelWorkHours.text = DILocalizedString(@"sightCardClosedToday");
        _imageViewWorkHours.image = [UIImage imageNamed:@"list_status_unavailable"];
    }
    else {
        NSDate *timeOpen = _todayWH[@"timeOpen"];
        NSDate *timeClose = _todayWH[@"timeClose"];
    
        NSString *displayedHours = [[DISightsManager sharedInstance] openCloseStringFromDateOpen:timeOpen
                                                                                   dateClose:timeClose];
        _labelWorkHours.text = displayedHours;
        _imageViewWorkHours.image = [UIImage imageNamed:@"list_status_worktime"];
    }
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
        [button setImage:[_sight imageForNavibarButton] forState:UIControlStateNormal];
        button.insets = UIEdgeInsetsMake(0, 0, 0, 18);
        return button;
    }
    
    return nil;
}

- (void)barButtonLeftPressed {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)barButtonRightPressed {
 
    switch (_sight.sightType) {
        case SightTypeChosen:
            _sight.sightType = SightTypeInteresting;
            break;
        case SightTypeInteresting:
            _sight.sightType = SightTypeChosen;
            break;
        default:
            break;
    }
    [self customizeBarButton:self.rightBarButton];
}


#pragma mark - TableView affairs

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return _datasource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    DICardTVItem *item = _datasource[section];
    return item.opened ? 1 : 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = indexPath.section;
    DICardTVItem *item = _datasource[section];
    CGFloat ret;
    if ([item.keyString isEqualToString:SIGHT_LIST_ITEM_SCHEDULE])
        ret = self.scheduleListView.frame.size.height;
    else
        ret = item.webView ? item.webView.frame.size.height : 0;
    
    return ret;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger section = indexPath.section;
    UITableViewCell *cell;

    cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if (!cell) {
        cell = [UITableViewCell new];
    }
    
    DICardTVItem *item = _datasource[section];
    if ([item.keyString isEqualToString:SIGHT_LIST_ITEM_SCHEDULE]) {
        [cell.contentView addSubview:self.scheduleListView];
    }
    else {
        if (!item.webView) {
            [self setWebViewForItem:item];
            _loadingWebViewIndexPath = indexPath;
        }
        [cell.contentView addSubview:item.webView];
    }

    //cell.userInteractionEnabled = NO;
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    DIHeaderView *header = [_tableView dequeueReusableHeaderFooterViewWithIdentifier:HEADER_ID];
    header.delegate = self;
    header.section = section;
    DICardTVItem *item = _datasource[section];
    header.item = item;
    [header refreshContent];
    return header;
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
    
    [_tableView scrollToRowAtIndexPath:_loadingWebViewIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    _loadingWebViewIndexPath = nil;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *urlString = [request.URL absoluteString];
    NSRange range = [urlString rangeOfString:@"http://www"];
    if (range.location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    return YES;
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
    
    if (item.opened && !_loadingWebViewIndexPath) {
        [_tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    [header refreshContent];
    
    if (item.opened && section == _datasource.count-1)  //otherway last cell doesn't scroll to top when it is openning
        _tableView.contentOffset = CGPointMake(0, _tableView.contentOffset.y + 1.);
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
        if ([key isEqualToString:SIGHT_LIST_ITEM_SCHEDULE]) {
            DICardTVItem *newItem = [DICardTVItem new];
            newItem.keyString = key;
            [_datasource addObject:newItem];
        }
        else {
            NSString *htmlValue = [_sight valueForKey:key];
            if (htmlValue) {
                DICardTVItem *newItem = [DICardTVItem new];
                newItem.keyString = key;
                newItem.htmlString = htmlValue;
                [_datasource addObject:newItem];
            }
        }
    }
}


#pragma mark - Setters & getters

- (NSArray *)listProperties {

    return @[SIGHT_LIST_ITEM_ABOUT,
             SIGHT_LIST_ITEM_SCHEDULE,
             SIGHT_LIST_ITEM_HISTORY,
             SIGHT_LIST_ITEM_NOW,
             SIGHT_LIST_ITEM_CONTACTS,
             SIGHT_LIST_ITEM_INTERESTING,
             SIGHT_LIST_ITEM_ADVICES];
}

- (void)setSight:(DISight *)sight {
    
    _sight = sight;
    [self createPropertyList];
}

- (UIView *)scheduleListView {
    
    CGFloat iconViewHeight = 48.;
    CGFloat labelsYOrig = 14.;
    CGFloat indent = 22.;
    CGFloat widthWithoutIndents = SCREEN_SIZE.width-indent*2;
    
    if (!_scheduleListView) {
        CGFloat height = _sevenDaysWH.count*SCHEDULE_ROW_HEIGHT + iconViewHeight;
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_SIZE.width, height)];
        view.backgroundColor = [UIColor colorWithRed:243./255 green:243./255 blue:243./255 alpha:1.];
        for (NSUInteger i=0; i<_sevenDaysWH.count; i++) {
            NSDictionary *dayDict = _sevenDaysWH[i];
            UIView *rowView = [[UIView alloc] initWithFrame:CGRectMake(0, i*SCHEDULE_ROW_HEIGHT, SCREEN_SIZE.width, SCHEDULE_ROW_HEIGHT)];
            UIColor *bgColor;
            if (i%2)
                bgColor = [UIColor colorWithRed:222./255 green:222./255 blue:222./255 alpha:1.];
            else
                bgColor = [UIColor colorWithRed:233./255 green:233./255 blue:233./255 alpha:1.];
            rowView.backgroundColor = bgColor;
            [view addSubview:rowView];
            
            UIFont *font = [UIFont systemFontOfSize:14.];
            NSString *dayString;
            switch (i) {
                case 0:
                    dayString = DILocalizedString(@"sightScheduleDaysToday");
                    break;
                case 1:
                    dayString = DILocalizedString(@"sightScheduleDaysTomorrow");
                    break;
                case 2:
                    dayString = DILocalizedString(@"sightScheduleDaysAfterTomorrow");
                    break;
                default:
                    dayString = dayDict.allKeys.firstObject;
                    break;
            }
            NSString *weekDay = [[DISightsManager sharedInstance] weekDayFromDateString:dayDict.allKeys.firstObject];
            dayString = [NSString stringWithFormat:@"%@  \t%@", weekDay, dayString];
            
            CGRect frame = [dayString rectForSize:CGSizeMake(280, 17)
                                             font:font
                                    lineBreakMode:NSLineBreakByWordWrapping];
            frame.origin = CGPointMake(indent, labelsYOrig);
            UILabel *dayLabel = [[UILabel alloc] initWithFrame:frame];
            dayLabel.text = dayString;
            dayLabel.font = font;
            [rowView addSubview:dayLabel];
            
            CGFloat secondLabelOrig = indent+CGRectGetMaxX(frame)+2;
            frame = CGRectMake(secondLabelOrig, labelsYOrig, 280.-secondLabelOrig, 17);
            UILabel *hoursLabel = [[UILabel alloc] initWithFrame:frame];
            hoursLabel.textAlignment = NSTextAlignmentRight;
            hoursLabel.font = font;
            [rowView addSubview:hoursLabel];
            
            NSDictionary *insideDict = dayDict.allValues.firstObject;
            if (insideDict.count < 2)
                continue;
            NSDate *openDate = insideDict[@"timeOpen"];
            NSDate *closeDate = insideDict[@"timeClose"];
            NSString *closeOpenStr = [[DISightsManager sharedInstance] openCloseStringFromDateOpen:openDate
                                                                                         dateClose:closeDate];
            hoursLabel.text = closeOpenStr;
        }
        
        UIView *iconView = [[UIView alloc] initWithFrame:CGRectMake(indent, _sevenDaysWH.count*SCHEDULE_ROW_HEIGHT, widthWithoutIndents, iconViewHeight)];
        [self adjustIconView:iconView];
        [view addSubview:iconView];
        
        _scheduleListView = view;
    }
    
    return _scheduleListView;
}


@end
