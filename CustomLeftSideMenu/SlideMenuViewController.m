//
//  LeftSlideMenuViewController.m
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "SlideMenuViewController.h"
#import "UIViewController+SlideMenu.h"

#define kScreenWidth          [[UIScreen mainScreen] bounds].size.width
#define kScreenHeight         [[UIScreen mainScreen] bounds].size.height



@interface SlideMenuViewController ()<UIGestureRecognizerDelegate>
{
    NSInteger beforeTag;
    BOOL isLock;
}
@property(nonatomic,strong)UIImageView *backgroundImageView;
@property(nonatomic,strong)UIButton *contentButton;
@property(nonatomic,strong)UIViewController *contentViewController;
@property(nonatomic,strong)UIViewController *leftMenuViewController;
@property(nonatomic,strong)UIViewController *rightMenuViewController;

@property(nonatomic,strong)UIView *menuViewContainer;//侧滑弹出视图
@property(nonatomic,strong)UIView *contentViewContainer;//主视图

@property(nonatomic,assign)BOOL visible;
@property(nonatomic,strong)UIView *contentCoverView;//主视图覆盖视图，用来添加单点、滑动手势
@property(nonatomic,assign)CGFloat contentMaxCentreX;
@property(nonatomic,assign)CGFloat contentMinCentreX;



@property(nonatomic,assign)CGFloat distanceVariable;
@property(nonatomic,assign)CGFloat menuStartCentreX;
@property(nonatomic,assign)CGFloat menuEndCentreX;

@property(nonatomic,assign)CGFloat rightMenuStartCentreX;
@property(nonatomic,assign)CGFloat rightMenuEndCentreX;

@property(nonatomic,assign)BOOL isShowLeft;
@end

@implementation SlideMenuViewController

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
    _rightMenuStartCentreX = kScreenWidth-30;
    _bgZoomSmaller = YES;
    _menuDisplayType = MenuDisPlayModeScale;
    beforeTag = 0;
}

- (instancetype)initWithContentViewController:(UIViewController *)contentViewController
                       LeftMenuViewController:(UIViewController *)leftMenuViewController
                      RightMenuViewController:(UIViewController *)rightMenuViewController;

{
    if (self==[self init])
    {
        _contentViewController = contentViewController;
        _leftMenuViewController = leftMenuViewController;
        _rightMenuViewController = rightMenuViewController;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.clipsToBounds = YES;
    _contentMaxCentreX = kScreenWidth*self.percentOfMenu + kScreenWidth*_contentViewScaleValue*0.5;
    _menuEndCentreX = kScreenWidth *self.percentOfMenu/2;
    
    _contentMinCentreX = kScreenWidth - _contentMaxCentreX;
    _rightMenuEndCentreX = kScreenWidth - kScreenWidth*self.percentOfMenu/2;
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    [_backgroundImageView setImage:_backgroundImage];
    [self.view addSubview:_backgroundImageView];
    
    _menuViewContainer = [UIView new];
    if (self.menuDisplayType == MenuDisPlayModeTransition) {
        [_menuViewContainer setFrame:CGRectMake(-kScreenWidth*self.percentOfMenu, 0, kScreenWidth*self.percentOfMenu, kScreenHeight)];
    }else{
        [_menuViewContainer setFrame:CGRectMake(0, 0, kScreenWidth*self.percentOfMenu, kScreenHeight)];
    }
    _menuViewContainer.clipsToBounds = YES;
    [self.view addSubview:_menuViewContainer];
    
    
    //Menu
    if (_leftMenuViewController) {
        [self addChildViewController:_leftMenuViewController];
        _leftMenuViewController.view.frame = _menuViewContainer.bounds;
        [_menuViewContainer addSubview:_leftMenuViewController.view];
        [_leftMenuViewController didMoveToParentViewController:self];
        
//        //蒙版
//        UIView *view = [[UIView alloc] init];
//        view.frame = self.view.bounds;
//        view.backgroundColor = [UIColor purpleColor];
//        view.alpha = 0.5;
//        self.menuAlphView = view;
//        [self.view addSubview:self.menuAlphView];
    }
    if (_rightMenuViewController) {
        
        [self addChildViewController:_rightMenuViewController];
        _rightMenuViewController.view.frame = _menuViewContainer.bounds;
        [_menuViewContainer addSubview:_rightMenuViewController.view];
        [_rightMenuViewController didMoveToParentViewController:self];
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
    
    [self hideMenuViewControllerWithAnimationDuration:0];
}

- (void)transitionToLeftViewController:(BOOL)left
{
    if (!_leftMenuViewController || !_rightMenuViewController) {
        
        return;
    }
    if (!left) {
        
          [self transitionFromViewController:_leftMenuViewController toViewController:_rightMenuViewController duration:0 options:0 animations:nil completion:nil];
    }else{
        
          [self transitionFromViewController:_rightMenuViewController toViewController:_leftMenuViewController duration:0 options:0 animations:nil completion:nil];
    }
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
    _isShowLeft = YES;
    _visible = YES;
    [self transitionToLeftViewController:YES];
    [self postNSNotification:LeftSlideMenuWillShowNotification];
    [_leftMenuViewController beginAppearanceTransition:YES animated:YES];
    [self.view.window endEditing:YES];
    [UIView animateWithDuration:duration animations:^{
        
        //缩放
   
        _contentViewContainer.center = CGPointMake(_contentMaxCentreX, CGRectGetHeight(self.view.bounds)/2);
        
        _menuViewContainer.center = CGPointMake(_menuEndCentreX, kScreenHeight/2);
        if (self.menuDisplayType == MenuDisPlayModeScale) {
           
            _contentViewContainer.transform = CGAffineTransformMakeScale(_contentViewScaleValue, _contentViewScaleValue);
            _menuViewContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        }
        if (self.scaleBackgroundImageView)
        {
            CGFloat scale = _bgZoomSmaller?1:kBgImageMaxScale;
            _backgroundImageView.transform = CGAffineTransformMakeScale(scale, scale);
        }
        
    } completion:^(BOOL finished) {
        
        _distanceVariable = kScreenWidth*self.contentViewScaleValue;
        [self addContentCoverView];
        [self postNSNotification:LeftSlideMenuDidShowNotification];
        [_leftMenuViewController endAppearanceTransition];
    }];
    [self addLock];
    
}
- (void)addLock
{
    isLock = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        isLock = NO;
    });
}

- (void)showRightMenuViewController
{
    [self showRightMenuViewControllerWithAnimationDuration:_animationDuration];
}

- (void)showRightMenuViewControllerWithAnimationDuration:(NSTimeInterval)duration
{
    if (!_rightMenuViewController) {
        return;
    }
    _visible = YES;
    [self transitionToLeftViewController:NO];
    [self postNSNotification:RightSlideMenuWillShowNotification];
    [_rightMenuViewController beginAppearanceTransition:YES animated:YES];
    [self.view.window endEditing:YES];
    [UIView animateWithDuration:duration animations:^{
        
        //缩放
        
        _contentViewContainer.center = CGPointMake(_contentMinCentreX, CGRectGetHeight(self.view.bounds)/2);
        _menuViewContainer.center = CGPointMake(_rightMenuEndCentreX, kScreenHeight/2);
        if (self.menuDisplayType == MenuDisPlayModeScale) {
            
            _contentViewContainer.transform = CGAffineTransformMakeScale(_contentViewScaleValue, _contentViewScaleValue);
            _menuViewContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity,1.0,1.0);
        }
        
        if (self.scaleBackgroundImageView)
        {
            CGFloat scale = _bgZoomSmaller?1:kBgImageMaxScale;
            _backgroundImageView.transform = CGAffineTransformMakeScale(scale, scale);
        }
        
    } completion:^(BOOL finished) {
        
        _isShowLeft = NO;
        _distanceVariable = kScreenWidth*self.contentViewScaleValue;
        [self addContentCoverView];
        [self postNSNotification:RightSlideMenuDidShowNotification];
        [_leftMenuViewController endAppearanceTransition];
    }];
    [self addLock];
}

- (void)hideMenuViewController
{
    [self hideMenuViewControllerWithAnimationDuration:_animationDuration];
}

- (void)hideMenuViewControllerWithAnimationDuration:(NSTimeInterval)duration
{
    if (!_leftMenuViewController && !_rightMenuViewController) {
        return;
    }
    _visible = NO;
    [self postNSNotification:_isShowLeft?LeftSlideMenuWillHideNotification:RightSlideMenuWillHideNotification];
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
        
        if (self.menuDisplayType == MenuDisPlayModeScale) {
            _contentViewContainer.transform = CGAffineTransformIdentity;
        }
        _contentViewContainer.frame = self.view.bounds;
        _contentViewContainer.center = CGPointMake(CGRectGetWidth(self.view.bounds)/2, CGRectGetHeight(self.view.bounds)/2);
        
        _menuViewContainer.center = CGPointMake(_isShowLeft?_menuStartCentreX:_rightMenuStartCentreX, kScreenHeight/2);
        if (self.menuDisplayType == MenuDisPlayModeScale) {
            
            _menuViewContainer.transform = CGAffineTransformMakeScale(kMenuMinScale, kMenuMinScale);
        }
        if (self.scaleBackgroundImageView)
        {
            CGFloat scale = _bgZoomSmaller?kBgImageMaxScale:1;
            _backgroundImageView.transform = CGAffineTransformMakeScale(scale, scale);
        }
        
    } completion:^(BOOL finished) {
        
        beforeTag = 0;
        _distanceVariable = 0;
        _isShowLeft = NO;
        [self removeContentCoverView];
        [self postNSNotification:_isShowLeft?LeftSlideMenuDidHideNotification:RightSlideMenuDidHideNotification];
    }];
    [self addLock];
}

- (void)addContentCoverView
{
    if (_contentCoverView==nil)
    {
        UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        _contentCoverView = [[UIView alloc] initWithFrame:_contentViewContainer.bounds];
        [_contentCoverView setBackgroundColor:color];
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
        [self hideMenuViewController];
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
    if (!self.panFromEdge && [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
    {
        NSLog(@"gestureRecognizer:%f",point.x);
        if (!_visible) {
            
            if (point.x < kDefaultGestureArea || point.x > kScreenWidth-kDefaultGestureArea)
            {
                return YES;
            } else {
                //超出侧滑区域
                return NO;
            }
            
        }else{
            
            if (CGRectContainsPoint(_contentViewContainer.frame, point)) {
                
                return YES;
            }
            return NO;
        }
        
    }
    return YES;
}

#pragma mark 滑动手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)pangesture
{
    CGFloat velocity = [pangesture velocityInView:self.view].x;
    CGPoint point = [pangesture translationInView:self.view];
    NSInteger _isLeft = 0;
    if ((!_visible && point.x >0) || (_visible && point.x < 0)) {
        
        //操作LeftViewController
        _isLeft = 1;
    }else if ((!_visible && point.x <0) || (_visible && point.x > 0)){
        
        _isLeft = 2;
    }
    if (!self.panGestureEnabled
        || (_visible && !_isShowLeft && point.x <0)
        || (_visible && _isShowLeft && point.x >0)
        || _isLeft == 0
        || isLock)
    {
        return;
    }
//    NSLog(@"pointX:%f",point.x);
    CGFloat menuProportion = 0;
    if (_isLeft == 1) {
        
        if (!_leftMenuViewController || beforeTag == 2) {
            
            return;
        }
        // 禁止在主界面的时候向左滑动
        if (!_visible && point.x < 0)
        {
            
//                    NSLog(@"禁止在主界面的时候向左滑动");
            [self hideMenuViewControllerWithAnimationDuration:0];
            return;
        }
        //禁止在menu显示到最大的时候向右滑动
        if (_contentViewContainer.center.x >= _contentMaxCentreX && point.x>0 && _visible)
        {
//                    NSLog(@"禁止在menu显示到最大的时候向右滑动");
            [self showLeftMenuViewControllerWithAnimationDuration:0];
            return;
        }
        if (velocity >= 800 && !_visible)
        {
//                    NSLog(@"手速太快，直接显示");
            [self showLeftMenuViewController];
            return;
        }
        else if (velocity <= -800 && _visible)
        {
//                    NSLog(@"手速太快，直接隐藏");
            [self hideMenuViewController];
            return;
        }
        CGFloat dis = self.distanceVariable + point.x;
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
                [self hideMenuViewControllerWithAnimationDuration:duration];
            }
            NSLog(@"+++++++++++++++++++++");
            return;
        }
        if (pangesture.state == UIGestureRecognizerStateBegan)
        {
            if (point.x > 0)
            {
                if (!self.visible)
                {
                    [self transitionToLeftViewController:YES];
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
            beforeTag = _isLeft;
        }
        CGFloat centreX = self.view.center.x+dis;
        centreX = centreX >= _contentMaxCentreX?_contentMaxCentreX:centreX;
        centreX = centreX <= self.view.center.x?self.view.center.x:centreX;
        
        dis = (centreX-self.view.center.x);
        CGFloat proportion = dis/(_contentMaxCentreX-CGRectGetMidX(self.view.frame))*(_contentViewScaleValue-1)+1;
        _contentViewContainer.center = CGPointMake(centreX, kScreenHeight/2);
        
        
        [self addContentCoverView];
        CGFloat menuCenterX = _menuStartCentreX+dis/2;
        menuCenterX = menuCenterX>=_menuEndCentreX?_menuEndCentreX:menuCenterX;
        menuCenterX = menuCenterX<=_menuStartCentreX?_menuStartCentreX:menuCenterX;
        
        menuProportion = dis/2/(_menuEndCentreX-_menuStartCentreX)*(1-kMenuMinScale)+kMenuMinScale;
        menuProportion = menuProportion>=1?1:menuProportion;
        menuProportion = menuProportion<=kMenuMinScale?kMenuMinScale:menuProportion;
        _menuViewContainer.center = CGPointMake(menuCenterX, kScreenHeight/2);
        if (self.menuDisplayType == MenuDisPlayModeScale) {
            
            _contentViewContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
            _menuViewContainer.transform = CGAffineTransformMakeScale(menuProportion, menuProportion);
        }
    }else{
        
        if (!_rightMenuViewController || beforeTag == 1) {
            return;
        }
        // 禁止在主界面的时候向右滑动
        if (!_visible && point.x > 0)
        {
            
//                    NSLog(@"禁止在主界面的时候向左滑动");
            [self hideMenuViewControllerWithAnimationDuration:0];
            return;
        }
        //禁止在menu显示到最大的时候向左滑动
        if (_contentViewContainer.center.x <= _contentMinCentreX && point.x<0 && _visible)
        {
//                    NSLog(@"禁止在menu显示到最大的时候向右滑动");
            [self showLeftMenuViewControllerWithAnimationDuration:0];
            return;
        }
        if (velocity >= 800 && !_visible)
        {
//                    NSLog(@"手速太快，直接显示");
            [self showRightMenuViewController];
            return;
        }
        else if (velocity <= -800 && _visible)
        {
//                    NSLog(@"手速太快，直接隐藏");
            [self hideMenuViewController];
            return;
        }
        CGFloat dis = self.distanceVariable - point.x;
        // 当手势停止时执行操作
        if (pangesture.state == UIGestureRecognizerStateEnded)
        {
            //移动距离超过一半的情况
            if (dis >= kScreenWidth * self.percentOfMenu/2)
            {
                CGFloat distance = kScreenWidth*self.percentOfMenu - CGRectGetMinX(_contentViewContainer.frame);
                NSTimeInterval duration = distance/kScreenWidth*_animationDuration;
                [self showRightMenuViewControllerWithAnimationDuration:duration];
            }
            else if(dis < kScreenWidth * self.percentOfMenu/2)
            {
                CGFloat duration = CGRectGetMinX(_contentViewContainer.frame)/kScreenWidth*_animationDuration;
                [self hideMenuViewControllerWithAnimationDuration:duration];
            }
            return;
        }
        if (pangesture.state == UIGestureRecognizerStateBegan)
        {
            if (point.x < 0)
            {
                if (!self.visible)
                {
                    [self transitionToLeftViewController:NO];
                    [self postNSNotification:RightSlideMenuWillShowNotification];
                }
            }
            else if (point.x > 0)
            {
                if (self.visible)
                {
                    [self postNSNotification:RightSlideMenuWillHideNotification];
                }
            }
            beforeTag = _isLeft;
        }
        CGFloat centreX = self.view.center.x-dis;
        centreX = centreX <= _contentMinCentreX?_contentMinCentreX:centreX;
        centreX = centreX >= self.view.center.x?self.view.center.x:centreX;
        
        dis = -(centreX-self.view.center.x);
        CGFloat proportion = dis/ceil((_contentMinCentreX-CGRectGetMidX(self.view.frame)))*(1-_contentViewScaleValue)+1;
        _contentViewContainer.center = CGPointMake(centreX, kScreenHeight/2);
        
        
        [self addContentCoverView];
        CGFloat menuCenterX = _menuStartCentreX+dis/2;
        menuCenterX = menuCenterX<=_rightMenuEndCentreX?_rightMenuEndCentreX:menuCenterX;
        menuCenterX = menuCenterX>=_rightMenuStartCentreX?_rightMenuStartCentreX:menuCenterX;
        
        menuProportion = dis/2/(_rightMenuStartCentreX-_rightMenuEndCentreX)*(1-kMenuMinScale)+kMenuMinScale;
        menuProportion = menuProportion>=1?1:menuProportion;
        menuProportion = menuProportion<=kMenuMinScale?kMenuMinScale:menuProportion;
        _menuViewContainer.center = CGPointMake(menuCenterX, kScreenHeight/2);
        if (self.menuDisplayType == MenuDisPlayModeScale) {
            
            _contentViewContainer.transform = CGAffineTransformScale(CGAffineTransformIdentity, proportion, proportion);
            _menuViewContainer.transform = CGAffineTransformMakeScale(menuProportion, menuProportion);
            
        }
    }
    //背景图片设置缩放动画
    if (self.scaleBackgroundImageView)
    {
        CGFloat bgScale = 1;
        if (self.bgZoomSmaller) {
            
            bgScale = kBgImageMaxScale-(kBgImageMaxScale-1)*menuProportion;
        }else{
            
            bgScale = (kBgImageMaxScale-1)*menuProportion+1;
            
        }
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
        [self hideMenuViewControllerWithAnimationDuration:0];
        [naviCtr pushViewController:viewController animated:YES];
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
