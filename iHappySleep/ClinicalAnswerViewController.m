//
//  ClinicalAnswerViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/20.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "ClinicalAnswerViewController.h"
#import "myHeader.h"

@interface ClinicalAnswerViewController ()

@end

@implementation ClinicalAnswerViewController
{
    UITableView *clinicalAnswerTableView;
    NSArray *questionAndAnswer;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    clinicalAnswerTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
    clinicalAnswerTableView.tableFooterView=[[UIView alloc] init];
    clinicalAnswerTableView.delegate=self;
    clinicalAnswerTableView.dataSource=self;
    
    [self.view addSubview:clinicalAnswerTableView];
    
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
        if (_questionIndex==0 || _questionIndex==3 || _questionIndex==4 || _questionIndex==5)
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
            if (_questionIndex==0 ||_questionIndex==5)
            {
                return SCREEN_HEIGHT*7/15;
            }
            else if (_questionIndex==1 || _questionIndex==4)
            {
                return SCREEN_HEIGHT*3.5/15;
            }
            else if (_questionIndex==2)
            {
                return SCREEN_HEIGHT*10/24;
            }
            else if (_questionIndex==3)
            {
                return SCREEN_HEIGHT*1.7/5;
            }
            else if (_questionIndex==6)
            {
                return SCREEN_HEIGHT*11/30;
            }
            else
            {
                UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
                return cell.frame.size.height;
            }
        }
        else if (SCREEN_HEIGHT==568)
        {
            if (_questionIndex==0 ||_questionIndex==5)
            {
                return SCREEN_HEIGHT*6/15;
            }
            else if (_questionIndex==1 || _questionIndex==4)
            {
                return SCREEN_HEIGHT*3/15;
            }
            else if (_questionIndex==2)
            {
                return SCREEN_HEIGHT*9/24;
            }
            else if (_questionIndex==3)
            {
                return SCREEN_HEIGHT*1.5/5;
            }
            else if (_questionIndex==6)
            {
                return SCREEN_HEIGHT*9/30;
            }
            else
            {
                UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
                return cell.frame.size.height;
            }
        }
        else if (SCREEN_HEIGHT==667)
        {
            if (_questionIndex==0 ||_questionIndex==5)
            {
                return SCREEN_HEIGHT*5.5/15;
            }
            else if (_questionIndex==1)
            {
                return SCREEN_HEIGHT*3/15;
            }
            else if (_questionIndex==2)
            {
                return SCREEN_HEIGHT*8/24;
            }
            else if (_questionIndex==3)
            {
                return SCREEN_HEIGHT*1.4/5;
            }
            else if (_questionIndex==4)
            {
                return SCREEN_HEIGHT*2.5/15;
            }
            else if (_questionIndex==6)
            {
                return SCREEN_HEIGHT*8/30;
            }
            else
            {
                UITableViewCell *cell=[self tableView:tableView cellForRowAtIndexPath:indexPath];
                return cell.frame.size.height;
            }
        }
        else
        {
            if (_questionIndex==0 || _questionIndex==5)
            {
                return SCREEN_HEIGHT*5.5/15;
            }
            else if (_questionIndex==1)
            {
                return SCREEN_HEIGHT*2.7/15;
            }
            else if (_questionIndex==2)
            {
                return SCREEN_HEIGHT*8/24;
            }
            else if (_questionIndex==3)
            {
                return SCREEN_HEIGHT*1.3/5;
            }
            else if (_questionIndex==4)
            {
                return SCREEN_HEIGHT*2.5/15;
            }
            else if (_questionIndex==6)
            {
                return SCREEN_HEIGHT*8/30;
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
    static NSString *identify=@"ClinicalAnswer";
    
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
