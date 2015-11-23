//
//  ViewController.m
//  CustomLeftSideMenu
//
//  Created by 龙章辉 on 15/11/19.
//  Copyright © 2015年 Peter. All rights reserved.
//

#import "LeftViewController.h"
#import "PushViewController.h"
#import "UIViewController+LeftSlideMenu.h"
#import "AppDelegate.h"

@interface LeftViewController ()<UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UITableView *tableView;
@end

@implementation LeftViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor clearColor]];
    _tableView = [[UITableView alloc] init];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    _tableView.translatesAutoresizingMaskIntoConstraints = NO;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.tableFooterView = [UIView new];
    [_tableView setBackgroundColor:[UIColor clearColor]];
//    _tableView.layer.shouldRasterize = YES;
    [self.view addSubview:_tableView];
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
     [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-100-[_tableView]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_tableView)]];
}

#pragma mark UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"cell%zi",indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:18.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setBackgroundColor:[UIColor clearColor]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    PushViewController *ctr = [[PushViewController alloc] init];
    ctr.title = [NSString stringWithFormat:@"cell%zi",indexPath.row];
    [self pushLeftMenuViewController:ctr animated:YES];
//    AppDelegate *tmpAppDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [tmpAppDelegate.navigationController pushViewController:ctr animated:YES];
////    [self.navigationController pushViewController:ctr animated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
