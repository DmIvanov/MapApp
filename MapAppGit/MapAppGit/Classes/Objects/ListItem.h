//
//  ListItem.h
//  MapAppGit
//
//  Created by Dmitry Ivanov on 26.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ListItem : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * descriptionString;
@property (nonatomic, retain) NSNumber * number;

@end
