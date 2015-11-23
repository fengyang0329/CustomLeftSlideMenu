//
//  LeftSlideMenuViewController.m
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "LeftSlideMenuViewController.h"
#import "UIViewController+LeftSlideMenu.h"

#define kScreenWidth          [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight         [[UIScreen mainScreen] bounds].size.height



@interface LeftSlideMenuViewController ()<UIGestureRecognizerDelegate>

@property(nonatomic,strong)UIImageView *backgroundImageView;
@property(nonatomic,strong)UIButton *contentButton;
@property(nonatomic,strong)UIViewController *contentViewController;
@property(nonatomic,strong)UIViewController *leftMenuViewController;
@property(nonatomic,strong)UIView *menuViewContainer;
@property(nonatomic,strong)UIView *contentViewContainer;

@property(nonatomic,assign)BOOL visible;
@property(nonatomic,strong)UIView *contentCoverView;
@property(nonatomic,assign)CGFloat contentMaxCentreX;


@property(nonatomic,assign)CGFloat distanceVariable;
@property(nonatomic,strong)UIView *menuAlphView;
@property(nonatomic,assign)CGFloat menuStartCentreX;
@property(nonatomic,assign)CGFloat menuEndCentreX;



@end

@implementation LeftSlideMenuViewController

- (id)init
{
    self = [super init];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self defaultInit];
    }
    return self;
}

- (void)defaultInit
{
    _contentViewScaleValue = kDefaultScaleValue;
    _animationDuration = kDefaultAnimationDuration;
    _panGestureEnabled = YES;
    _panFromEdge = NO;
    _percentOfMenu = kDefaultPercentOfMenu;
    _distanceVariable = 0;
    _menuStartCentreX = 30;
}

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController
                       LeftMenuViewController:(UIViewController *)leftMenuViewController
{
    if (self==[self init])
    {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    _contentMaxCentreX = kScreenWidth*self.percentOfMenu + kScreenWidth*_contentViewScaleValue*0.5;
    _menuEndCentreX = kScreenWidth *self.percentOfMenu/2;

    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_backgroundImageView setImage:_backgroundImage];
    [self.view addSubview:_backgroundImageView];
    
    _menuViewContainer = [UIView new];
    [_menuViewContainer setFrame:CGRectMake(0, 0, kScreenWidth*self.percentOfMenu, kScreenHeight)];
    [_menuViewContainer setBackgroundColor:[UIColor clearColor]];
    _menuViewContainer.clipsToBounds = YES;
    [self.view addSubview:_menuViewContainer];
    
    
    //Menu
    if (_leftMenuViewController) {
        [self addChildViewController:_leftMenuViewController];
        _leftMenuViewController.view.frame = _menuViewContainer.bounds;
        [_leftMenuViewController.view setBackgroundColor:[UIColor clearColor]];
        [_menuViewContainer addSubview:_leftMenuViewController.view];
        [_leftMenuViewController didMoveToParentViewController:self];
        _menuViewContainer.transform = CGAffineTransformMakeScale(kMenuMinScale, kMenuMinScale);
        _menuViewContainer.center = CGPointMake(0, kScreenHeight/2);
        
        
        //蒙版
        UIView *view = [[UIView alloc] init];
        view.frame = self.view.bounds;
        view.backgroundColor = [UIColor blackColor];
        view.alpha = 0.5;
        self.menuAlphView = view;
        [self.view addSubview:self.menuAlphView];
    }
    
    //content
    _contentViewContainer = [UIView new];
    [_contentViewContainer setFrame:self.view.bounds];
    [_contentViewContainer setBackgroundColor:[UIColor clearColor]];
    _contentViewContainer.clipsToBounds = YES;
    _contentViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_contentViewContainer];
    
    [self addChildViewController:self.contentViewController];
    self.contentViewController.view.frame = _contentViewContainer.bounds;
    [self.contentViewContainer addSubview:self.contentViewController.view];
    self.contentViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.contentViewController didMoveToParentViewController:self];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    pan.delegate = self;
    [_contentViewController.view addGestureRecognizer:pan];
}


- (void)showLeftMenuViewController
{
    [self showLeftMenuViewControllerWithAnimationDuration:_animationDuration];
}

- (void)showLeftMenuViewControllerWithAnimationDuration:(NSTimeInterval)duration
{
    if (!_leftMenuViewController) {
        return;
    }
    _visible = YES;
    [self postNSNotification:LeftSlideMenuWillShowNotification];
//    [_leftMenuViewController beginAppearanceTransition:YES animated:YES];
    [self.view.window endEditing:YES];
    [UIView animateWithDuration:duration animations:^{
        
        //缩放
        _contentViewContainer.transform = CGAffineTransformMakeScale(_contentViewScaleValue, _contentViewScaleValue);
        _contentViewContainer.center = CGPointMake(_contentMaxCentreX, CGRectGetHeight(self.view.bounds)/2);
        
        _menuViewContainer.center = CGPointMake(_menuEndCentreX, kScreenHeight/2);
        _menuViewContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        _menuAlphView.alpha = 0;
        
        if (self.scaleBackgroundImageView)
        {
            _backgroundImageView.transform = CGAffineTransformMakeScale(kBgImageMaxScale, kBgImageMaxScale);
        }
        
    } completion:^(BOOL finished) {

        _distanceVariable = kScreenWidth*self.contentViewScaleValue;
        [self addContentCoverView];
        [self postNSNotification:LeftSlideMenuDidShowNotification];
//        [_leftMenuViewController endAppearanceTransition];
    }];

}

- (void)hideLeftMenuViewController
{
    [self hideLeftMenuViewControllerWithAnimationDuration:_animationDuration];
}

- (void)hideLeftMenuViewControllerWithAnimationDuration:(NSTimeInterval)duration
{
    if (!_leftMenuViewController) {
        return;
    }
    _visible = NO;
    [self postNSNotification:LeftSlideMenuWillHideNotification];
//    [_leftMenuViewController beginAppearanceTransition:YES animated:YES];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
        
        _contentViewContainer.transform = CGAffineTransformIdentity;
        _contentViewContainer.frame = self.view.bounds;
        _contentViewContainer.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
        
        _menuViewContainer.transform = CGAffineTransformMakeScale(kMenuMinScale, kMenuMinScale);
        _menuViewContainer.center = CGPointMake(_menuStartCentreX, kScreenHeight/2);
        _menuAlphView.alpha = kMenuMaxAlpha;
        if (self.scaleBackgroundImageView)
        {
            _backgroundImageView.transform = CGAffineTransformMakeScale(1, 1);
        }
        
    } completion:^(BOOL finished) {
        
        _distanceVariable = 0;
        [self removeContentCoverView];
        [self postNSNotification:LeftSlideMenuDidHideNotification];
//        [_leftMenuViewController endAppearanceTransition];
    }];
}

- (void)addContentCoverView
{
    if (_contentCoverView==nil)
    {
        _contentCoverView = [[UIView alloc] initWithFrame:_contentViewContainer.bounds];
        [_contentCoverView setBackgroundColor:[UIColor clearColor]];
        [_contentViewContainer addSubview:_contentCoverView];
        
        //单击手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        tap.numberOfTapsRequired = 1;
        [_contentCoverView addGestureRecognizer:tap];
        
        //滑动手势
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        [_contentCoverView addGestureRecognizer:pan];

    }
    
}

- (void)removeContentCoverView
{
    if (_contentCoverView)
    {
        [_contentCoverView removeFromSuperview];
        _contentCoverView = nil;
    }
}

#pragma mark 单点手势
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture
{
    if (_visible)
    {
        [self hideLeftMenuViewController];
    }
    else
    {
        [self showLeftMenuViewController];
    }
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if ([self.contentViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *navigationController = (UINavigationController *)self.contentViewController;
        if (navigationController.viewControllers.count > 1)
        {
            //在其他页面禁止侧滑
            return NO;
        }
    }
    CGPoint point = [touch locationInView:gestureRecognizer.view];
    if (!self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && !self.visible)
    {
        if (point.x < kDefailtGestureArea || point.x > self.view.frame.size.width - kDefailtGestureArea)
        {
            return YES;
        } else {
            //超出侧滑区域
            return NO;
        }
    }
    return YES;
}

#pragma mark 滑动手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)pangesture
{
 
    CGFloat velocity = [pangesture velocityInView:self.view].x;
    if (!self.panGestureEnabled)
    {
        return;
    }
    CGPoint point = [pangesture translationInView:self.view];
    // 禁止在主界面的时候向左滑动
    if (!_visible && point.x < 0)
    {
//        NSLog(@"禁止在主界面的时候向左滑动");
        [self hideLeftMenuViewControllerWithAnimationDuration:0];
        return;
    }
    //禁止在menu显示到最大的时候向右滑动
    if (_contentViewContainer.center.x >= _contentMaxCentreX && point.x>0 && _visible)
    {
//        NSLog(@"禁止在menu显示到最大的时候向右滑动");
        [self showLeftMenuViewControllerWithAnimationDuration:0];
        return;
    }
    if (velocity >= 800 && !_visible)
    {
//        NSLog(@"手速太快，直接显示");
        [self showLeftMenuViewController];
        return;
    }
    else if (velocity <= -800 && _visible)
    {
//        NSLog(@"手速太快，直接隐藏");
        [self hideLeftMenuViewController];
        return;
    }
    CGFloat dis = self.distanceVariable + point.x;
    CGFloat maxDis = kScreenWidth/2 + kScreenWidth*(1-self.percentOfMenu)/2;
    if (dis > maxDis)
    {
        dis = maxDis;
    }
    // 当手势停止时执行操作
    if (pangesture.state == UIGestureRecognizerStateEnded)
    {
        if (dis >= kScreenWidth * self.percentOfMenu/2)
        {
            CGFloat distance = kScreenWidth*self.percentOfMenu - CGRectGetMinX(_contentViewContainer.frame);
            NSTimeInterval duration = distance/kScreenWidth*_animationDuration;
            [self showLeftMenuViewControllerWithAnimationDuration:duration];
        }
        else if(dis < kScreenWidth * self.percentOfMenu/2)
        {
            CGFloat duration = CGRectGetMinX(_contentViewContainer.frame)/kScreenWidth*_animationDuration;
            [self hideLeftMenuViewControllerWithAnimationDuration:duration];
        }
        return;
    }
    CGFloat proportion = (_contentViewScaleValue - 1) * dis / (kScreenWidth *_contentViewScaleValue) + 1;
    if (proportion < _contentViewScaleValue || proportion > 1)
    {
        return;
    }
    if (pangesture.state == UIGestureRecognizerStateBegan)
    {
        if (point.x > 0)
        {
            if (!self.visible)
            {
                [self postNSNotification:LeftSlideMenuWillShowNotification];
            }
        }
        else if (point.x < 0)
        {
            if (self.visible)
            {
                [self postNSNotification:LeftSlideMenuWillHideNotification];
            }
        }
    }
    CGFloat centreX = self.view.center.x+dis;
    centreX = centreX >= _contentMaxCentreX?_contentMaxCentreX:centreX;
    _contentViewContainer.center = CGPointMake(centreX, kScreenHeight/2);
    _contentViewContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
    
    _menuAlphView.alpha = kMenuMaxAlpha-dis/(kScreenWidth*self.percentOfMenu);
    [self addContentCoverView];

    CGFloat menuProportion = dis * (1 - kMenuMinScale) / (kScreenWidth * self.percentOfMenu) + kMenuMinScale;
    CGFloat menuCenterMove = dis * (self.menuEndCentreX - self.menuStartCentreX) / (kScreenWidth * self.percentOfMenu);
    menuCenterMove = menuCenterMove+_menuStartCentreX;
    menuCenterMove = menuCenterMove>=_menuEndCentreX?_menuEndCentreX:menuCenterMove;
    menuProportion = menuProportion>1?1:menuProportion;
    _menuViewContainer.center = CGPointMake(menuCenterMove, kScreenHeight/2);
    _menuViewContainer.transform = CGAffineTransformMakeScale(menuProportion, menuProportion);

    //背景图片设置缩放动画
    if (self.scaleBackgroundImageView)
    {
        CGFloat bgScale = (kBgImageMaxScale-1)*menuProportion+1;
        _backgroundImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, bgScale, bgScale);
    }
}


#pragma mark Setters
- (void)setBackgroundImage:(UIImage *)backgroundImage
{
    _backgroundImage = backgroundImage;
    if (_backgroundImageView)
    {
        [_backgroundImageView setImage:_backgroundImage];
    }
}


- (void)pushMenuViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([_contentViewController isKindOfClass:[UINavigationController class]])
    {
        UINavigationController *naviCtr = (UINavigationController *)_contentViewController;
        [naviCtr pushViewController:viewController animated:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self hideLeftMenuViewController];
        });
    }
}



- (void)postNSNotification:(NSString *)name
{
    NSNotification *notification = [NSNotification notificationWithName:name object:nil];
    if (notification)
    {
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
