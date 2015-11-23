//
//  HomeViewController.m
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "HomeViewController.h"
#import "UIViewController+LeftSlideMenu.h"
#import "PushViewController.h"

@interface HomeViewController ()
{
    UIButton *btn;
}
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.title = @"Home";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Menu"
                                                                             style:UIBarButtonItemStylePlain
                                                                            target:self
                                                                            action:@selector(func:)];
    
    btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"push to other viewController" forState:UIControlStateNormal];
    [btn setBackgroundColor:[UIColor redColor]];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    [btn addTarget:self action:@selector(btn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-40-[btn]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-200-[btn(50)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(btn)]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willShowLeftMenuController) name:LeftSlideMenuWillShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didShowLeftMenuController) name:LeftSlideMenuDidShowNotification object:nil];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideLeftMenuController) name:LeftSlideMenuWillHideNotification object:nil];
//     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didHideLeftMenuController) name:LeftSlideMenuDidHideNotification object:nil];
}
- (void)btn
{
    PushViewController *ctr = [[PushViewController alloc] init];
    ctr.title = @"fromHome";
    [self.navigationController pushViewController:ctr animated:YES];
}
- (void)func:(UIBarButtonItem *)item
{
    [self showLeftMenuViewController];
}


- (void)willShowLeftMenuController
{
    NSLog(@"willShowLeftMenuController");
}
- (void)didShowLeftMenuController
{
    NSLog(@"didShowLeftMenuController");
}
- (void)willHideLeftMenuController
{
    NSLog(@"willHideLeftMenuController");
}
- (void)didHideLeftMenuController
{
    NSLog(@"didHideLeftMenuController");
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
