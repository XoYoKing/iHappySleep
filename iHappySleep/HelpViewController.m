//
//  HelpViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/7.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "HelpViewController.h"
#import "myHeader.h"
#import "ConfigRequireViewController.h"
#import "ClinicalUseViewController.h"
#import "SoftwareOptionViewController.h"
#import "CommonProViewController.h"
#import "RelatedConsumViewController.h"

@interface HelpViewController ()

@end

@implementation HelpViewController
{
    NSArray *helpArray;
    
    NSArray *configRequireArray;
    NSArray *clinicalUseArray;
    NSArray *softwareOptionArray;
    NSArray *commonProArray;
    NSArray *relatedConsumArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    _helpTableView.contentInset=UIEdgeInsetsMake(-64, 0, 0, 0);
    _helpTableView.delegate=self;
    _helpTableView.dataSource=self;
    
    helpArray=@[@"配置要求",@"临床使用",@"软件操作",@"常见问题",@"相关耗材"];
    
    NSString *plistPath=[[NSBundle mainBundle] pathForResource:@"HelpInfo" ofType:@"plist"];
    NSDictionary *helpInfoDic=[[NSDictionary alloc] initWithContentsOfFile:plistPath];
    configRequireArray=[helpInfoDic objectForKey:@"配置要求"];
    clinicalUseArray=[helpInfoDic objectForKey:@"临床使用"];
    softwareOptionArray=[helpInfoDic objectForKey:@"软件操作"];
    commonProArray=[helpInfoDic objectForKey:@"常见问题"];
    relatedConsumArray=[helpInfoDic objectForKey:@"相关耗材"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return helpArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"HelpTableViewCell";
    
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
    cell.textLabel.text=[helpArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        //跳转到配置要求问题界面
        ConfigRequireViewController *configRequire=[[ConfigRequireViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"配置要求";
        [temporaryBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        
        configRequire.configRequireArray=configRequireArray;
        [self.navigationController pushViewController:configRequire animated:YES];
    }
    else if (indexPath.row==1)
    {
        //跳转到临床使用问题界面
        ClinicalUseViewController *clinicalUse=[[ClinicalUseViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"临床使用";
        [temporaryBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        
        clinicalUse.clinicalUseArray=clinicalUseArray;
        [self.navigationController pushViewController:clinicalUse animated:YES];
    }
    else if (indexPath.row==2)
    {
        //跳转到软件操作问题界面
        SoftwareOptionViewController *softwareOption=[[SoftwareOptionViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"软件操作";
        [temporaryBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        
        softwareOption.softwareOptionArray=softwareOptionArray;
        [self.navigationController pushViewController:softwareOption animated:YES];
    }
    else if (indexPath.row==3)
    {
        //跳转到常见问题问题界面
        CommonProViewController *commonPro=[[CommonProViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"常见问题";
        [temporaryBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        
        commonPro.commonProArray=commonProArray;
        [self.navigationController pushViewController:commonPro animated:YES];
    }
    else if (indexPath.row==4)
    {
        //跳转到相关耗材问题界面
        RelatedConsumViewController *relatedConsum=[[RelatedConsumViewController alloc] init];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"相关耗材";
        [temporaryBarButtonItem setTintColor:[UIColor whiteColor]];
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        
        relatedConsum.relatedConsumArray=relatedConsumArray;
        [self.navigationController pushViewController:relatedConsum animated:YES];
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
