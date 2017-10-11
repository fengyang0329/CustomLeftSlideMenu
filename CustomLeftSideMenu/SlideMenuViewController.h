//
//  SlideMenuViewController.h
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDefaultAnimationDuration 0.3
#define kDefaultScaleValue 0.7
#define kDefaultPercentOfMenu 0.66
#define kDefaultGestureArea  100

#define kMenuMinScale 0.5

#define kBgImageMaxScale 2

//视图出现动画方式
typedef NS_ENUM(NSInteger,MenuDisPlayMode){
  
    MenuDisPlayModeScale = 0, //由小到大的缩放
    MenuDisPlayModeTransition = 1,//没有缩放，平移
};

@interface SlideMenuViewController : UIViewController
/**
 *  背景图片
 */
@property(nonatomic,strong)UIImage *backgroundImage;
@property(nonatomic,assign)BOOL scaleBackgroundImageView;

//背景缩放方式，默认由大变小，NO:由小变大，
@property(nonatomic,assign)BOOL bgZoomSmaller;
@property(nonatomic,assign)MenuDisPlayMode menuDisplayType;

/**
 *  是否开启左滑手势，默认开启
 */
@property(nonatomic,assign)BOOL panGestureEnabled;


/**
 *  手势是否从屏幕右边界开始，默认NO,左滑手势区域0-kDefaultGestureArea 右滑手势区域：（屏幕宽度-kDefaultGestureArea）-屏幕最右边
 */
@property(nonatomic,assign)BOOL panFromEdge;


/**
 *  动画时间,kDefaultAnimationDuration
 */
@property(nonatomic,assign)CGFloat animationDuration;


/**
 *  主页面缩放倍率，kDefaultScaleValue
 */
@property(nonatomic,assign)CGFloat contentViewScaleValue;


/**
 *  左滑视图占屏幕宽的比率，kDefaultPercentOfMenu
 */
@property(nonatomic,assign)CGFloat percentOfMenu;


- (instancetype)initWithContentViewController:(UIViewController *)contentViewController
                       LeftMenuViewController:(UIViewController *)leftMenuViewController
                      RightMenuViewController:(UIViewController *)rightMenuViewController;

- (void)showLeftMenuViewController;
- (void)showRightMenuViewController;
- (void)hideMenuViewController;

- (void)pushMenuViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end
