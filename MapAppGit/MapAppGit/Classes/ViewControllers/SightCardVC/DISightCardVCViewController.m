//
//  DISightCardVCViewController.m
//  
//
//  Created by Dmitry Ivanov on 26.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightCardVCViewController.h"

#import "DISight.h"

@interface DISightCardVCViewController ()

@property (nonatomic, strong) IBOutlet UITextView *textView;

@end

@implementation DISightCardVCViewController

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
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
