//
//  MoreViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/9/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "MoreViewController.h"
#import "myHeader.h"
#import "EvaluateDataViewController.h"
#import "TreatDataViewController.h"
#import "SelfInfoViewController.h"

@interface MoreViewController ()

@end

@implementation MoreViewController
{
    UITableView *MoreTableView;
    NSArray *MoreTableViewArray;
    
    UIAlertView *alert;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    MoreTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
    MoreTableView.tableFooterView=[[UIView alloc] init];
    MoreTableView.tag=1;
    MoreTableView.delegate=self;
    MoreTableView.dataSource=self;
    [self.view addSubview:MoreTableView];
    
    MoreTableViewArray=[NSArray arrayWithObjects:@"评估数据",@"治疗数据",@"睡眠医院",@"我的资料", nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return SCREEN_WIDTH*2/15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"MoreTableViewCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/15, SCREEN_HEIGHT/60, SCREEN_WIDTH/14, SCREEN_WIDTH/14)];
    if (indexPath.row==0)
    {
        [imageview setImage:[UIImage imageNamed:@"more_access"]];
    }
    else if (indexPath.row==1)
    {
        [imageview setImage:[UIImage imageNamed:@"more_cure"]];
    }
    else if (indexPath.row==2)
    {
        [imageview setImage:[UIImage imageNamed:@"more_hospital"]];
    }
    else if (indexPath.row==3)
    {
        [imageview setImage:[UIImage imageNamed:@"more_basic"]];
    }
    
    UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6, SCREEN_HEIGHT/35, SCREEN_WIDTH/4, SCREEN_WIDTH/30)];
    if (SCREEN_WIDTH==320)
    {
        label.font=[UIFont systemFontOfSize:20];
    }
    else
    {
        label.font=[UIFont systemFontOfSize:22.5];
    }
    label.text=[MoreTableViewArray objectAtIndex:indexPath.row];
    
    [cell.contentView addSubview:imageview];
    [cell.contentView addSubview:label];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        //跳转到评估数据查看界面
        EvaluateDataViewController *evaluateData=[[EvaluateDataViewController alloc] initWithNibName:@"EvaluateDataViewController" bundle:nil];
        //三级子界面导航控制器的返回按钮的title修改不了，通过设置代理在ViewController中修改
        [self.delegate alterBackBarButtonItemTitle:@"评估数据"];
        
        evaluateData.patientInfo=_patientInfo;
        [self.navigationController pushViewController:evaluateData animated:YES];
    }
    else if (indexPath.row==1)
    {
        //跳转到治疗数据查看界面
        TreatDataViewController *treatData=[[TreatDataViewController alloc] initWithNibName:@"TreatDataViewController" bundle:nil];
        //三级子界面导航控制器的返回按钮的title修改不了，通过设置代理在ViewController中修改
        [self.delegate alterBackBarButtonItemTitle:@"治疗数据"];
        
        treatData.patientInfo=_patientInfo;
        [self.navigationController pushViewController:treatData animated:YES];
    }
    else if (indexPath.row==2)
    {
        //睡眠医院
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"暂未开放" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        [alert show];
    }
    else if (indexPath.row==3)
    {
        //我的资料
        SelfInfoViewController *selfInfoController=[[SelfInfoViewController alloc] initWithNibName:@"SelfInfoViewController" bundle:nil];
        [self.delegate alterBackBarButtonItemTitle:@"我的资料"];
        
        selfInfoController.patientInfo=_patientInfo;
        [self.navigationController pushViewController:selfInfoController animated:YES];
    }
}

//alertview自动消失
- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}

- (void)didReceiveMemoryWarning
{
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
