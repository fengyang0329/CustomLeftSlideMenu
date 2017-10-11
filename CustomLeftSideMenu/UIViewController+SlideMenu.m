//
//  UIViewController+LeftSlideMenu.m
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "UIViewController+SlideMenu.h"


NSString *const LeftSlideMenuWillShowNotification   = @"LeftSlideMenuWillShowNotification";
NSString *const LeftSlideMenuDidShowNotification    = @"LeftSlideMenuDidShowNotification";
NSString *const LeftSlideMenuWillHideNotification   = @"LeftSlideMenuWillHideNotification";
NSString *const LeftSlideMenuDidHideNotification    = @"LeftSlideMenuDidHideNotification";

NSString *const RightSlideMenuWillShowNotification   = @"RightSlideMenuWillShowNotification";
NSString *const RightSlideMenuDidShowNotification    = @"RightSlideMenuDidShowNotification";
NSString *const RightSlideMenuWillHideNotification   = @"RightSlideMenuWillHideNotification";
NSString *const RightSlideMenuDidHideNotification    = @"RightSlideMenuDidHideNotification";


@implementation UIViewController (SlideMenu)

- (SlideMenuViewController *)sideMenuViewController
{
    UIViewController *iter = self.parentViewController;
    while (iter)
    {
        if ([iter isKindOfClass:[SlideMenuViewController class]])
        {
            return (SlideMenuViewController *)iter;
        }
        else if (iter.parentViewController && iter.parentViewController != iter)
        {
            iter = iter.parentViewController;
        }
        else
        {
            iter = nil;
        }
    }
    return nil;
}


- (void)showLeftMenuViewController
{
    [self.sideMenuViewController showLeftMenuViewController];
}
- (void)showRightMenuViewController
{
    [self.sideMenuViewController showRightMenuViewController];
}

- (void)pushMenuViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (!viewController) {
        return;
    }
    [self.sideMenuViewController pushMenuViewController:viewController animated:animated];
}


@end
