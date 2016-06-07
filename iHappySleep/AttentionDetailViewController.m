//
//  AttentionDetailViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/29.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "AttentionDetailViewController.h"
#import "myHeader.h"

@interface AttentionDetailViewController ()

@end

@implementation AttentionDetailViewController
{
    UITableView *myTableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    myTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    myTableView.tableFooterView=[[UIView alloc] init];
    myTableView.delegate=self;
    myTableView.dataSource=self;
    
    [self.view addSubview:myTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
        if (_index==1)
        {
            return 1.5*cell.frame.size.height;
        }
        else
        {
            return cell.frame.size.height;
        }
    }
    else
    {
        if (SCREEN_HEIGHT==480)
        {
            if (_index==0)
            {
                return SCREEN_HEIGHT/3;
            }
            else if (_index==1)
            {
                return SCREEN_HEIGHT/4;
            }
            else if (_index==2)
            {
                return SCREEN_HEIGHT/7;
            }
            else
            {
                return SCREEN_HEIGHT/10;
            }
        }
        else if (SCREEN_HEIGHT==568)
        {
            if (_index==0)
            {
                return SCREEN_HEIGHT/3.5;
            }
            else if (_index==1)
            {
                return SCREEN_HEIGHT/5;
            }
            else if (_index==2)
            {
                return SCREEN_HEIGHT/8;
            }
            else
            {
                return SCREEN_HEIGHT/10;
            }
        }
        else if (SCREEN_HEIGHT==667)
        {
            if (_index==0)
            {
                return SCREEN_HEIGHT/3.5;
            }
            else if (_index==1)
            {
                return SCREEN_HEIGHT/6;
            }
            else if (_index==2)
            {
                return SCREEN_HEIGHT/8;
            }
            else
            {
                return SCREEN_HEIGHT/10;
            }
        }
        else
        {
            if (_index==0)
            {
                return SCREEN_HEIGHT/3.5;
            }
            else if (_index==1)
            {
                return SCREEN_HEIGHT/6.5;
            }
            else if (_index==2)
            {
                return SCREEN_HEIGHT/8;
            }
            else
            {
                return SCREEN_HEIGHT/10;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"AttentionAnswer";
    
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
    cell.textLabel.numberOfLines=0;
    
    if (indexPath.row==0)
    {
        cell.textLabel.text=[_questionAndAnswer objectForKey:@"question"];
    }
    else if (indexPath.row==1)
    {
        cell.textLabel.textColor=UIColorWithRGBA(20.0f, 80.0f, 200.0f, 0.7f);
        cell.textLabel.text=[_questionAndAnswer objectForKey:@"answer"];
    }
    
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
