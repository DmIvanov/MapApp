//
//  DIDefaults.h
//
//
//  Created by Dmitry Ivanov on 06.01.14.
//  Copyright (c) 2014 Dmitry Ivanov. All rights reserved.
//


#if defined(DEBUG)
#   define DLog(...) NSLog(__VA_ARGS__)
#else
#   define DLog(...)
#endif