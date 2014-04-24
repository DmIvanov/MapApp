//
//  DIHintManager.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 24.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DIHintManager.h"

#import "DIHint.h"

@interface DIHintManager ()
{
    DIHint *_currentHint;
}

@end

@implementation DIHintManager

+ (DIHintManager *)sharedInstance {
    
    static DIHintManager *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DIHintManager alloc] initSingletone];
    });
    return sharedInstance;
}

- (id)initSingletone {
    
    self = [super init];
    if (self) {
        
    }
    return self;
}


- (void)showHint:(DIHint *)hint {
    
    if (!_currentHint) {
        //showing
        _currentHint = hint;
    }
}

- (void)hideCurrentHint {
    
    if (_currentHint) {
        //hiding
        _currentHint = nil;
    }
}


- (void)performNotification {
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = @"Hint!";
    notification.alertAction = @"look";
    notification.applicationIconBadgeNumber = 13;
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}

@end
