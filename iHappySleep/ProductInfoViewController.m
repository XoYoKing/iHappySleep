//
//  ProductInfoViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/25.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "ProductInfoViewController.h"
#import "myHeader.h"

@interface ProductInfoViewController ()

@end

@implementation ProductInfoViewController
{
    NSArray *infoArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    UIImageView *productInfoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
    [productInfoImageView setImage:[UIImage imageNamed:@"product_info_bg.png"]];
    [self.view addSubview:productInfoImageView];
    
    UITableView *infoTableView=[[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, SCREEN_HEIGHT*2/3, SCREEN_WIDTH*4/5, SCREEN_HEIGHT*4/5) style:UITableViewStylePlain];
    if (SCREEN_WIDTH==320)
    {
        infoTableView.frame=CGRectMake(SCREEN_WIDTH/15, SCREEN_HEIGHT*2/3, SCREEN_WIDTH*13/15, SCREEN_HEIGHT*4/5);
    }
    infoTableView.separatorStyle=UITableViewCellSeparatorStyleNone;
    infoTableView.tableFooterView=[[UIView alloc] init];
    infoTableView.delegate=self;
    infoTableView.dataSource=self;
    [self.view addSubview:infoTableView];
    
    infoArray=@[@"上海诺之嘉医疗器械有限公司",@"产品名称：疗疗失眠",@"网       址：www.nuozhijia.com.cn",@"服务热线：400-680-0272",@"版  本  号：V1.0.0.4"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 5;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 30;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:15]];
    cell.textLabel.text=[infoArray objectAtIndex:indexPath.row];
    
    return cell;
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
