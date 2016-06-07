//
//  AboutViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/1.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "AboutViewController.h"
#import "myHeader.h"
#import "MethodViewController.h"
#import "PrincipleViewController.h"
#import "AttentionViewController.h"
#import "ProductInfoViewController.h"

@interface AboutViewController ()

@end

@implementation AboutViewController
{
    NSArray *aboutArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBar.translucent=YES;
    
    _aboutTableView.contentInset=UIEdgeInsetsMake(-64, 0, 0, 0);
    _aboutTableView.tableFooterView=[[UIView alloc] init];
    _aboutTableView.delegate=self;
    _aboutTableView.dataSource=self;
    
    aboutArray=@[@"使用方法",@"治疗原理",@"注意事项",@"产品信息"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return aboutArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"AboutTableViewCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    if (SCREEN_WIDTH==320)
    {
        cell.textLabel.font=[UIFont systemFontOfSize:18];
    }
    else if (SCREEN_WIDTH==375)
    {
        cell.textLabel.font=[UIFont systemFontOfSize:20];
    }
    else
    {
        cell.textLabel.font=[UIFont systemFontOfSize:22];
    }
    cell.textLabel.text=[aboutArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        //跳转使用方法界面
        MethodViewController *method=[[MethodViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"使用方法";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:method animated:YES];
    }
    else if (indexPath.row==1)
    {
        //跳转治疗原理界面
        PrincipleViewController *principle=[[PrincipleViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"使用方法";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:principle animated:YES];
    }
    else if (indexPath.row==2)
    {
        //跳转注意事项界面
        AttentionViewController *attention=[[AttentionViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"注意事项";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:attention animated:YES];
    }
    else if (indexPath.row==3)
    {
        //跳转产品信息界面
        ProductInfoViewController *productInfo=[[ProductInfoViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"产品信息";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:productInfo animated:YES];
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
