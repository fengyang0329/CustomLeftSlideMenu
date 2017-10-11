//
//  UIViewController+LeftSlideMenu.h
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SlideMenuViewController.h"

extern NSString *const LeftSlideMenuWillShowNotification;
extern NSString *const LeftSlideMenuDidShowNotification;
extern NSString *const LeftSlideMenuWillHideNotification;
extern NSString *const LeftSlideMenuDidHideNotification;

extern NSString *const RightSlideMenuWillShowNotification;
extern NSString *const RightSlideMenuDidShowNotification;
extern NSString *const RightSlideMenuWillHideNotification;
extern NSString *const RightSlideMenuDidHideNotification;

@interface UIViewController (SlideMenu)

@property (strong, readonly, nonatomic)SlideMenuViewController *sideMenuViewController;

- (void)showLeftMenuViewController;
- (void)showRightMenuViewController;
- (void)pushMenuViewController:(UIViewController *)viewController animated:(BOOL)animated;

@end
