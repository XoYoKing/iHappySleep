//
//  SoftwareAnswerViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/20.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "SoftwareAnswerViewController.h"
#import "myHeader.h"

@interface SoftwareAnswerViewController ()

@end

@implementation SoftwareAnswerViewController
{
    UITableView *softwareAnswerTableView;
    NSArray *questionAndAnswer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    softwareAnswerTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    softwareAnswerTableView.tableFooterView=[[UIView alloc] init];
    softwareAnswerTableView.delegate=self;
    softwareAnswerTableView.dataSource=self;
    
    [self.view addSubview:softwareAnswerTableView];
    
    questionAndAnswer=[NSArray arrayWithObjects:[_answerDic objectForKey:@"Question"],[_answerDic objectForKey:@"Answer"], nil];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return questionAndAnswer.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0)
    {
        UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
        if (_questionIndex==2 || _questionIndex==4 || _questionIndex==5)
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
            if (_questionIndex==0)
            {
                return SCREEN_HEIGHT/6;
            }
            else if (_questionIndex==4)
            {
                return SCREEN_HEIGHT/5;
            }
            else if (_questionIndex==1)
            {
                return SCREEN_HEIGHT/10;
            }
            else if (_questionIndex==2 || _questionIndex==3 || _questionIndex==5)
            {
                return SCREEN_HEIGHT/7;
            }
            else if (_questionIndex==6)
            {
                return SCREEN_HEIGHT/3;
            }
            else if (_questionIndex==7)
            {
                return SCREEN_HEIGHT/3.5;
            }
            else
            {
                UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
                return cell.frame.size.height;
            }
        }
        else if (SCREEN_HEIGHT==568)
        {
            if (_questionIndex==0)
            {
                return SCREEN_HEIGHT/7;
            }
            else if (_questionIndex==4)
            {
                return SCREEN_HEIGHT/6;
            }
            else if (_questionIndex==1)
            {
                return SCREEN_HEIGHT/12;
            }
            else if ( _questionIndex==2 || _questionIndex==3 || _questionIndex==5)
            {
                return SCREEN_HEIGHT/7;
            }
            else if (_questionIndex==6)
            {
                return SCREEN_HEIGHT/3.5;
            }
            else if (_questionIndex==7)
            {
                return SCREEN_HEIGHT/4;
            }
            else
            {
                UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
                return cell.frame.size.height;
            }
        }
        else
        {
            if (_questionIndex==0)
            {
                return SCREEN_HEIGHT/8;
            }
            else if (_questionIndex==4)
            {
                return SCREEN_HEIGHT/6;
            }
            else if (_questionIndex==1)
            {
                return SCREEN_HEIGHT/10;
            }
            else if (_questionIndex==2 || _questionIndex==3 || _questionIndex==5)
            {
                return SCREEN_HEIGHT/8;
            }
            else if (_questionIndex==6)
            {
                return SCREEN_HEIGHT/3.7;
            }
            else if (_questionIndex==7)
            {
                return SCREEN_HEIGHT/4.5;
            }
            else
            {
                UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
                return cell.frame.size.height;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"SoftwareAnswer";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    cell.textLabel.numberOfLines=0;
    cell.textLabel.text=[questionAndAnswer objectAtIndex:indexPath.row];
    if (indexPath.row==1)
    {
        cell.textLabel.textColor=UIColorWithRGBA(20.0f, 80.0f, 200.0f, 0.7f);
    }
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
