//
//  DISightExtended.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 13.06.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import "DISightExtended.h"


@implementation DISightExtended


#pragma mark - Setters & getters

- (UIImage *)avatarImage {
    
    if (!_avatarImage) {
        _avatarImage = [UIImage imageWithData:_originalSight.avatarData];
    }
    
    return _avatarImage;
}

//- (NSDictionary *)list {
//    
//    if (!_list) {
//        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithCapacity:10];
//        for (NSString *listProp in [self listProperties]) {
//            NSString *value = [_originalSight valueForKey:listProp];
//            if (value)
//                [dict setObject:value forKey:listProp];
//        }
//    }
//}
//


@end
