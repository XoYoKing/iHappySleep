//
//  AssessmentViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 16/3/2.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import "AssessmentViewController.h"
#import "myHeader.h"
#import "DataBaseOpration.h"

@interface AssessmentViewController ()<UITableViewDelegate,UITableViewDataSource>

@end

@implementation AssessmentViewController
{
    NSArray *SleepQuestionArray;           //存储睡眠量表测试的问题数组
    NSArray *DepressedQuestionArray;       //存储抑郁量表测试的问题数组
    NSArray *WorriedQuestionArray;         //存储焦虑量表测试的问题数组
    NSArray *BodyQuestionArray;            //存储躯体量表测试的问题数组
    
    NSInteger questionIndex;               //记录答到哪一题(即界面显示哪一题)
    
    UIProgressView *myProgressView;        //进度条
    UILabel *percentLabel;                 //现实百分比的Label
    
    NSInteger hourIndex;                   //记住pickerview选择的小时在_dateHourArray中的索引
    NSInteger minuteIndex;                 //记住pickerview选择的小时在_dateMinuteArray中的索引
    UIButton *sureButton;
    UITableView *QuestionChooseTableView;  //显示题目选项的tableview
    UIButton *QuestionImageButton;         //标志是否选中哪项答案
    NSMutableArray *QuestionImageButtonArray;//存储评估标志QuestionImageButton的数组
    
    UIButton *tmpButton;                   //存储被点击的选项按钮
    
    NSMutableArray *resultArray;           //存储量表测试选项的结果
    NSMutableArray *initArray;             //存储选择的量表初始化数组
    
    NSInteger Mark;                        //记录测评的分数
    
    UIAlertView *alert;                    //提示答完该题才可进入下一题
    
    DataBaseOpration *dbOption;            //数据库对象全局变量
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
//    self.navigationController.navigationBar.translucent=YES;
    self.extendedLayoutIncludesOpaqueBars=NO;
    self.edgesForExtendedLayout=UIRectEdgeBottom|UIRectEdgeLeft|UIRectEdgeRight;
    
    QuestionImageButtonArray=[NSMutableArray array];
    resultArray=[NSMutableArray array];
    
    _dateHourArray=[NSMutableArray array];
    _dateMinuteArray=[NSMutableArray array];
    for (int i=0; i<24; i++)
    {
        NSString *hour=[NSString stringWithFormat:@"%.2d",i];
        [_dateHourArray addObject:hour];
    }
    for (int i=0; i<60; i++)
    {
        NSString *minute=[NSString stringWithFormat:@"%.2d",i];
        [_dateMinuteArray addObject:minute];
    }
    
    //获取项目下的plist文件路径
    NSString *projectPath=[[NSBundle mainBundle] pathForResource:@"AnswerList" ofType:@"plist"];
    NSDictionary *questionDic=[NSDictionary dictionaryWithContentsOfFile:projectPath];
    if (_tableListTag==1)
    {
        SleepQuestionArray=[NSArray arrayWithArray:[questionDic objectForKey:@"SleepList"]];
        
        NSString *sleepTipsPath=[[NSBundle mainBundle] pathForResource:@"SleepTipsList" ofType:@"plist"];
        _sleepTipsArray=[NSArray arrayWithContentsOfFile:sleepTipsPath];
        _sleepTipsResultArray=[NSMutableArray array];
        
        //添加测试题目
        questionIndex=0;
        resultArray=[NSMutableArray array];
        initArray=[NSMutableArray array];
        for (int i=0; i<SleepQuestionArray.count; i++)
        {
            if (i==0)
            {
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                NSString *strHour=@"21";
                NSString *strMinutes=@"30";
                [dic setObject:strHour forKey:@"时"];
                [dic setObject:strMinutes forKey:@"分"];
                [resultArray addObject:dic];
                [initArray addObject:dic];
            }
            else if (i==1)
            {
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                NSString *strHour=@"00";
                NSString *strMinutes=@"30";
                [dic setObject:strHour forKey:@"时"];
                [dic setObject:strMinutes forKey:@"分"];
                [resultArray addObject:dic];
                [initArray addObject:dic];
            }
            else if (i==2 || i==3)
            {
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                NSString *strHour=@"07";
                NSString *strMinutes=@"30";
                [dic setObject:strHour forKey:@"时"];
                [dic setObject:strMinutes forKey:@"分"];
                [resultArray addObject:dic];
                [initArray addObject:dic];
            }
            else
            {
                NSString *str=@"4";
                [resultArray addObject:str];
                [initArray addObject:str];
            }
        }
        [self addSleepListView];
    }
    else if (_tableListTag==2)
    {
        DepressedQuestionArray=[NSArray arrayWithArray:[questionDic objectForKey:@"DepressedList"]];
        
        //添加测试题目
        questionIndex=0;
        resultArray=[NSMutableArray array];
        initArray=[NSMutableArray array];
        for (int i=0; i<DepressedQuestionArray.count; i++)
        {
            NSString *str=@"4";
            [resultArray addObject:str];
            [initArray addObject:str];
        }
        [self addDepressedListView];
    }
    else if (_tableListTag==3)
    {
        WorriedQuestionArray=[NSArray arrayWithArray:[questionDic objectForKey:@"WorriedList"]];
        
        //添加测试题目
        resultArray=[NSMutableArray array];
        initArray=[NSMutableArray array];
        for (int i=0; i<WorriedQuestionArray.count; i++)
        {
            NSString *str=@"4";
            [resultArray addObject:str];
            [initArray addObject:str];
        }
        [self addWorriedListView];
    }
    else if (_tableListTag==4)
    {
        BodyQuestionArray=[NSArray arrayWithArray:[questionDic objectForKey:@"BodyList"]];
        
        //添加测试题目
        resultArray=[NSMutableArray array];
        initArray=[NSMutableArray array];
        for (int i=0; i<BodyQuestionArray.count; i++)
        {
            NSString *str=@"4";
            [resultArray addObject:str];
            [initArray addObject:str];
        }
        [self addBodyListView];
    }
}

//添加tableview
-(void)addTableView
{
    [QuestionImageButtonArray removeAllObjects];
    
    if (SCREEN_HEIGHT==480)
    {
        QuestionChooseTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/3.5, SCREEN_WIDTH, SCREEN_HEIGHT/2.5)];
    }
    else
    {
        QuestionChooseTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/3, SCREEN_WIDTH, SCREEN_HEIGHT/3)];
    }
    QuestionChooseTableView.backgroundColor=[UIColor whiteColor];
    QuestionChooseTableView.tableFooterView=[[UIView alloc] init];           //不显示没有内容的cell
    QuestionChooseTableView.scrollEnabled=NO;
    QuestionChooseTableView.tag=_tableListTag;
    QuestionChooseTableView.delegate=self;
    QuestionChooseTableView.dataSource=self;
    [self.view addSubview:QuestionChooseTableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==4)
    {
        return 3;
    }
    else
    {
        return 4;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"QuestionCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    
    QuestionImageButton=[[UIButton alloc] initWithFrame:CGRectMake(10, 0, 30,40)];
    QuestionImageButton.tag=indexPath.row;
    if ([[resultArray objectAtIndex:questionIndex] intValue]==indexPath.row)
    {
        [QuestionImageButton setImage:[UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
    }
    else
    {
        [QuestionImageButton setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
    }
    [QuestionImageButton addTarget:self action:@selector(chooseAnswer:) forControlEvents: UIControlEventTouchUpInside];
    [QuestionImageButtonArray addObject:QuestionImageButton];
    
    UILabel *answersLabel=[[UILabel alloc] initWithFrame:CGRectMake(50, 0, SCREEN_WIDTH*3/5, 40)];
    if (tableView.tag==1)
    {
        if (questionIndex!=14 && questionIndex!=17)
        {
            if (indexPath.row==0)
            {
                answersLabel.text=@"无";
            }
            else if (indexPath.row==1)
            {
                answersLabel.text=@"<1次/周";
            }
            else if (indexPath.row==2)
            {
                answersLabel.text=@"<1-2次/周";
            }
            else if (indexPath.row==3)
            {
                answersLabel.text=@">=3次/周";
            }
        }
        else if(questionIndex==14)
        {
            if (indexPath.row==0)
            {
                answersLabel.text=@"很好";
            }
            else if (indexPath.row==1)
            {
                answersLabel.text=@"较好";
            }
            else if (indexPath.row==2)
            {
                answersLabel.text=@"较差";
            }
            else if (indexPath.row==3)
            {
                answersLabel.text=@"很差";
            }
        }
        else if(questionIndex==17)
        {
            if (indexPath.row==0)
            {
                answersLabel.text=@"没有";
            }
            else if (indexPath.row==1)
            {
                answersLabel.text=@"偶尔有";
            }
            else if (indexPath.row==2)
            {
                answersLabel.text=@"有时有";
            }
            else if (indexPath.row==3)
            {
                answersLabel.text=@"经常有";
            }
        }
    }
    else if (tableView.tag==2 || tableView.tag==3)
    {
        if (indexPath.row==0)
        {
            answersLabel.text=@"完全不会";
        }
        else if (indexPath.row==1)
        {
            answersLabel.text=@"好几天";
        }
        else if (indexPath.row==2)
        {
            answersLabel.text=@"超过一周";
        }
        else if (indexPath.row==3)
        {
            answersLabel.text=@"几乎每天";
        }
    }
    else if (tableView.tag==4)
    {
        if (indexPath.row==0)
        {
            answersLabel.text=@"没有困扰";
        }
        else if (indexPath.row==1)
        {
            answersLabel.text=@"少许困扰";
        }
        else if (indexPath.row==2)
        {
            answersLabel.text=@"很多困扰";
        }
    }
    
    [cell.contentView addSubview:QuestionImageButton];
    [cell.contentView addSubview:answersLabel];
    [cell setSelected:YES animated:YES];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *btn_choose=[QuestionImageButtonArray objectAtIndex:indexPath.row];
    [self chooseAnswer:btn_choose];
}

//添加pickerview
-(void)addPickerView
{
    if (SCREEN_HEIGHT==480)
    {
        self.pickerView=[[UIPickerView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/4, SCREEN_WIDTH/3, SCREEN_HEIGHT/3)];
    }
    else
    {
        self.pickerView=[[UIPickerView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT/10+SCREEN_WIDTH/5, SCREEN_WIDTH/3, SCREEN_HEIGHT/3)];
    }
    self.pickerView.backgroundColor=[UIColor whiteColor];
    if (questionIndex<4)
    {
        NSDictionary *dic=[resultArray objectAtIndex:questionIndex];
        hourIndex=[[dic objectForKey:@"时"] intValue];
        minuteIndex=[[dic objectForKey:@"分"] intValue];
    }
    self.pickerView.delegate=self;
    self.pickerView.dataSource=self;
    
    UILabel *lb1=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/6, SCREEN_HEIGHT/7, 20, 25)];
    lb1.text=@":";
    [self.pickerView addSubview:lb1];
    [self.view addSubview:self.pickerView];
    
    [self.pickerView selectRow:hourIndex inComponent:0 animated:YES];
    [self.pickerView selectRow:minuteIndex inComponent:1 animated:YES];
    [self.pickerView reloadAllComponents];
}

#pragma pickerview的delegate和dataSource代理方法

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component==0)
    {
        return [_dateHourArray count];
    }
    else
    {
        return [_dateMinuteArray count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return _dateHourArray[row];
    }
    else
    {
        return _dateMinuteArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        hourIndex=row;
    }
    else
    {
        minuteIndex=row;
    }
}

//选择答案按钮的点击事件方法
-(void)chooseAnswer:(UIButton *)sender
{
    if (sender.tag==11)
    {
        sender.enabled=NO;
        //确定按钮的点击事件
        NSMutableDictionary *resultTimeDic=[NSMutableDictionary dictionary];
        NSString *resultHour=[NSString stringWithFormat:@"%.2ld",(long)hourIndex];
        NSString *resultMinute=[NSString stringWithFormat:@"%.2ld",(long)minuteIndex];
        [resultTimeDic setObject:resultHour forKey:@"时"];
        [resultTimeDic setObject:resultMinute forKey:@"分"];
        
        [resultArray replaceObjectAtIndex:questionIndex withObject:resultTimeDic];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(nextQuestion) userInfo:nil repeats:NO];
    }
    else
    {
        //选项按钮的点击事件
        for (UIButton *tmp in QuestionImageButtonArray)
        {
            [tmp setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        }
        [sender setImage:[UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
        
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(nextQuestion) object:sender];
        [self performSelector:@selector(nextQuestion) withObject:sender afterDelay:1.0f];
        NSString *str=[NSString stringWithFormat:@"%ld",sender.tag];
        [resultArray replaceObjectAtIndex:questionIndex withObject:str];
    }
}

//一段时间后跳转到下一题
-(void)nextQuestion
{
    if ((_tableListTag==1 && questionIndex!=0 && questionIndex!=1 && questionIndex!=2 && questionIndex!=3 && [[resultArray objectAtIndex:questionIndex] intValue]==4) || (_tableListTag!=1 && [[resultArray objectAtIndex:questionIndex] intValue]==4))
    {
        //提示答完这题才可进入下一题
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"请先答完该题" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        [alert show];
    }
    else if (_tableListTag==1 && (questionIndex==0 || questionIndex==1 || questionIndex==2 || questionIndex==3))
    {
        //确定按钮的点击事件
        NSMutableDictionary *resultTimeDic=[NSMutableDictionary dictionary];
        NSString *resultHour=[NSString stringWithFormat:@"%.2ld",(long)hourIndex];
        NSString *resultMinute=[NSString stringWithFormat:@"%.2ld",(long)minuteIndex];
        [resultTimeDic setObject:resultHour forKey:@"时"];
        [resultTimeDic setObject:resultMinute forKey:@"分"];
        
        [resultArray replaceObjectAtIndex:questionIndex withObject:resultTimeDic];
        
        questionIndex++;
        dispatch_async(dispatch_get_main_queue(), ^{
            //改变进度条以及完成百分比
            float tmp_Progress=(float)(questionIndex+1)/initArray.count;
            myProgressView.progress=tmp_Progress;
            int tmp=ceil(tmp_Progress*100);
            NSString *text=[NSString stringWithFormat:@"%d%%",tmp];
            NSLog(@"%@",text);
            percentLabel.text=text;
        });
        
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        if (_tableListTag==1)
        {
            if (questionIndex==18)
            {
                [self markForResult];
                [self addResult:resultArray];
                //创建一个消息对象
                NSNotification * notice = [NSNotification notificationWithName:@"refreshData" object:nil userInfo:nil];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
            }
            else
            {
                [self addSleepListView];
            }
        }
    }
    else
    {
        questionIndex++;
        dispatch_async(dispatch_get_main_queue(), ^{
            //改变进度条以及完成百分比
            float tmp_Progress=(float)(questionIndex+1)/initArray.count;
            myProgressView.progress=tmp_Progress;
            int tmp=ceil(tmp_Progress*100);
            NSString *text=[NSString stringWithFormat:@"%d%%",tmp];
            NSLog(@"%@",text);
            percentLabel.text=text;
        });
        
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        if (_tableListTag==1)
        {
            if (questionIndex==18)
            {
                [self markForResult];
                [self addResult:resultArray];
                //创建一个消息对象
                NSNotification * notice = [NSNotification notificationWithName:@"refreshData" object:nil userInfo:nil];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
            }
            else
            {
                [self addSleepListView];
            }
        }
        else if (_tableListTag==2)
        {
            if (questionIndex==9)
            {
                [self markForResult];
                [self addResult:resultArray];
                //创建一个消息对象
                NSNotification * notice = [NSNotification notificationWithName:@"refreshData" object:nil userInfo:nil];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
            }
            else
            {
                [self addDepressedListView];
            }
        }
        else if (_tableListTag==3)
        {
            if (questionIndex==7)
            {
                [self markForResult];
                [self addResult:resultArray];
                //创建一个消息对象
                NSNotification * notice = [NSNotification notificationWithName:@"refreshData" object:nil userInfo:nil];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
            }
            else
            {
                [self addWorriedListView];
            }
        }
        else if (_tableListTag==4)
        {
            if (questionIndex==15)
            {
                [self markForResult];
                [self addResult:resultArray];
                //创建一个消息对象
                NSNotification * notice = [NSNotification notificationWithName:@"refreshData" object:nil userInfo:nil];
                //发送消息
                [[NSNotificationCenter defaultCenter]postNotification:notice];
            }
            else
            {
                [self addBodyListView];
            }
        }
    }
}
//alertview自动消失
- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}
//上一题
-(void)beforeQuestion
{
    questionIndex--;
    dispatch_async(dispatch_get_main_queue(), ^{
        //改变进度条以及完成百分比
        float tmp_Progress=(float)(questionIndex+1)/initArray.count;
        myProgressView.progress=tmp_Progress;
        int tmp=ceil(tmp_Progress*100);
        NSString *text=[NSString stringWithFormat:@"%d%%",tmp];
        NSLog(@"%@",text);
        percentLabel.text=text;
    });
    NSArray *arr=self.view.subviews;
    for (int i=0; i<[arr count]; i++)
    {
        [[arr objectAtIndex:i] removeFromSuperview];
    }
    if (_tableListTag==1)
    {
        [self addSleepListView];
    }
    else if (_tableListTag==2)
    {
        [self addDepressedListView];
    }
    else if (_tableListTag==3)
    {
        [self addWorriedListView];
    }
    else if (_tableListTag==4)
    {
        [self addBodyListView];
    }
}

//1.添加睡眠评估量表界面
-(void)addSleepListView
{
    //添加题目完成度
    UILabel *label_finish=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/15, SCREEN_WIDTH/5, SCREEN_WIDTH/20)];
    label_finish.text=@"已完成:";
    [self.view addSubview:label_finish];
    UILabel *label_questionIndex=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4, SCREEN_HEIGHT/15, SCREEN_WIDTH/17, SCREEN_WIDTH/20)];
    label_questionIndex.textAlignment=NSTextAlignmentRight;
    label_questionIndex.text=[NSString stringWithFormat:@"%ld",(long)questionIndex+1];
    [self.view addSubview:label_questionIndex];
    UILabel *label_questionCount=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4+SCREEN_WIDTH/17, SCREEN_HEIGHT/15, SCREEN_WIDTH/10, SCREEN_WIDTH/20)];
    label_questionCount.text=[NSString stringWithFormat:@"/%lu",(unsigned long)initArray.count];
    [self.view addSubview:label_questionCount];
    
    //给睡眠评估量表界面添加问题回答进度条
    myProgressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    myProgressView.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8.7, SCREEN_WIDTH*2/3, SCREEN_WIDTH/20);
    myProgressView.trackTintColor=[UIColor greenColor];
    [self.view addSubview:myProgressView];
    percentLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, SCREEN_HEIGHT/10, SCREEN_WIDTH/6, SCREEN_WIDTH/20)];
    float tmp_Progress=(float)(questionIndex+1)/initArray.count;
    myProgressView.progress=tmp_Progress;
    int tmp=ceil(tmp_Progress*100);
    NSString *text=[NSString stringWithFormat:@"%d%%",tmp];
    percentLabel.text=text;
    [self.view addSubview:percentLabel];
    
    //添加问题Label
    UILabel *questionLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8, SCREEN_WIDTH*9/10, SCREEN_WIDTH/5)];
    questionLabel.textAlignment=NSTextAlignmentLeft;
    questionLabel.numberOfLines=0;
    questionLabel.text=[SleepQuestionArray objectAtIndex:questionIndex];
    [self.view addSubview:questionLabel];
    
    if (questionIndex==0 ||questionIndex==1 ||questionIndex==2 ||questionIndex==3 )
    {
        //添加pickerview
        [self addPickerView];
        //添加确定按钮并添加target
        sureButton=[UIButton buttonWithType:UIButtonTypeSystem];
//        if (SCREEN_HEIGHT==480)
//        {
//            sureButton.frame=CGRectMake(SCREEN_WIDTH*2/5, SCREEN_HEIGHT*5.5/9, SCREEN_WIDTH/5, SCREEN_WIDTH/16);
//        }
//        else
//        {
//            sureButton.frame=CGRectMake(SCREEN_WIDTH*2/5, SCREEN_HEIGHT*2/3, SCREEN_WIDTH/5, SCREEN_WIDTH/16);
//        }
        sureButton.frame=CGRectMake(SCREEN_WIDTH*2/5, SCREEN_HEIGHT*2/3, SCREEN_WIDTH/5, SCREEN_WIDTH/16);
        sureButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [sureButton setTitle:@"确定" forState:UIControlStateNormal];
        sureButton.tag=11;
        [sureButton addTarget:self action:@selector(chooseAnswer:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:sureButton];
    }
    else
    {
        //添加tableview
        [self addTableView];
    }
    //添加上一题和下一题按钮
    if (questionIndex==0)
    {
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*6.2/8, SCREEN_WIDTH/5, 30);
        }
        else
        {
            nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        }
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
    else if (questionIndex==17)
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*6.2/8, SCREEN_WIDTH/5, 30);
        }
        else
        {
            beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        }
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
    }
    else
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*6.2/8, SCREEN_WIDTH/5, 30);
        }
        else
        {
            beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        }
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*6.2/8, SCREEN_WIDTH/5, 30);
        }
        else
        {
            nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        }
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
    
    
}
//2.添加抑郁评估量表界面
-(void)addDepressedListView
{
    //添加题目完成度
    UILabel *label_finish=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/15, SCREEN_WIDTH/5, SCREEN_WIDTH/20)];
    label_finish.text=@"已完成:";
    [self.view addSubview:label_finish];
    UILabel *label_questionIndex=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4, SCREEN_HEIGHT/15, SCREEN_WIDTH/17, SCREEN_WIDTH/20)];
    label_questionIndex.textAlignment=NSTextAlignmentRight;
    label_questionIndex.text=[NSString stringWithFormat:@"%ld",(long)questionIndex+1];
    [self.view addSubview:label_questionIndex];
    UILabel *label_questionCount=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4+SCREEN_WIDTH/17, SCREEN_HEIGHT/15, SCREEN_WIDTH/10, SCREEN_WIDTH/20)];
    label_questionCount.text=[NSString stringWithFormat:@"/%lu",(unsigned long)initArray.count];
    [self.view addSubview:label_questionCount];
    
    //给睡眠评估量表界面添加问题回答进度条
    myProgressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    myProgressView.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8.7, SCREEN_WIDTH*2/3, SCREEN_WIDTH/20);
    myProgressView.trackTintColor=[UIColor greenColor];
    [self.view addSubview:myProgressView];
    percentLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, SCREEN_HEIGHT/10, SCREEN_WIDTH/6, SCREEN_WIDTH/20)];
    float tmp_Progress=(float)(questionIndex+1)/initArray.count;
    myProgressView.progress=tmp_Progress;
    int tmp=ceil(tmp_Progress*100);
    NSString *text=[NSString stringWithFormat:@"%d%%",tmp];
    percentLabel.text=text;
    [self.view addSubview:percentLabel];
    
    //添加问题Label
    UILabel *questionLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8, SCREEN_WIDTH*9/10, SCREEN_WIDTH/5)];
    questionLabel.textAlignment=NSTextAlignmentLeft;
    questionLabel.numberOfLines=0;
    questionLabel.text=[DepressedQuestionArray objectAtIndex:questionIndex];
    [self.view addSubview:questionLabel];
    
    
    //添加tableview
    [self addTableView];
    //添加上一题和下一题按钮
    if (questionIndex==0)
    {
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
    else if (questionIndex==8)
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
    }
    else
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
}
//3.添加焦虑评估量表界面啊
-(void)addWorriedListView
{
    //添加题目完成度
    UILabel *label_finish=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/15, SCREEN_WIDTH/5, SCREEN_WIDTH/20)];
    label_finish.text=@"已完成:";
    [self.view addSubview:label_finish];
    UILabel *label_questionIndex=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4, SCREEN_HEIGHT/15, SCREEN_WIDTH/17, SCREEN_WIDTH/20)];
    label_questionIndex.textAlignment=NSTextAlignmentRight;
    label_questionIndex.text=[NSString stringWithFormat:@"%ld",(long)questionIndex+1];
    [self.view addSubview:label_questionIndex];
    UILabel *label_questionCount=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4+SCREEN_WIDTH/17, SCREEN_HEIGHT/15, SCREEN_WIDTH/10, SCREEN_WIDTH/20)];
    label_questionCount.text=[NSString stringWithFormat:@"/%lu",(unsigned long)initArray.count];
    [self.view addSubview:label_questionCount];
    
    //给睡眠评估量表界面添加问题回答进度条
    myProgressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    myProgressView.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8.7, SCREEN_WIDTH*2/3, SCREEN_WIDTH/20);
    myProgressView.trackTintColor=[UIColor greenColor];
    [self.view addSubview:myProgressView];
    percentLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, SCREEN_HEIGHT/10, SCREEN_WIDTH/6, SCREEN_WIDTH/20)];
    float tmp_Progress=(float)(questionIndex+1)/initArray.count;
    myProgressView.progress=tmp_Progress;
    int tmp=ceil(tmp_Progress*100);
    NSString *text=[NSString stringWithFormat:@"%d%%",tmp];
    percentLabel.text=text;
    [self.view addSubview:percentLabel];
    
    //添加问题Label
    UILabel *questionLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8, SCREEN_WIDTH*9/10, SCREEN_WIDTH/5)];
    questionLabel.textAlignment=NSTextAlignmentLeft;
    questionLabel.numberOfLines=0;
    questionLabel.text=[WorriedQuestionArray objectAtIndex:questionIndex];
    [self.view addSubview:questionLabel];
    
    
    //添加tableview
    [self addTableView];
    //添加上一题和下一题按钮
    if (questionIndex==0)
    {
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
    else if (questionIndex==6)
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
    }
    else
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
}
//4.添加躯体评估量表界面
-(void)addBodyListView
{
    //添加题目完成度
    UILabel *label_finish=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/15, SCREEN_WIDTH/5, SCREEN_WIDTH/20)];
    label_finish.text=@"已完成:";
    [self.view addSubview:label_finish];
    UILabel *label_questionIndex=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4, SCREEN_HEIGHT/15, SCREEN_WIDTH/17, SCREEN_WIDTH/20)];
    label_questionIndex.textAlignment=NSTextAlignmentRight;
    label_questionIndex.text=[NSString stringWithFormat:@"%ld",(long)questionIndex+1];
    [self.view addSubview:label_questionIndex];
    UILabel *label_questionCount=[[UILabel alloc] initWithFrame:CGRectMake( SCREEN_WIDTH/4+SCREEN_WIDTH/17, SCREEN_HEIGHT/15, SCREEN_WIDTH/10, SCREEN_WIDTH/20)];
    label_questionCount.text=[NSString stringWithFormat:@"/%lu",(unsigned long)initArray.count];
    [self.view addSubview:label_questionCount];
    
    //给睡眠评估量表界面添加问题回答进度条
    myProgressView=[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    myProgressView.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8.7, SCREEN_WIDTH*2/3, SCREEN_WIDTH/20);
    myProgressView.trackTintColor=[UIColor greenColor];
    [self.view addSubview:myProgressView];
    percentLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, SCREEN_HEIGHT/10, SCREEN_WIDTH/6, SCREEN_WIDTH/20)];
    float tmp_Progress=(float)(questionIndex+1)/initArray.count;
    myProgressView.progress=tmp_Progress;
    int tmp=ceil(tmp_Progress*100);
    NSString *text=[NSString stringWithFormat:@"%d%%",tmp];
    percentLabel.text=text;
    [self.view addSubview:percentLabel];
    
    //添加问题Label
    UILabel *questionLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/8, SCREEN_WIDTH*9/10, SCREEN_WIDTH/5)];
    questionLabel.textAlignment=NSTextAlignmentLeft;
    questionLabel.numberOfLines=0;
    questionLabel.text=[BodyQuestionArray objectAtIndex:questionIndex];
    [self.view addSubview:questionLabel];
    
    
    //添加tableview
    [self addTableView];
    //添加上一题和下一题按钮
    if (questionIndex==0)
    {
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
    else if (questionIndex==14)
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
    }
    else
    {
        UIButton *beforeButton=[UIButton buttonWithType:UIButtonTypeSystem];
        beforeButton.frame=CGRectMake(0, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        beforeButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [beforeButton setTitle:@"上一题" forState:UIControlStateNormal];
        [beforeButton addTarget:self action:@selector(beforeQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:beforeButton];
        UIButton *nextButton=[UIButton buttonWithType:UIButtonTypeSystem];
        nextButton.frame=CGRectMake(SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30);
        nextButton.titleLabel.font=[UIFont systemFontOfSize:18];
        [nextButton setTitle:@"下一题" forState:UIControlStateNormal];
        [nextButton addTarget:self action:@selector(nextQuestion) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:nextButton];
    }
}
//5.添加测评结果界面
-(void)addResult:(NSMutableArray *)resultArray
{
    DataBaseOpration *opration=[[DataBaseOpration alloc] init];
    _EvaluateInfoArray=[opration getEvaluateDataFromDataBase];
    if (_tableListTag==1)
    {
        //添加睡眠评估界面
        //清除界面上的子控件
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        
        //添加评分结果界面
        UILabel *myLabelOne=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/20, SCREEN_WIDTH*9/10, SCREEN_WIDTH/20)];
        myLabelOne.textAlignment=NSTextAlignmentLeft;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        NSLog(@"%@", strDate);
        myLabelOne.text=[NSString stringWithFormat:@"评估完成时间:%@",strDate];
        [self.view addSubview:myLabelOne];
        
        UILabel *myLabelTwo=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/10, SCREEN_WIDTH*9/10, SCREEN_WIDTH/5)];
        myLabelTwo.textAlignment=NSTextAlignmentLeft;
        myLabelTwo.numberOfLines=0;
        NSString *myStrOne=[NSString string];
        NSString *myStrTwo=[NSString string];
        if (Mark>=0 && Mark<=5)
        {
            myStrOne=@"睡眠质量很好";
            myStrTwo=@"睡眠质量很好，请继续保持。";
        }
        else if (Mark>=6 && Mark<=10)
        {
            myStrOne=@"睡眠质量一般";
            myStrTwo=@"建议使用疗疗失眠进行治疗。";
        }
        else if (Mark>=11 && Mark<=15)
        {
            myStrOne=@"睡眠质量较差";
            myStrTwo=@"建议使用疗疗失眠进行治疗。";
        }
        else if (Mark>=16 && Mark<=21)
        {
            myStrOne=@"睡眠质量很差";
            myStrTwo=@"建议使用疗疗失眠进行治疗。";
        }
        myLabelTwo.text=[NSString stringWithFormat:@"你的睡眠指数为〖%ld分，%@〗。%@",(long)Mark,myStrOne,myStrTwo];
        [self.view addSubview:myLabelTwo];
        
        //添加睡眠贴士
        [self addSleepTips];
        NSString *str;
        for (int i=0; i<_sleepTipsResultArray.count; i++)
        {
            if (i==0)
            {
                str=[NSString stringWithFormat:@"%@",[_sleepTipsArray objectAtIndex:[[_sleepTipsResultArray objectAtIndex:0] intValue]-1]];
            }
            else
            {
                str=[NSString stringWithFormat:@"%@\n%@",str,[_sleepTipsArray objectAtIndex:[[_sleepTipsResultArray objectAtIndex:i] intValue]-1]];
            }
        }
        UITextView *tipsTextView=[[UITextView alloc] init];
        tipsTextView.frame=CGRectMake(10, SCREEN_HEIGHT/10+SCREEN_WIDTH/5, SCREEN_WIDTH-20, SCREEN_HEIGHT/2);
        tipsTextView.editable=NO;
        tipsTextView.font=[UIFont systemFontOfSize:15];
        tipsTextView.text=str;
        [self.view addSubview:tipsTextView];
        
        //关于保存评估数据
        if (_patientInfo.PatientID!=nil)
        {
            //保存睡眠评估数据
            EvaluateInfo *tmpEvaluate=[[EvaluateInfo alloc] init];
            tmpEvaluate.PatientID=_patientInfo.PatientID;
            tmpEvaluate.ListFlag=[NSString stringWithFormat:@"%ld",_tableListTag];
            
            NSDateFormatter *dateFormatterDate = [[NSDateFormatter alloc] init];
            [dateFormatterDate setDateFormat:@"yyyy-MM-dd"];
            NSString *strDate = [dateFormatterDate stringFromDate:[NSDate date]];
            tmpEvaluate.Date=strDate;
            
            NSDateFormatter *dateFormatTime=[[NSDateFormatter alloc] init];
            [dateFormatTime setDateFormat:@"hh:mm:ss"];
            NSString *strTime = [dateFormatTime stringFromDate:[NSDate date]];
            tmpEvaluate.Time=strTime;
            
            tmpEvaluate.Score=[NSString stringWithFormat:@"%ld",(long)Mark];
            tmpEvaluate.Quality=myStrOne;
            
            EvaluateInfo *contain=[[EvaluateInfo alloc] init];
            for (EvaluateInfo *tmp in _EvaluateInfoArray)
            {
                if ([tmp.Date isEqualToString:tmpEvaluate.Date] && [tmp.ListFlag isEqualToString:@"1"] && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
                {
                    contain=tmp;
                }
            }
            //初始化数据库，并打开数据库
            dbOption=[[DataBaseOpration alloc] init];
            if (contain.Date!=nil)
            {
                //更新睡眠评估数据库数据
                [dbOption updateEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
            else
            {
                //插入睡眠评估数据库数据
                [dbOption insertEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
        }
        
        //添加再测一次按钮
        UIButton *EvaluateAgain=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*6.2/8, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
            EvaluateAgain.titleLabel.font=[UIFont systemFontOfSize:16];
        }
        else
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
            EvaluateAgain.titleLabel.font=[UIFont systemFontOfSize:18];
        }
        [EvaluateAgain setTitle:@"再测一次" forState:UIControlStateNormal];
        [EvaluateAgain addTarget:self action:@selector(evaluateAgainClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:EvaluateAgain];
    }
    else if (_tableListTag==2)
    {
        //添加抑郁评估界面
        //清除界面上的子控件
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        
        //添加评分结果界面
        UILabel *myLabelOne=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/20, SCREEN_WIDTH*9/10, SCREEN_WIDTH/20)];
        myLabelOne.textAlignment=NSTextAlignmentLeft;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        NSLog(@"%@", strDate);
        myLabelOne.text=[NSString stringWithFormat:@"评估完成时间:%@",strDate];
        [self.view addSubview:myLabelOne];
        
        UILabel *myLabelTwo=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/10, SCREEN_WIDTH/5, SCREEN_WIDTH/20)];
        myLabelTwo.text=@"得分:";
        [self.view addSubview:myLabelTwo];
        UILabel *myLabelThree=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/10, SCREEN_WIDTH/10, SCREEN_WIDTH/20)];
        myLabelThree.text=[NSString stringWithFormat:@"%ld",(long)Mark];
        [self.view addSubview:myLabelThree];
        
        UILabel *myLabelFour=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT*3/20, SCREEN_WIDTH/4, SCREEN_WIDTH/20)];
        myLabelFour.text=@"评估结果:";
        [self.view addSubview:myLabelFour];
        UILabel *myLabelFive=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/10, SCREEN_HEIGHT*3/20, SCREEN_WIDTH*3/4, SCREEN_WIDTH/20)];
        if (Mark==0)
        {
            myLabelFive.text=@"没有抑郁";
        }
        else if (Mark>0 && Mark<9)
        {
            myLabelFive.text=@"轻度抑郁";
        }
        else if (Mark>=9 && Mark<18)
        {
            myLabelFive.text=@"中度抑郁";
        }
        else if (Mark>=18 && Mark<27)
        {
            myLabelFive.text=@"重度抑郁";
        }
        [self.view addSubview:myLabelFive];
        
        //关于保存评估数据
        if (_patientInfo.PatientID!=nil)
        {
            //保存抑郁评估数据
            EvaluateInfo *tmpEvaluate=[[EvaluateInfo alloc] init];
            tmpEvaluate.PatientID=_patientInfo.PatientID;
            tmpEvaluate.ListFlag=[NSString stringWithFormat:@"%ld",_tableListTag];
            
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [dateFormat setTimeStyle:NSDateFormatterShortStyle];
            [dateFormat setDateFormat:@"YYYY-MM-dd"];
            NSDate *myDate=[NSDate date];
            tmpEvaluate.Date=[dateFormat stringFromDate:myDate];
            
            NSDateFormatter *_dateFormat=[[NSDateFormatter alloc] init];
            [_dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [_dateFormat setTimeStyle:NSDateFormatterShortStyle];
            [_dateFormat setDateFormat:@"hh:mm:ss"];
            tmpEvaluate.Time=[_dateFormat stringFromDate:myDate];
            
            tmpEvaluate.Score=[NSString stringWithFormat:@"%ld",(long)Mark];
            tmpEvaluate.Quality=myLabelFive.text;
            
            EvaluateInfo *contain=[[EvaluateInfo alloc] init];
            for (EvaluateInfo *tmp in _EvaluateInfoArray)
            {
                if ([tmp.Date isEqualToString:tmpEvaluate.Date] && [tmp.ListFlag isEqualToString:@"2"] && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
                {
                    contain=tmp;
                }
            }
            //初始化数据库，并打开数据库
            dbOption=[[DataBaseOpration alloc] init];
            if (contain.Date!=nil)
            {
                //更新抑郁评估数据库数据
                [dbOption updateEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
            else
            {
                //插入抑郁评估数据库数据
                [dbOption insertEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
        }
        
        //添加再测一次按钮
        UIButton *EvaluateAgain=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*5.5/8, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
        }
        else
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
        }
        EvaluateAgain.titleLabel.font=[UIFont systemFontOfSize:18];
        [EvaluateAgain setTitle:@"再测一次" forState:UIControlStateNormal];
        [EvaluateAgain addTarget:self action:@selector(evaluateAgainClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:EvaluateAgain];
    }
    else if (_tableListTag==3)
    {
        //添加焦虑评估界面
        //清除界面上的子控件
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        
        //添加评分结果界面
        UILabel *myLabelOne=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/20, SCREEN_WIDTH*9/10, SCREEN_WIDTH/20)];
        myLabelOne.textAlignment=NSTextAlignmentLeft;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        //NSLog(@"%@", strDate);
        myLabelOne.text=[NSString stringWithFormat:@"评估完成时间:%@",strDate];
        [self.view addSubview:myLabelOne];
        
        UILabel *myLabelTwo=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/10, SCREEN_WIDTH/5, SCREEN_WIDTH/20)];
        myLabelTwo.text=@"得分:";
        [self.view addSubview:myLabelTwo];
        UILabel *myLabelThree=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/10, SCREEN_WIDTH/10, SCREEN_WIDTH/20)];
        myLabelThree.text=[NSString stringWithFormat:@"%ld",(long)Mark];
        [self.view addSubview:myLabelThree];
        
        UILabel *myLabelFour=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT*3/20, SCREEN_WIDTH/4, SCREEN_WIDTH/20)];
        myLabelFour.text=@"评估结果:";
        [self.view addSubview:myLabelFour];
        UILabel *myLabelFive=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/10, SCREEN_HEIGHT*3/20, SCREEN_WIDTH*3/4, SCREEN_WIDTH/20)];
        if (Mark==0)
        {
            myLabelFive.text=@"没有焦虑";
        }
        else if (Mark>0 && Mark<7)
        {
            myLabelFive.text=@"轻度焦虑";
        }
        else if (Mark>=7 && Mark<14)
        {
            myLabelFive.text=@"中度焦虑";
        }
        else if (Mark>=14 && Mark<=21)
        {
            myLabelFive.text=@"重度焦虑";
        }
        [self.view addSubview:myLabelFive];
        
        //关于保存评估数据
        if (_patientInfo.PatientID!=nil)
        {
            //保存焦虑评估数据
            EvaluateInfo *tmpEvaluate=[[EvaluateInfo alloc] init];
            tmpEvaluate.PatientID=_patientInfo.PatientID;
            tmpEvaluate.ListFlag=[NSString stringWithFormat:@"%ld",_tableListTag];
            
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [dateFormat setTimeStyle:NSDateFormatterShortStyle];
            [dateFormat setDateFormat:@"YYYY-MM-dd"];
            NSDate *myDate=[NSDate date];
            tmpEvaluate.Date=[dateFormat stringFromDate:myDate];
            
            NSDateFormatter *_dateFormat=[[NSDateFormatter alloc] init];
            [_dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [_dateFormat setTimeStyle:NSDateFormatterShortStyle];
            [_dateFormat setDateFormat:@"hh:mm:ss"];
            tmpEvaluate.Time=[_dateFormat stringFromDate:myDate];
            
            tmpEvaluate.Score=[NSString stringWithFormat:@"%ld",(long)Mark];
            tmpEvaluate.Quality=myLabelFive.text;
            
            EvaluateInfo *contain=[[EvaluateInfo alloc] init];
            for (EvaluateInfo *tmp in _EvaluateInfoArray)
            {
                if ([tmp.Date isEqualToString:tmpEvaluate.Date] && [tmp.ListFlag isEqualToString:@"3"] && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
                {
                    contain=tmp;
                }
            }
            //初始化数据库，并打开数据库
            dbOption=[[DataBaseOpration alloc] init];
            if (contain.Date!=nil)
            {
                //更新焦虑评估数据库数据
                [dbOption updateEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
            else
            {
                //插入焦虑评估数据库数据
                [dbOption insertEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
        }
        
        //添加再测一次按钮
        UIButton *EvaluateAgain=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*5.5/8, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
        }
        else
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
        }
        EvaluateAgain.titleLabel.font=[UIFont systemFontOfSize:18];
        [EvaluateAgain setTitle:@"再测一次" forState:UIControlStateNormal];
        [EvaluateAgain addTarget:self action:@selector(evaluateAgainClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:EvaluateAgain];
    }
    else if (_tableListTag==4)
    {
        //添加躯体评估界面
        //清除界面上的子控件
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        
        //添加评分结果界面
        UILabel *myLabelOne=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/20, SCREEN_WIDTH*9/10, SCREEN_WIDTH/20)];
        myLabelOne.textAlignment=NSTextAlignmentLeft;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy年MM月dd日 HH:mm"];
        NSString *strDate = [dateFormatter stringFromDate:[NSDate date]];
        NSLog(@"%@", strDate);
        myLabelOne.text=[NSString stringWithFormat:@"评估完成时间:%@",strDate];
        [self.view addSubview:myLabelOne];
        
        UILabel *myLabelTwo=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/10, SCREEN_WIDTH/5, SCREEN_WIDTH/20)];
        myLabelTwo.text=@"得分:";
        [self.view addSubview:myLabelTwo];
        UILabel *myLabelThree=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, SCREEN_HEIGHT/10, SCREEN_WIDTH/10, SCREEN_WIDTH/20)];
        myLabelThree.text=[NSString stringWithFormat:@"%ld",(long)Mark];
        [self.view addSubview:myLabelThree];
        
        UILabel *myLabelFour=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT*3/20, SCREEN_WIDTH/4, SCREEN_WIDTH/20)];
        myLabelFour.text=@"评估结果:";
        [self.view addSubview:myLabelFour];
        UILabel *myLabelFive=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/10, SCREEN_HEIGHT*3/20, SCREEN_WIDTH*3/4, SCREEN_WIDTH/20)];
        if (Mark>=0 && Mark<=4)
        {
            myLabelFive.text=@"没有躯体症状";
        }
        else if (Mark>=5 && Mark<=9)
        {
            myLabelFive.text=@"轻度躯体症状";
        }
        else if (Mark>=9 && Mark<=14)
        {
            myLabelFive.text=@"中度躯体症状";
        }
        else if (Mark>=15)
        {
            myLabelFive.text=@"重度躯体症状";
        }
        [self.view addSubview:myLabelFive];
        
        //关于保存评估数据
        if (_patientInfo.PatientID!=nil)
        {
            //保存躯体评估数据
            EvaluateInfo *tmpEvaluate=[[EvaluateInfo alloc] init];
            tmpEvaluate.PatientID=_patientInfo.PatientID;
            tmpEvaluate.ListFlag=[NSString stringWithFormat:@"%ld",_tableListTag];
            
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
            [dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [dateFormat setTimeStyle:NSDateFormatterShortStyle];
            [dateFormat setDateFormat:@"YYYY-MM-dd"];
            NSDate *myDate=[NSDate date];
            tmpEvaluate.Date=[dateFormat stringFromDate:myDate];
            
            NSDateFormatter *_dateFormat=[[NSDateFormatter alloc] init];
            [_dateFormat setDateStyle:NSDateFormatterMediumStyle];
            [_dateFormat setTimeStyle:NSDateFormatterShortStyle];
            [_dateFormat setDateFormat:@"hh:mm:ss"];
            tmpEvaluate.Time=[_dateFormat stringFromDate:myDate];
            
            tmpEvaluate.Score=[NSString stringWithFormat:@"%ld",(long)Mark];
            
            tmpEvaluate.Quality=myLabelFive.text;
            
            EvaluateInfo *contain=[[EvaluateInfo alloc] init];
            for (EvaluateInfo *tmp in _EvaluateInfoArray)
            {
                if ([tmp.Date isEqualToString:tmpEvaluate.Date] && [tmp.ListFlag isEqualToString:@"4"] && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
                {
                    contain=tmp;
                }
            }
            //初始化数据库，并打开数据库
            dbOption=[[DataBaseOpration alloc] init];
            if (contain.Date!=nil)
            {
                //更新躯体评估数据库数据
                [dbOption updateEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
            else
            {
                //插入躯体评估数据库数据
                [dbOption insertEvaluateInfo:tmpEvaluate];
                [dbOption closeDataBase];
            }
        }
        
        //添加再测一次按钮SCREEN_WIDTH*4/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/5, 30
        UIButton *EvaluateAgain=[UIButton buttonWithType:UIButtonTypeSystem];
        if (SCREEN_HEIGHT==480)
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*5.5/8, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
        }
        else
        {
            EvaluateAgain.frame=CGRectMake(SCREEN_WIDTH*3/5, SCREEN_HEIGHT*3/4, SCREEN_WIDTH/3, SCREEN_HEIGHT/20);
        }
        EvaluateAgain.titleLabel.font=[UIFont systemFontOfSize:18];
        [EvaluateAgain setTitle:@"再测一次" forState:UIControlStateNormal];
        [EvaluateAgain addTarget:self action:@selector(evaluateAgainClick) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:EvaluateAgain];
    }
}

//再测一次按钮的点击事件
-(void)evaluateAgainClick
{
    [resultArray removeAllObjects];
    [initArray removeAllObjects];
    questionIndex=0;
    Mark=0;
    if (_tableListTag==1)
    {
        [_sleepTipsResultArray removeAllObjects];
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        //给睡眠表的结果数组赋初值，进行初始化
        for (int i=0; i<SleepQuestionArray.count; i++)
        {
            if (i==0)
            {
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                NSString *strHour=@"21";
                NSString *strMinutes=@"30";
                [dic setObject:strHour forKey:@"时"];
                [dic setObject:strMinutes forKey:@"分"];
                [resultArray addObject:dic];
                [initArray addObject:dic];
            }
            else if (i==1)
            {
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                NSString *strHour=@"00";
                NSString *strMinutes=@"30";
                [dic setObject:strHour forKey:@"时"];
                [dic setObject:strMinutes forKey:@"分"];
                [resultArray addObject:dic];
                [initArray addObject:dic];
            }
            else if (i==2 || i==3)
            {
                NSMutableDictionary *dic=[NSMutableDictionary dictionary];
                NSString *strHour=@"07";
                NSString *strMinutes=@"30";
                [dic setObject:strHour forKey:@"时"];
                [dic setObject:strMinutes forKey:@"分"];
                [resultArray addObject:dic];
                [initArray addObject:dic];
            }
            else
            {
                NSString *str=@"4";
                [resultArray addObject:str];
                [initArray addObject:str];
            }
        }
        
        [self addSleepListView];
    }
    else if (_tableListTag==2)
    {
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        //给抑郁表的结果数组赋初值，进行初始化
        for (int i=0; i<DepressedQuestionArray.count; i++)
        {
            NSString *str=@"4";
            [resultArray addObject:str];
            [initArray addObject:str];
        }
        
        [self addDepressedListView];
    }
    else if (_tableListTag==3)
    {
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        //给焦虑表的结果数组赋初值，进行初始化
        for (int i=0; i<WorriedQuestionArray.count; i++)
        {
            NSString *str=@"4";
            [resultArray addObject:str];
            [initArray addObject:str];
        }
        
        [self addWorriedListView];
    }
    else if (_tableListTag==4)
    {
        NSArray *arr=self.view.subviews;
        for (int i=0; i<[arr count]; i++)
        {
            [[arr objectAtIndex:i] removeFromSuperview];
        }
        //给躯体表的结果数组赋初值，进行初始化
        for (int i=0; i<BodyQuestionArray.count; i++)
        {
            NSString *str=@"4";
            [resultArray addObject:str];
            [initArray addObject:str];
        }
        
        [self addBodyListView];
    }
}

//给评估的选择进行评分
-(void)markForResult
{
    if (_tableListTag==1)
    {
        [self sleepMark];
    }
    else if (_tableListTag==2)
    {
        [self depressedMark];
    }
    else if (_tableListTag==3)
    {
        [self worriedMark];
    }
    else if (_tableListTag==4)
    {
        [self bodyMark];
    }
}
//睡眠评估量表评分
-(void)sleepMark
{
    //睡眠量表评估结果评分
    int E_mark=0;
    int G_mark=0;
    for (int i=0; i<resultArray.count; i++)
    {
        if (i==3)
        {
            NSString *sleepTimeForHour=[[resultArray objectAtIndex:3] objectForKey:@"时"];
            NSString *sleepTimeForMinute=[[resultArray objectAtIndex:3] objectForKey:@"分"];
            float sleepTime=[sleepTimeForHour intValue] + [sleepTimeForMinute floatValue]/60;
            if (sleepTime>=6 && sleepTime<7)
            {
                Mark+=1;
            }
            else if (sleepTime>=5 && sleepTime<6)
            {
                Mark+=2;
            }
            else if (sleepTime<5)
            {
                Mark+=3;
            }
            
            NSString *getUpTimeForHour=[[resultArray objectAtIndex:2] objectForKey:@"时"];
            NSString *getUpTimeForMinute=[[resultArray objectAtIndex:2] objectForKey:@"分"];
            int getUpHour=[getUpTimeForHour intValue];
            int getUpMinute=[getUpTimeForMinute floatValue];
            NSString *bedTimeForHour=[[resultArray objectAtIndex:0] objectForKey:@"时"];
            NSString *bedTimeForMinute=[[resultArray objectAtIndex:0] objectForKey:@"分"];
            int bedHour=[bedTimeForHour intValue];
            int bedMinute=[bedTimeForMinute floatValue];
            
            float onBedTime=0;
            
            if (bedHour > getUpHour)
            {
                onBedTime=(getUpHour+24-bedHour)+(getUpMinute-bedMinute)/60;
            }
            else if (bedHour < getUpHour)
            {
                onBedTime=(getUpHour-bedMinute)+(getUpMinute-bedMinute)/60;
            }
            
            float efficiencyForSleep=100*sleepTime/onBedTime;
            
            if (efficiencyForSleep >85)
            {
                Mark+=0;
            }
            else if (efficiencyForSleep >=75 && efficiencyForSleep <=84)
            {
                Mark+=1;
            }
            else if (efficiencyForSleep >=65 && efficiencyForSleep<=74)
            {
                Mark+=2;
            }
            else if (efficiencyForSleep <65)
            {
                Mark+=3;
            }
        }
        else if (i==4)
        {
            NSString *toSleepTimeHour=[[resultArray objectAtIndex:1] objectForKey:@"时"];
            NSString *toSleepTimeMinute=[[resultArray objectAtIndex:1] objectForKey:@"分"];
            int tmpHour=[toSleepTimeHour intValue];
            int tmpMinute=[toSleepTimeMinute intValue];
            int toSleepTime=tmpHour*60+tmpMinute;
            int tmpMark = 0;
            if (toSleepTime>=16 && toSleepTime<=30)
            {
                tmpMark=1;
            }
            else if (toSleepTime>=31 && toSleepTime<=60)
            {
                tmpMark=2;
            }
            else if (toSleepTime>60)
            {
                tmpMark=3;
            }
            
            if ([[resultArray objectAtIndex:4] intValue]==0)
            {
                tmpMark+=0;
            }
            else if ([[resultArray objectAtIndex:4] intValue]==1)
            {
                tmpMark+=1;
            }
            else if ([[resultArray objectAtIndex:4] intValue]==2)
            {
                tmpMark+=2;
            }
            else if ([[resultArray objectAtIndex:4] intValue]==3)
            {
                tmpMark+=3;
            }
            
            if (tmpMark==0)
            {
                Mark+=0;
            }
            else if (tmpMark==1 || tmpMark==2)
            {
                Mark+=1;
            }
            else if (tmpMark==3 || tmpMark==4)
            {
                Mark+=2;
            }
            else if (tmpMark==5 || tmpMark==6)
            {
                Mark+=3;
            }
        }
        else if (i>=5 && i<=13)
        {
            int tmp=[[resultArray objectAtIndex:i] intValue];
            if (tmp==1)
            {
                E_mark+=1;
            }
            else if (tmp==2)
            {
                E_mark+=2;
            }
            else if (tmp==3)
            {
                E_mark+=3;
            }
        }
        else if (i==14 ||i==15)
        {
            int tmp=[[resultArray objectAtIndex:i] intValue];
            if (tmp==0)
            {
                Mark+=0;
            }
            else if (tmp==1)
            {
                Mark+=1;
            }
            else if (tmp==2)
            {
                Mark+=2;
            }
            else if (tmp==3)
            {
                Mark+=3;
            }
        }
        else if (i==16 || i==17)
        {
            int tmp=[[resultArray objectAtIndex:i] intValue];
            if (tmp==0)
            {
                G_mark+=0;
            }
            else if (tmp==1)
            {
                G_mark+=1;
            }
            else if (tmp==2)
            {
                G_mark+=2;
            }
            else if (tmp==3)
            {
                G_mark+=3;
            }
        }
    }
    if (E_mark==0)
    {
        Mark+=0;
    }
    else if (E_mark>=1 && E_mark<=9)
    {
        Mark+=1;
    }
    else if (E_mark>=10 && E_mark<=18)
    {
        Mark+=2;
    }
    else if (E_mark>=19 && E_mark<=27)
    {
        Mark+=3;
    }
    if (G_mark==0)
    {
        Mark+=0;
    }
    else if (G_mark==1 || G_mark==2)
    {
        Mark+=1;
    }
    else if (G_mark==3 || G_mark==4)
    {
        Mark+=2;
    }
    else if (G_mark==5 || G_mark==6)
    {
        Mark+=3;
    }
}
//评估抑郁量表评分
-(void)depressedMark
{
    for (int i=0; i<resultArray.count; i++)
    {
        int tmp=[[resultArray objectAtIndex:i] intValue];
        if (tmp==1)
        {
            Mark+=1;
        }
        else if (tmp==2)
        {
            Mark+=2;
        }
        else if (tmp==3)
        {
            Mark+=3;
        }
    }
}
//评估焦虑量表评分
-(void)worriedMark
{
    for (int i=0; i<resultArray.count; i++)
    {
        int tmp=[[resultArray objectAtIndex:i] intValue];
        if (tmp==1)
        {
            Mark+=1;
        }
        else if (tmp==2)
        {
            Mark+=2;
        }
        else if (tmp==3)
        {
            Mark+=3;
        }
    }
}
//评估躯体量表评分
-(void)bodyMark
{
    for (int i=0; i<resultArray.count; i++)
    {
        int tmp=[[resultArray objectAtIndex:i] intValue];
        if (tmp==1)
        {
            Mark+=1;
        }
        else if (tmp==2)
        {
            Mark+=2;
        }
    }
}

//添加睡眠贴士
-(void)addSleepTips
{
    if ([[[resultArray objectAtIndex:0] objectForKey:@"时"] intValue]>=23)
    {
        [_sleepTipsResultArray addObject:@"1"];
        [_sleepTipsResultArray addObject:@"12"];
    }
    if ([[[resultArray objectAtIndex:1] objectForKey:@"时"] intValue]*60+[[[resultArray objectAtIndex:1] objectForKey:@"分"] intValue]<=30 && [[[resultArray objectAtIndex:1] objectForKey:@"时"] intValue]*60+[[[resultArray objectAtIndex:1] objectForKey:@"分"] intValue]>=16)
    {
        [_sleepTipsResultArray addObject:@"2"];
        [_sleepTipsResultArray addObject:@"4"];
    }
    if ([[[resultArray objectAtIndex:3] objectForKey:@"时"] intValue]<7)
    {
        [_sleepTipsResultArray addObject:@"3"];
    }
    if ([[resultArray objectAtIndex:4] intValue]==2 || [[resultArray objectAtIndex:4] intValue]==3)
    {
        NSString *temp;
        for (NSString *tmp in _sleepTipsResultArray)
        {
            if ([tmp isEqualToString:@"4"])
            {
                temp=tmp;
            }
        }
        if (temp==nil)
        {
            [_sleepTipsResultArray addObject:@"4"];
        }
        
        [_sleepTipsResultArray addObject:@"5"];
        [_sleepTipsResultArray addObject:@"6"];
        [_sleepTipsResultArray addObject:@"9"];
    }
    if ([[resultArray objectAtIndex:5] intValue]==2 || [[resultArray objectAtIndex:5] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"8"];
        [_sleepTipsResultArray addObject:@"15"];
        [_sleepTipsResultArray addObject:@"17"];
    }
    if ([[resultArray objectAtIndex:6] intValue]==2 || [[resultArray objectAtIndex:6] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"11"];
    }
    if ([[resultArray objectAtIndex:7] intValue]==2 || [[resultArray objectAtIndex:7] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"20"];
    }
    if ([[resultArray objectAtIndex:8] intValue]==2 || [[resultArray objectAtIndex:8] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"16"];
    }
    if ([[resultArray objectAtIndex:9] intValue]==2 || [[resultArray objectAtIndex:9] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"18"];
    }
    if ([[resultArray objectAtIndex:10] intValue]==2 || [[resultArray objectAtIndex:10] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"13"];
    }
    if ([[resultArray objectAtIndex:11] intValue]==2 || [[resultArray objectAtIndex:11] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"7"];
        NSString *temp;
        for (NSString *tmp in _sleepTipsResultArray)
        {
            if ([tmp isEqualToString:@"8"])
            {
                temp=tmp;
            }
        }
        if (temp==nil)
        {
            [_sleepTipsResultArray addObject:@"8"];
        }
        [_sleepTipsResultArray addObject:@"9"];
    }
    if ([[resultArray objectAtIndex:12] intValue]==2 || [[resultArray objectAtIndex:12] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"21"];
    }
    if ([[resultArray objectAtIndex:14] intValue]==2 || [[resultArray objectAtIndex:14] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"10"];
    }
    if ([[resultArray objectAtIndex:15] intValue]==1 || [[resultArray objectAtIndex:15] intValue]==2 || [[resultArray objectAtIndex:15] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"14"];
    }
    if ([[resultArray objectAtIndex:16] intValue]==2 || [[resultArray objectAtIndex:16] intValue]==3)
    {
        [_sleepTipsResultArray addObject:@"22"];
        [_sleepTipsResultArray addObject:@"23"];
    }
    if ([[resultArray objectAtIndex:17] intValue]==2 || [[resultArray objectAtIndex:17] intValue]==3)
    {
        NSString *temp;
        for (NSString *tmp in _sleepTipsResultArray)
        {
            if ([tmp isEqualToString:@"22"] || [tmp isEqualToString:@"23"])
            {
                temp=tmp;
            }
        }
        if (temp==nil)
        {
            [_sleepTipsResultArray addObject:@"22"];
            [_sleepTipsResultArray addObject:@"23"];
        }
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
