//
//  DIAppDelegate.m
//  MapAppGit
//
//  Created by Dmitry Ivanov on 29.12.13.
//  Copyright (c) 2013 Dmitry Ivanov. All rights reserved.
//

#import "DIAppDelegate.h"

#import "DIHelper.h"
#import "DICloudeMadeManager.h"
#import "DILocationManager.h"
#import "DISightsManager.h"

#import "DIMapController.h"
#import "ListVC.h"
#import "DIListMapVC.h"



@interface DIAppDelegate()

@property (nonatomic, strong) DIMapSourceManager *mapSourceManager;

@end


@implementation DIAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
#if 0
    //load map controller, download database from file
    DIMapController *mapController = [[DIMapController alloc] init];
    self.window.rootViewController = mapController;
#elif 0
    //download tiles to database
    _mapSourceManager = [[DICloudeMadeManager alloc] init];
    [_mapSourceManager makeDatabase];
#elif 1
    DIListMapVC *listMapController = [DIListMapVC new];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:listMapController];
    self.window.rootViewController = navi;

#else
    ListVC *listVC = [[ListVC alloc] init];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:listVC];
    self.window.rootViewController = navi;
#endif
    [self.window makeKeyAndVisible];

    [[UINavigationBar appearance] setShadowImage:[[UIImage alloc] init]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    //[self saveContext];
}


@end
