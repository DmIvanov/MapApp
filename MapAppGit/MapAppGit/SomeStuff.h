//
//  SomeStuff.c
//  MapAppGit
//
//  Created by Dmitry Ivanov on 27.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//

#include <stdio.h>

static NSString *beatlesImgURL = @"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTACenH2Qbdm40hSmcQmzeReolDDYscWoo5oRdSuD_dn8kqBiUf";
static NSString *beatlesDescr = @"an English rock band that formed in Liverpool, in 1960. With John Lennon, Paul McCartney, George Harrison, and Ringo Starr, they became widely regarded as the greatest and most influential act of the rock era.";

static NSString *pinkFloydImgURL = @"https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR9U4qPpps5eDoOHPEqQSxzveYHx76ZXRnuVda89QcAxkhjONZd";
static NSString *pinkFloydDescr = @"an English rock band that achieved international acclaim with their progressive and psychedelic music.";

static NSString *rollingStonesImgURL = @"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQneFt8GTS0yuOInCErwZfZE39SEKUFaXfOFzs_a8ZRSVVma1kTOg";
static NSString *rollingStonesDescr = @"an English rock band formed in London in 1962 who were in the vanguard of the British Invasion of bands that first became popular in the US in 1964–65.";

static NSString *doorsImgURL = @"https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSyh354MdN7VEdwvVJb9qbFKa9EFnwAVzibqMuLFE3ZnZIGzlCT";
static NSString *doorsDescr = @"an American rock band formed in 1965 in Los Angeles, California, with vocalist Jim Morrison, keyboardist Ray Manzarek, drummer John Densmore and guitarist Robby Krieger.";

static NSString *ledZepellinImgURL = @"https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRaeW58sC20FI-tLfE8iZZkdIdab5yvQH28nrffVT9ok2KGI2QE";
static NSString *ledZepellinDescr = @"an English rock band formed in London in 1968. The band consisted of guitarist Jimmy Page, singer Robert Plant, bassist and keyboardist John Paul Jones, and drummer John Bonham.";


//        _dataArray      = @[@"The Beatles", @"Pink Floyd", @"The Rolling Stones", @"The Doors", @"Led Zepellin", @"Dire Straits", @"The Strokes", @"Velvet undeground", @"Deep purple", @"The Beatles", @"Pink Floyd", @"The Rolling Stones", @"The Doors", @"Led Zepellin", @"Dire Straits", @"The Strokes", @"Velvet undeground", @"Deep purple", @"The Beatles", @"Pink Floyd", @"The Rolling Stones", @"The Doors", @"Led Zepellin", @"Dire Straits", @"The Strokes", @"Velvet undeground", @"Deep purple"];
//        _dataArray      = @[@"The Beatles", @"Pink Floyd", @"The Rolling Stones", @"The Doors", @"Led Zepellin"];

//        _dataArray = [NSMutableArray array];
//
//        DIItem *item = [DIItem new];
//        item.name = @"THE BEATLES";
//        item.descriptionString = beatlesDescr;
//        NSURL *imageURL = [NSURL URLWithString:beatlesImgURL];
//        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
//        item.imageData = imageData;
//        [_dataArray addObject:item];

//        [appDelegate createAndSaveItemWithName:@"THE BEATLES"
//                                   description:beatlesDescr
//                                     imageData:imageData];

//        item = [DIItem new];
//        item.name = @"PINK FLOYD";
//        item.descriptionString = pinkFloydDescr;
//        imageURL = [NSURL URLWithString:pinkFloydImgURL];
//        imageData = [NSData dataWithContentsOfURL:imageURL];
//        item.imageData = imageData;
//        [_dataArray addObject:item];
//        [appDelegate createAndSaveItemWithName:@"PINK FLOYD"
//                                   description:pinkFloydDescr
//                                     imageData:imageData];
//
//        item = [DIItem new];
//        item.name = @"THE ROLLING STONES";
//        item.descriptionString = rollingStonesDescr;
//        imageURL = [NSURL URLWithString:rollingStonesImgURL];
//        imageData = [NSData dataWithContentsOfURL:imageURL];
//        item.imageData = imageData;
//        [_dataArray addObject:item];
//        [appDelegate createAndSaveItemWithName:@"THE ROLLING STONES"
//                                   description:rollingStonesDescr
//                                     imageData:imageData];

//        item = [DIItem new];
//        item.name = @"THE DOORS";
//        item.descriptionString = doorsDescr;
//        imageURL = [NSURL URLWithString:doorsImgURL];
//        imageData = [NSData dataWithContentsOfURL:imageURL];
//        item.imageData = imageData;
//        [_dataArray addObject:item];
//        [appDelegate createAndSaveItemWithName:@"THE DOORS"
//                                   description:doorsDescr
//                                     imageData:imageData];

//        item = [DIItem new];
//        item.name = @"LED ZEPELLIN";
//        item.descriptionString = ledZepellinDescr;
//        imageURL = [NSURL URLWithString:ledZepellinImgURL];
//        imageData = [NSData dataWithContentsOfURL:imageURL];
//        item.imageData = imageData;
//        [_dataArray addObject:item];
//        [appDelegate createAndSaveItemWithName:@"LED ZEPELLIN"
//                                   description:ledZepellinDescr
//                                     imageData:imageData];

