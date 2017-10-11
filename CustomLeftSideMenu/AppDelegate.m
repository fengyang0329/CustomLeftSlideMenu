//
//  AppDelegate.m
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
#import "SlideMenuViewController.h"
#import "LeftViewController.h"
#import "RightViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    HomeViewController *homeCtr = [[HomeViewController alloc] init];
    LeftViewController *leftCtr = [[LeftViewController alloc] init];
    RightViewController *rightCtr = [[RightViewController alloc] init];
    _navigationController = [[UINavigationController alloc] initWithRootViewController:homeCtr];
    SlideMenuViewController *leftSlideMenu = [[SlideMenuViewController alloc] initWithContentViewController:_navigationController LeftMenuViewController:leftCtr RightMenuViewController:rightCtr];
    leftSlideMenu.backgroundImage = [UIImage imageNamed:@"bgScaleImage"];
    leftSlideMenu.scaleBackgroundImageView = YES;//是否开启背景图缩放动画
    self.window.rootViewController = leftSlideMenu;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
