//
//  DILocationManager.h
//  
//
//  Created by Dmitry Ivanov on 22.04.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DILocationManager : NSObject

+ (DILocationManager *)sharedInstance;
- (id)init __attribute__((unavailable("init is not available, use class methods 'sharedInstance' instead!")));
- (id)copy __attribute__((unavailable("copy is not available, use class methods 'sharedInstance' instead!")));

@end
