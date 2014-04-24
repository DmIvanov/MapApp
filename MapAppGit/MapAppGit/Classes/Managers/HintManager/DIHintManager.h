//
//  DIHintManager.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 24.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DIHint;

@interface DIHintManager : NSObject

+ (DIHintManager *)sharedInstance;
- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

- (void)showHint:(DIHint *)hint;
- (void)performNotification;

@end
