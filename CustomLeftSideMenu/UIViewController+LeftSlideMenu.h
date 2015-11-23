//
//  UIViewController+LeftSlideMenu.h
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LeftSlideMenuViewController.h"

extern NSString *const LeftSlideMenuWillShowNotification;
extern NSString *const LeftSlideMenuDidShowNotification;
extern NSString *const LeftSlideMenuWillHideNotification;
extern NSString *const LeftSlideMenuDidHideNotification;

@interface UIViewController (LeftSlideMenu)

@property (strong, readonly, nonatomic)LeftSlideMenuViewController *sideMenuViewController;

- (void)showLeftMenuViewController;
- (void)pushLeftMenuViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
