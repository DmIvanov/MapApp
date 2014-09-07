//
//  DIAppDefaults.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 07.06.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#define SIGHT_LIST_ITEM_ABOUT               @"about"
#define SIGHT_LIST_ITEM_SCHEDULE            @"schedule"
#define SIGHT_LIST_ITEM_HISTORY             @"history"
#define SIGHT_LIST_ITEM_NOW                 @"now"
#define SIGHT_LIST_ITEM_CONTACTS            @"contacts"
#define SIGHT_LIST_ITEM_INTERESTING         @"interesting"
#define SIGHT_LIST_ITEM_ADVICES             @"advices"


static BOOL OSVersionIsAtLeastiOS7() {
    return (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1);
}

