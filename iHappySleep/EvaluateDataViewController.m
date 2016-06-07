//
//  EvaluateDataViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "EvaluateDataViewController.h"
#import "myHeader.h"

@interface EvaluateDataViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate>

@end

@implementation EvaluateDataViewController
{
    NSInteger flag;                              //记录选择的评估数据类型，跟评估数据的ListFlag对应
    
    DataBaseOpration *dbOpration;                //申请数据库操作全局变量
    NSMutableArray *evaluateData;                //存储所有评估数据的数组，包括四张量表的数据
    
    NSMutableArray *SleepEvaluate;               //存储睡眠量表评估数据的数组
    NSMutableArray *WorriedEvaluate;             //存储焦虑量表评估数据的数组
    NSMutableArray *DepressedEvaluate;           //存储抑郁量表评估数据的数组
    NSMutableArray *BodyEvaluate;                //存储躯体量表评估数据的数组
    
    UIButton *chooseType;                        //选择评估类型的按钮
    
    NSDate *BegainDate;                          //NSDate类型的查看日期的开始日期
    NSDate *EndDate;                             //NSDate类型的查看日期的截止日期
    NSString *BegainTime;                        //NSString类型的查看日期的开始日期
    NSString *EndTime;                           //NSString类型的查看日期的截止日期
    
    UITableView *DataTableView;                  //显示评估数据的tableview
    
    UIView *view;
    UITableView *evaluateTypeTableView;          //显示评估类型选项的tableview
    NSArray *ListArray;                          //存储评估类型的量表名称
    UIView *dateView;                            //用来添加选择时间的pickerview和一个确定按钮
    
    UIPickerView *PickerView;                    //时间选择的pickerview
    NSInteger year;                              //系统当前时间的年份
    NSInteger month;                             //系统当前时间的月份
    NSInteger day;                               //系统当前时间的日份
    NSInteger yearBegainIndex;                   //开始时间年份在pickerview中年份数组中的index
    NSInteger monthBegainIndex;                  //开始时间月份在pickerview中月份数组中的index
    NSInteger dayBegainIndex;                    //开始时间日份在pickerview中日份数组中的index
    NSInteger yearEndIndex;                      //截止时间年份在pickerview中年份数组中的index
    NSInteger monthEndIndex;                     //截止时间年份在pickerview中年份数组中的index
    NSInteger dayEndIndex;                       //截止时间年份在pickerview中年份数组中的index
    NSInteger monthBegainSelectIndex;
    NSInteger yearBegainSelectIndex;
    NSInteger dayBegainSelectIndex;
    NSInteger monthEndSelectIndex;
    NSInteger yearEndSelectIndex;
    NSInteger dayEndSelectIndex;
    
    UIButton *dateOne_Button;                    //选择查看日期开始日期的按钮
    UIButton *dateTwo_Button;                    //选择查看日期截止日期的按钮
    
    UIAlertView *alert;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.translucent=YES;
    
    dbOpration=[[DataBaseOpration alloc] init];
    evaluateData=[dbOpration getEvaluateDataFromDataBase];
    [dbOpration closeDataBase];
    
    [self getEvaluateDataFromServer];
    
    ListArray=@[@"匹兹堡睡眠指数(PSQI)",@"抑郁自评(GAD-7)",@"焦虑自评(PHQ-9)",@"躯体自评(PHQ-15)"];
    
    SleepEvaluate=[[NSMutableArray alloc] init];
    DepressedEvaluate=[[NSMutableArray alloc] init];
    WorriedEvaluate=[[NSMutableArray alloc] init];
    BodyEvaluate=[[NSMutableArray alloc] init];
    
    UILabel *evaluateType=[[UILabel alloc] initWithFrame:CGRectMake(0, 65, SCREEN_WIDTH*2/7, SCREEN_HEIGHT/20)];
    evaluateType.text=@"评估类型：";
    evaluateType.textAlignment=NSTextAlignmentCenter;
    chooseType=[UIButton buttonWithType:UIButtonTypeSystem];
    chooseType.tag=2;
    flag=1;
    chooseType.frame=CGRectMake(SCREEN_WIDTH*2/7, 65, SCREEN_WIDTH/2, SCREEN_HEIGHT/20);
    if (SCREEN_WIDTH==320)
    {
        chooseType.titleLabel.font=[UIFont systemFontOfSize:16];
    }
    else
    {
        chooseType.titleLabel.font=[UIFont systemFontOfSize:18];
    }
    [chooseType setTitle:@"匹兹堡睡眠指数(PSQI)" forState:UIControlStateNormal];
    [chooseType addTarget:self action:@selector(chooseTypeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:evaluateType];
    [self.view addSubview:chooseType];
    
    UILabel *dateOne_Label=[[UILabel alloc] initWithFrame:CGRectMake(0, 65+SCREEN_HEIGHT/20, SCREEN_WIDTH*2/7, SCREEN_HEIGHT/20)];
    dateOne_Label.text=@"查看日期：";
    dateOne_Label.textAlignment=NSTextAlignmentCenter;
    dateOne_Button=[UIButton buttonWithType:UIButtonTypeSystem];
    dateOne_Button.tag=1;
    dateOne_Button.frame=CGRectMake(SCREEN_WIDTH*2/7, 65+SCREEN_HEIGHT/20, SCREEN_WIDTH*2/7, SCREEN_HEIGHT/20);
    EndDate=[NSDate date];
    BegainDate=[EndDate initWithTimeIntervalSinceNow:-6*24*60*60];
    NSLog(@"%@",BegainDate);
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    BegainTime=[dateFormatter stringFromDate:BegainDate];
    yearBegainIndex=[[BegainTime substringWithRange:NSMakeRange(0, 4)] integerValue]-1900;
    monthBegainIndex=[[BegainTime substringWithRange:NSMakeRange(5, 2)] integerValue]-1;
    dayBegainIndex=[[BegainTime substringWithRange:NSMakeRange(8, 2)] integerValue]-1;
    [dateOne_Button setTitle:BegainTime forState:UIControlStateNormal];
    [dateOne_Button addTarget:self action:@selector(chooseDateClick:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *dateTwo_Label=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*4/7, 65+SCREEN_HEIGHT/20, SCREEN_WIDTH/7, SCREEN_HEIGHT/20)];
    dateTwo_Label.text=@"至";
    dateTwo_Label.textAlignment=NSTextAlignmentCenter;
    dateTwo_Button=[UIButton buttonWithType:UIButtonTypeSystem];
    dateTwo_Button.tag=2;
    dateTwo_Button.frame=CGRectMake(SCREEN_WIDTH*5/7, 65+SCREEN_HEIGHT/20, SCREEN_WIDTH*2/7, SCREEN_HEIGHT/20);
    EndTime=[dateFormatter stringFromDate:EndDate];
    yearEndIndex=[[EndTime substringWithRange:NSMakeRange(0, 4)] integerValue]-1900;
    monthEndIndex=[[EndTime substringWithRange:NSMakeRange(5, 2)] integerValue]-1;
    dayEndIndex=[[EndTime substringWithRange:NSMakeRange(8, 2)] integerValue]-1;
    [dateTwo_Button setTitle:EndTime forState:UIControlStateNormal];
    [dateTwo_Button addTarget:self action:@selector(chooseDateClick:) forControlEvents:UIControlEventTouchUpInside];
    if (SCREEN_WIDTH==320)
    {
        dateOne_Button.titleLabel.font=[UIFont systemFontOfSize:16];
        dateTwo_Button.titleLabel.font=[UIFont systemFontOfSize:16];
    }
    else
    {
        dateOne_Button.titleLabel.font=[UIFont systemFontOfSize:18];
        dateTwo_Button.titleLabel.font=[UIFont systemFontOfSize:18];
    }
    
    [self.view addSubview:dateOne_Label];
    [self.view addSubview:dateOne_Button];
    [self.view addSubview:dateTwo_Label];
    [self.view addSubview:dateTwo_Button];
    
    //添加显示的菜单
    UIView *viewOne=[[UIView alloc] initWithFrame:CGRectMake(0, 65+SCREEN_HEIGHT/10, SCREEN_WIDTH, 1)];
    viewOne.backgroundColor=[UIColor blackColor];
    UILabel *label_date=[[UILabel alloc] initWithFrame:CGRectMake(0, 65+SCREEN_HEIGHT/10, SCREEN_WIDTH/4, SCREEN_HEIGHT/20)];
    label_date.text=@"日期";
    label_date.textAlignment=NSTextAlignmentCenter;
    UILabel *label_time=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 65+SCREEN_HEIGHT/10, SCREEN_WIDTH/4, SCREEN_HEIGHT/20)];
    label_time.text=@"评估时间";
    label_time.textAlignment=NSTextAlignmentCenter;
    UILabel *label_num=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 65+SCREEN_HEIGHT/10, SCREEN_WIDTH/4, SCREEN_HEIGHT/20)];
    label_num.text=@"障碍指数";
    label_num.textAlignment=NSTextAlignmentCenter;
    UILabel *label_quality=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, 65+SCREEN_HEIGHT/10, SCREEN_WIDTH/4, SCREEN_HEIGHT/20)];
    label_quality.text=@"评估结果";
    label_quality.textAlignment=NSTextAlignmentCenter;
    UIView *viewTwo=[[UIView alloc] initWithFrame:CGRectMake(0, 65+SCREEN_HEIGHT*3/20, SCREEN_WIDTH, 1)];
    viewTwo.backgroundColor=[UIColor blackColor];
    
    [self.view addSubview:viewOne];
    [self.view addSubview:label_date];
    [self.view addSubview:label_time];
    [self.view addSubview:label_num];
    [self.view addSubview:label_quality];
    [self.view addSubview:viewTwo];
    
    DataTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 66+SCREEN_HEIGHT*3/20, SCREEN_WIDTH, (SCREEN_HEIGHT*17/20)-65) style:UITableViewStylePlain];
    DataTableView.tag=1;
    [DataTableView.tableHeaderView removeFromSuperview];
    DataTableView.tableFooterView=[[UIView alloc] init];
    DataTableView.delegate=self;
    DataTableView.dataSource=self;
    
    [self.view addSubview:DataTableView];
    
    //最近一周内的评估数据
    [self putEvaluateDataToArray];
    
    //获取系统当前时间
    NSDate *date=[NSDate date];
    unsigned units  = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *component = [myCal components:units fromDate:date];
    year = [component year];
    month = [component month];
    day = [component day];
    _begainDateYearArray=[NSMutableArray array];
    _begainDateMonthArray=[NSMutableArray array];
    _begainDateDayArray=[NSMutableArray array];
    _endDateYearArray=[NSMutableArray array];
    _endDateMonthArray=[NSMutableArray array];
    _endDateDayArray=[NSMutableArray array];
    
    for (int i=1900; i<=year; i++)
    {
        NSString *yearStr=[NSString stringWithFormat:@"%d",i];
        [_begainDateYearArray addObject:yearStr];
        [_endDateYearArray addObject:yearStr];
    }
    for (int i=1; i<=12; i++)
    {
        NSString *monthStr=[NSString stringWithFormat:@"%d",i];
        [_begainDateMonthArray addObject:monthStr];
        [_endDateMonthArray addObject:monthStr];
    }
    for (int i=1; i<=31; i++)
    {
        NSString *dayStr=[NSString stringWithFormat:@"%d",i];
        [_begainDateDayArray addObject:dayStr];
        [_endDateDayArray addObject:dayStr];
    }
}

//下载服务器上的评估数据
-(void)getEvaluateDataFromServer
{
    if (_patientInfo.PatientID!=nil)
    {
        NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:_patientInfo.PatientID,@"PatientID",@"",@"Date",nil];
        NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
        
        // 设置我们之后解析XML时用的关键字
        matchingElement = @"APP_GetEvaluateDataResponse";
        // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
        NSString *soapMsg = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap12:Envelope "
                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                             "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap12:Body>"
                             "<APP_GetEvaluateData xmlns=\"MeetingOnline\">"
                             "<JsonEvaluateData>%@</JsonEvaluateData>"
                             "</APP_GetEvaluateData>"
                             "</soap12:Body>"
                             "</soap12:Envelope>", jsonString,nil];
        //打印soapMsg信息
        NSLog(@"%@",soapMsg);
        
        //设置网络连接的url
        NSString *urlStr = [NSString stringWithFormat:@"%@",ADDRESS];
        NSURL *url = [NSURL URLWithString:urlStr];
        //设置request
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        NSString *msgLength=[NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
        // 添加请求的详细信息，与请求报文前半部分的各字段对应
        [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
        // 设置请求行方法为POST，与请求报文第一行对应
        [request setHTTPMethod:@"POST"];//默认是GET
        // 将SOAP消息加到请求中
        [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
        // 创建连接
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (conn)
        {
            webData = [NSMutableData data];
        }
    }
}

//根据开始时间跟结束时间选择评估数据，并把数据放入对应数组
-(void)putEvaluateDataToArray
{
    if (_patientInfo!=nil)
    {
        for (EvaluateInfo *tmp in evaluateData)
        {
            NSDateFormatter *dateFormat=[[NSDateFormatter alloc] init];
            [dateFormat setDateFormat:@"YYYY-MM-dd"];
            NSDate *tmp_Date=[dateFormat dateFromString:tmp.Date];
            if ([tmp.ListFlag integerValue]==1 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                if ([BegainDate compare:tmp_Date]==NSOrderedAscending && [EndDate compare:tmp_Date]==NSOrderedDescending)
                {
                    [SleepEvaluate addObject:tmp];
                }
                else if ([tmp.Date isEqualToString:BegainTime] || [tmp.Date isEqualToString:EndTime])
                {
                    [SleepEvaluate addObject:tmp];
                }
            }
            else if ([tmp.ListFlag integerValue]==2 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                if ([BegainDate compare:tmp_Date]==NSOrderedAscending && [EndDate compare:tmp_Date]==NSOrderedDescending)
                {
                    [DepressedEvaluate addObject:tmp];
                }
                else if ([tmp.Date isEqualToString:BegainTime] || [tmp.Date isEqualToString:EndTime])
                {
                    [DepressedEvaluate addObject:tmp];
                }
            }
            else if ([tmp.ListFlag integerValue]==3 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                if ([BegainDate compare:tmp_Date]==NSOrderedAscending && [EndDate compare:tmp_Date]==NSOrderedDescending)
                {
                    [WorriedEvaluate addObject:tmp];
                }
                else if ([tmp.Date isEqualToString:BegainTime] || [tmp.Date isEqualToString:EndTime])
                {
                    [WorriedEvaluate addObject:tmp];
                }
            }
            else if ([tmp.ListFlag integerValue]==4 && [tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                if ([BegainDate compare:tmp_Date]==NSOrderedAscending && [EndDate compare:tmp_Date]==NSOrderedDescending)
                {
                    [BodyEvaluate addObject:tmp];
                }
                else if ([tmp.Date isEqualToString:BegainTime] || [tmp.Date isEqualToString:EndTime])
                {
                    [BodyEvaluate addObject:tmp];
                }
            }
        }
        if (SleepEvaluate.count>0)
        {
            [self bubbleSort:SleepEvaluate];
        }
        if (DepressedEvaluate.count>0)
        {
            [self bubbleSort:DepressedEvaluate];
        }
        if (WorriedEvaluate.count>0)
        {
            [self bubbleSort:WorriedEvaluate];
        }
        if (BodyEvaluate.count>0)
        {
            [self bubbleSort:BodyEvaluate];
        }
    }
}

//显示的分组名
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==2)
    {
        UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*4/5, SCREEN_HEIGHT/20)];
        customView.backgroundColor=[UIColor colorWithRed:0xed/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
        UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.backgroundColor = [UIColor clearColor];
        headerLabel.highlightedTextColor = [UIColor whiteColor];
        headerLabel.font = [UIFont boldSystemFontOfSize:20];
        headerLabel.textAlignment=NSTextAlignmentCenter;
        headerLabel.frame =CGRectMake(0, 0, SCREEN_WIDTH*4/5, SCREEN_HEIGHT/20);
        
        headerLabel.text =  @"评估数据类型";
        
        [customView addSubview:headerLabel];
        return customView;
    }
    else
    {
        return nil;
    }
}
- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView.tag==2)
    {
        return SCREEN_HEIGHT/20;
    }
    else
    {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==2)
    {
        return ListArray.count;
    }
    else
    {
        if (flag==1)
        {
            return SleepEvaluate.count;
        }
        else if (flag==2)
        {
            return DepressedEvaluate.count;
        }
        else if (flag==3)
        {
            return WorriedEvaluate.count;
        }
        else if (flag==4)
        {
            return BodyEvaluate.count;
        }
        else
        {
            return 0;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==2)
    {
        return 50;
    }
    else
    {
        return 30;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify=@"EvaluateDataCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
    
    if (tableView.tag==1)
    {
        if (indexPath.row%2==0)
        {
            cell.backgroundColor=[UIColor colorWithRed:0xad/255.0 green:0xd8/255.0 blue:0xe6/255.0 alpha:1];
        }
        else if (indexPath.row%2==1)
        {
            cell.backgroundColor=[UIColor colorWithRed:0xff/255.0 green:0xa5/255.0 blue:0x00/255.0 alpha:1];
        }
        
        UILabel *dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*27/100, 30)];
        dateLabel.font=[UIFont systemFontOfSize:15];
        dateLabel.textAlignment=NSTextAlignmentCenter;
        UILabel *timeLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4, 0, SCREEN_WIDTH/4, 30)];
        timeLabel.font=[UIFont systemFontOfSize:15];
        timeLabel.textAlignment=NSTextAlignmentCenter;
        UILabel *numLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/4, 30)];
        numLabel.font=[UIFont systemFontOfSize:15];
        numLabel.textAlignment=NSTextAlignmentCenter;
        UILabel *qualityLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, 0, SCREEN_WIDTH/4, 30)];
        qualityLabel.font=[UIFont systemFontOfSize:15];
        qualityLabel.textAlignment=NSTextAlignmentCenter;
        
        EvaluateInfo *tmp=[[EvaluateInfo alloc] init];
        if (flag==1)
        {
            tmp=[SleepEvaluate objectAtIndex:indexPath.row];
            dateLabel.text=tmp.Date;
            timeLabel.text=[tmp.Time substringWithRange:NSMakeRange(0, 5)];
            numLabel.text=tmp.Score;
            if ([tmp.Quality containsString:@"很好"])
            {
                qualityLabel.text=@"很好";
            }
            else if ([tmp.Quality containsString:@"一般"])
            {
                qualityLabel.text=@"一般";
            }
            else if ([tmp.Quality containsString:@"较差"])
            {
                qualityLabel.text=@"较差";
            }
            else if ([tmp.Quality containsString:@"很差"])
            {
                qualityLabel.text=@"很差";
            }
        }
        else if (flag==2)
        {
            tmp=[DepressedEvaluate objectAtIndex:indexPath.row];
            dateLabel.text=tmp.Date;
            timeLabel.text=[tmp.Time substringWithRange:NSMakeRange(0, 5)];
            numLabel.text=tmp.Score;
            qualityLabel.text=[tmp.Quality substringWithRange:NSMakeRange(0, 2)];
        }
        else if (flag==3)
        {
            tmp=[WorriedEvaluate objectAtIndex:indexPath.row];
            dateLabel.text=tmp.Date;
            timeLabel.text=[tmp.Time substringWithRange:NSMakeRange(0, 5)];
            numLabel.text=tmp.Score;
            qualityLabel.text=[tmp.Quality substringWithRange:NSMakeRange(0, 2)];
        }
        else if (flag==4)
        {
            tmp=[BodyEvaluate objectAtIndex:indexPath.row];
            dateLabel.text=tmp.Date;
            timeLabel.text=[tmp.Time substringWithRange:NSMakeRange(0, 5)];
            numLabel.text=tmp.Score;
        }
        
        [cell.contentView addSubview:dateLabel];
        [cell.contentView addSubview:timeLabel];
        [cell.contentView addSubview:numLabel];
        [cell.contentView addSubview:qualityLabel];
    }
    else
    {
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
        cell.textLabel.text=[ListArray objectAtIndex:indexPath.row];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==2)
    {
        if (indexPath.row==0)
        {
            flag=1;
            [evaluateTypeTableView removeFromSuperview];
            [view removeFromSuperview];
            [chooseType setTitle:@"匹兹堡睡眠指数(PSQI)" forState:UIControlStateNormal];
//            [DataTableView reloadData];
        }
        else if (indexPath.row==1)
        {
            flag=2;
            [evaluateTypeTableView removeFromSuperview];
            [view removeFromSuperview];
            [chooseType setTitle:@"抑郁自评(GAD-7)" forState:UIControlStateNormal];
//            [DataTableView reloadData];
        }
        else if (indexPath.row==2)
        {
            flag=3;
            [evaluateTypeTableView removeFromSuperview];
            [view removeFromSuperview];
            [chooseType setTitle:@"焦虑自评(PHQ-9)" forState:UIControlStateNormal];
//            [DataTableView reloadData];
        }
        else if (indexPath.row==3)
        {
            flag=4;
            [evaluateTypeTableView removeFromSuperview];
            [view removeFromSuperview];
            [chooseType setTitle:@"躯体自评(PHQ-15)" forState:UIControlStateNormal];
//            [DataTableView reloadData];
        }
        
        //更新开始日期跟结束日期的数组
        if (flag==1)
        {
            [SleepEvaluate removeAllObjects];
        }
        else if (flag==2)
        {
            [DepressedEvaluate removeAllObjects];
        }
        else if (flag==3)
        {
            [WorriedEvaluate removeAllObjects];
        }
        else if (flag==4)
        {
            [BodyEvaluate removeAllObjects];
        }
        for (int i=0; i<evaluateData.count; i++)
        {
            EvaluateInfo *tmpEvaluateInfo=[evaluateData objectAtIndex:i];
            NSInteger tmpOne=[self getIntervalTimeFrom:[self stringToDate:BegainTime] toDate:[self stringToDate:tmpEvaluateInfo.Date]];
            NSInteger tmpTwo=[self getIntervalTimeFrom:[self stringToDate:tmpEvaluateInfo.Date] toDate:[self stringToDate:EndTime]];
            if (tmpOne>=0 && tmpTwo>=0 && [tmpEvaluateInfo.PatientID isEqualToString:_patientInfo.PatientID])
            {
                if ([tmpEvaluateInfo.ListFlag isEqualToString:@"1"])
                {
                    [SleepEvaluate addObject:tmpEvaluateInfo];
                }
                else if ([tmpEvaluateInfo.ListFlag isEqualToString:@"2"])
                {
                    [DepressedEvaluate addObject:tmpEvaluateInfo];
                }
                else if ([tmpEvaluateInfo.ListFlag isEqualToString:@"3"])
                {
                    [WorriedEvaluate addObject:tmpEvaluateInfo];
                }
                else if ([tmpEvaluateInfo.ListFlag isEqualToString:@"4"])
                {
                    [BodyEvaluate addObject:tmpEvaluateInfo];
                }
            }
        }
        if (SleepEvaluate.count>0)
        {
            [self bubbleSort:SleepEvaluate];
        }
        if (DepressedEvaluate.count>0)
        {
            [self bubbleSort:DepressedEvaluate];
        }
        if (WorriedEvaluate.count>0)
        {
            [self bubbleSort:WorriedEvaluate];
        }
        if (BodyEvaluate.count>0)
        {
            [self bubbleSort:BodyEvaluate];
        }
        [DataTableView reloadData];
    }
}

//添加一层半透明灰色的UIview
-(void)addAGrayView:(CGFloat)tableviewHeight
{
    view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    view.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view.window addSubview:view];
    
    evaluateTypeTableView=[[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, SCREEN_HEIGHT*3/8, SCREEN_WIDTH*4/5, tableviewHeight+SCREEN_HEIGHT/20)];
    [evaluateTypeTableView.layer setCornerRadius:10.0];
    evaluateTypeTableView.backgroundColor=[UIColor whiteColor];
    evaluateTypeTableView.tag=2;
    //evaluateTypeTableView.scrollEnabled=NO;
    evaluateTypeTableView.delegate=self;
    evaluateTypeTableView.dataSource=self;
    
    [view.window addSubview:evaluateTypeTableView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestures:)];
    [view addGestureRecognizer:tapGesture];
}
//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGestures:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<evaluateTypeTableView.frame.origin.x || point.x >evaluateTypeTableView.frame.origin.x+evaluateTypeTableView.frame.size.width || point.y<evaluateTypeTableView.frame.origin.y || point.y>evaluateTypeTableView.frame.origin.y+evaluateTypeTableView.frame.size.height)
    {
        [evaluateTypeTableView removeFromSuperview];
        [view removeFromSuperview];
    }
}

-(void)chooseTypeClick:(UIButton *)sender
{
    [self addAGrayView:200];
}

-(void)chooseDateClick:(UIButton *)sender
{
    view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    view.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view.window addSubview:view];
    dateView=[[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, SCREEN_HEIGHT*3/8, SCREEN_WIDTH*4/5, 162+SCREEN_HEIGHT/20)];
    [dateView.layer setCornerRadius:10.0];
    dateView.backgroundColor=[UIColor whiteColor];

    PickerView=[[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*4/5, 162)];
    [PickerView.layer setCornerRadius:10.0];
    PickerView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    PickerView.backgroundColor=[UIColor whiteColor];
    PickerView.tag=sender.tag;
    UILabel *yearLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*6/25, 67.5, 30, 27)];
    yearLabel.text=@"年";
    UILabel *monthLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*12/25, 67.5, 30, 27)];
    monthLabel.text=@"月";
    UILabel *dayLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*18/25, 67.5, 30, 27)];
    dayLabel.text=@"日";
    
    yearBegainSelectIndex=yearBegainIndex;
    monthBegainSelectIndex=monthBegainIndex;
    dayBegainSelectIndex=dayBegainIndex;
    
    yearEndSelectIndex=yearEndIndex;
    monthEndSelectIndex=monthEndIndex;
    dayEndSelectIndex=dayEndIndex;
    
    PickerView.delegate=self;
    PickerView.dataSource=self;
    
    if (sender.tag==1)
    {
        [PickerView selectRow:yearBegainIndex inComponent:0 animated:YES];
        [PickerView selectRow:monthBegainIndex inComponent:1 animated:YES];
        [PickerView selectRow:dayBegainIndex inComponent:2 animated:YES];
    }
    else if (sender.tag==2)
    {
        [PickerView selectRow:yearEndIndex inComponent:0 animated:YES];
        [PickerView selectRow:monthEndIndex inComponent:1 animated:YES];
        [PickerView selectRow:dayEndIndex inComponent:2 animated:YES];
    }
    [PickerView reloadAllComponents];
    
    [PickerView addSubview:yearLabel];
    [PickerView addSubview:monthLabel];
    [PickerView addSubview:dayLabel];
    
    UIButton *determineButton=[UIButton buttonWithType:UIButtonTypeSystem];
    determineButton.frame=CGRectMake(SCREEN_WIDTH*8/25, 162, SCREEN_WIDTH*4/25, SCREEN_HEIGHT/20);
    determineButton.titleLabel.font=[UIFont systemFontOfSize:20];
    [determineButton setTitle:@"确定" forState:UIControlStateNormal];
    determineButton.tag=sender.tag;
    [determineButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
    [determineButton addTarget:self action:@selector(determineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [dateView addSubview:PickerView];
    [dateView addSubview:determineButton];
    [view addSubview:dateView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGesture:)];
    [view addGestureRecognizer:tapGesture];
}
//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGesture:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<dateView.frame.origin.x || point.x >dateView.frame.origin.x+dateView.frame.size.width || point.y<dateView.frame.origin.y || point.y>dateView.frame.origin.y+dateView.frame.size.height)
    {
        [dateView removeFromSuperview];
        [view removeFromSuperview];
    }
}
//弹出view中确定按钮的点击事件
-(void)determineButtonClick:(UIButton *)sender
{
    if (sender.tag==1)
    {
        NSString *yearString=[NSString stringWithFormat:@"%@",[_begainDateYearArray objectAtIndex:yearBegainSelectIndex]];
        NSString *monthString=[NSString stringWithFormat:@"%@",[_begainDateMonthArray objectAtIndex:monthBegainSelectIndex]];
        NSString *dayString;
        if (dayBegainSelectIndex>_begainDateDayArray.count-1)
        {
            if (_begainDateDayArray.count==30)
            {
                dayString=@"30";
            }
            else if (_begainDateDayArray.count==29)
            {
                dayString=@"29";
            }
            else if (_begainDateDayArray.count==28)
            {
                dayString=@"28";
            }
        }
        else
        {
            dayString=[NSString stringWithFormat:@"%@",[_begainDateDayArray objectAtIndex:dayBegainSelectIndex]];
        }
        BegainTime=[NSString stringWithFormat:@"%@-%@-%@",yearString,monthString,dayString];
        if ([self getIntervalTimeFrom:[self stringToDate:BegainTime] toDate:[self stringToDate:dateTwo_Button.titleLabel.text]]>=0)
        {
            [dateOne_Button setTitle:BegainTime forState:UIControlStateNormal];
            yearBegainIndex=yearBegainSelectIndex;
            monthBegainIndex=monthBegainSelectIndex;
            dayBegainIndex=dayBegainSelectIndex;
        }
        else
        {
            //提示日期选择错误
            BegainTime=dateOne_Button.titleLabel.text;
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"开始时间不能选择在截止日期之后" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
    }
    else
    {
        NSString *yearString=[NSString stringWithFormat:@"%@",[_endDateYearArray objectAtIndex:yearEndSelectIndex]];
        NSString *monthString=[NSString stringWithFormat:@"%@",[_endDateMonthArray objectAtIndex:monthEndSelectIndex]];
        NSString *dayString;
        if (dayEndSelectIndex>_endDateDayArray.count-1)
        {
            if (_endDateDayArray.count==30)
            {
                dayString=@"30";
            }
            else if (_endDateDayArray.count==29)
            {
                dayString=@"29";
            }
            else if (_endDateDayArray.count==28)
            {
                dayString=@"28";
            }
        }
        else
        {
            dayString=[NSString stringWithFormat:@"%@",[_endDateDayArray objectAtIndex:dayEndSelectIndex]];
        }
        EndTime=[NSString stringWithFormat:@"%@-%@-%@",yearString,monthString,dayString];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *nowTime=[dateFormatter stringFromDate:[NSDate date]];
        if ([self getIntervalTimeFrom:[self stringToDate:EndTime] toDate:[self stringToDate:nowTime]]>=0)
        {
            if([self getIntervalTimeFrom:[self stringToDate:dateOne_Button.titleLabel.text] toDate:[self stringToDate:EndTime]]>=0)
            {
                [dateTwo_Button setTitle:EndTime forState:UIControlStateNormal];
                yearEndIndex=yearEndSelectIndex;
                monthEndIndex=monthEndSelectIndex;
                dayEndIndex=dayEndSelectIndex;
            }
            else
            {
                //提示日期选择错误
                EndTime=dateTwo_Button.titleLabel.text;
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"截止时间不能选择在开始日期之前" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
            }
        }
        else
        {
            //提示日期选择错误
            EndTime=dateTwo_Button.titleLabel.text;
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"截止时间不能选择在系统日期之后" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
    }
    [dateView removeFromSuperview];
    [view removeFromSuperview];
    
    //更新开始日期跟结束日期的数组
    if (flag==1)
    {
        [SleepEvaluate removeAllObjects];
    }
    else if (flag==2)
    {
        [DepressedEvaluate removeAllObjects];
    }
    else if (flag==3)
    {
        [WorriedEvaluate removeAllObjects];
    }
    else if (flag==4)
    {
        [BodyEvaluate removeAllObjects];
    }
    for (int i=0; i<evaluateData.count; i++)
    {
        EvaluateInfo *tmpEvaluateInfo=[evaluateData objectAtIndex:i];
        NSInteger tmpOne=[self getIntervalTimeFrom:[self stringToDate:BegainTime] toDate:[self stringToDate:tmpEvaluateInfo.Date]];
        NSInteger tmpTwo=[self getIntervalTimeFrom:[self stringToDate:tmpEvaluateInfo.Date] toDate:[self stringToDate:EndTime]];
        if (tmpOne>=0 && tmpTwo>=0 && [tmpEvaluateInfo.PatientID isEqualToString:_patientInfo.PatientID])
        {
            if ([tmpEvaluateInfo.ListFlag isEqualToString:@"1"])
            {
                [SleepEvaluate addObject:tmpEvaluateInfo];
            }
            else if ([tmpEvaluateInfo.ListFlag isEqualToString:@"2"])
            {
                [DepressedEvaluate addObject:tmpEvaluateInfo];
            }
            else if ([tmpEvaluateInfo.ListFlag isEqualToString:@"3"])
            {
                [WorriedEvaluate addObject:tmpEvaluateInfo];
            }
            else if ([tmpEvaluateInfo.ListFlag isEqualToString:@"4"])
            {
                [BodyEvaluate addObject:tmpEvaluateInfo];
            }
        }
    }
    if (SleepEvaluate.count>0)
    {
        [self bubbleSort:SleepEvaluate];
    }
    if (DepressedEvaluate.count>0)
    {
        [self bubbleSort:DepressedEvaluate];
    }
    if (WorriedEvaluate.count>0)
    {
        [self bubbleSort:WorriedEvaluate];
    }
    if (BodyEvaluate.count>0)
    {
        [self bubbleSort:BodyEvaluate];
    }
    [DataTableView reloadData];
}

- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (pickerView.tag==1)
    {
        if(component==0)
        {
            return [self.begainDateYearArray count];
        }
        else if(component==1)
        {
            return [self.begainDateMonthArray count];
        }
        else
        {
            return [self.begainDateDayArray count];
        }
    }
    else
    {
        if(component==0)
        {
            return [self.endDateYearArray count];
        }
        else if(component==1)
        {
            return [self.endDateMonthArray count];
        }
        else
        {
            return [self.endDateDayArray count];
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (pickerView.tag==1)
    {
        if (component == 0)
        {
            return self.begainDateYearArray[row];
        }
        else if(component==1)
        {
            return self.begainDateMonthArray[row];
        }
        else
        {
            return self.begainDateDayArray[row];
        }
    }
    else
    {
        if (component == 0)
        {
            return self.endDateYearArray[row];
        }
        else if(component==1)
        {
            return self.endDateMonthArray[row];
        }
        else
        {
            return self.endDateDayArray[row];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView.tag==1)
    {
        if (component == 0)
        {
            yearBegainSelectIndex=row;
        }
        else if(component==1)
        {
            monthBegainSelectIndex=row;
        }
        else
        {
            dayBegainSelectIndex=row;
        }
        NSInteger tmp=1900+yearBegainSelectIndex;
        //判断是否是闰年，其他为平年
        if ((tmp%4==0 && tmp%100!=0) || (tmp%100==0 && tmp%400==0))//闰年
        {
            if (monthBegainSelectIndex==1)//2月份闰年的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i=1; i<=29; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex==0 || monthBegainSelectIndex==2 || monthBegainSelectIndex==4 || monthBegainSelectIndex==6 || monthBegainSelectIndex==7 || monthBegainSelectIndex==9 || monthBegainSelectIndex==11)//大月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i=1; i<=31; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex==3 || monthBegainSelectIndex==5 || monthBegainSelectIndex==8 || monthBegainSelectIndex==10)//小月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i=1; i<=30; i++)//小月的天数
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
//                if (!(dayBegainIndex<30))
//                {
//                    dayBegainIndex=29;
//                    dayBegainSelectIndex=29;
//                }
            }
        }
        else//平年
        {
            if (monthBegainSelectIndex==1)//2月份平年的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i=1; i<=28; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex==0 || monthBegainSelectIndex==2 || monthBegainSelectIndex==4 || monthBegainSelectIndex==6 || monthBegainSelectIndex==7 || monthBegainSelectIndex==9 || monthBegainSelectIndex==11)//大月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i=1; i<=31; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
            }
            else if(monthBegainSelectIndex==3 || monthBegainSelectIndex==5 || monthBegainSelectIndex==8 || monthBegainSelectIndex==10)//小月的天数
            {
                [_begainDateDayArray removeAllObjects];
                for (int i=1; i<=30; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_begainDateDayArray addObject:dayStr];
                }
//                if (!(dayBegainIndex<30))
//                {
//                    dayBegainIndex=29;
//                    dayBegainSelectIndex=29;
//                }
            }
        }
        [PickerView reloadComponent:2];
    }
    else
    {
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        if (component == 0)
        {
            yearEndSelectIndex=row;
        }
        else if(component==1)
        {
            monthEndSelectIndex=row;
        }
        else
        {
            dayEndSelectIndex=row;
        }
        NSInteger tmp=1900+yearEndSelectIndex;
        //判断是否是闰年，其他为平年
        if ((tmp%4==0 && tmp%100!=0) || (tmp%100==0 && tmp%400==0))//闰年
        {
            if (monthEndSelectIndex==1)//2月份闰年的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i=1; i<=29; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else if(monthEndSelectIndex==0 || monthEndSelectIndex==2 || monthEndSelectIndex==4 || monthEndSelectIndex==6 || monthEndSelectIndex==7 || monthEndSelectIndex==9 || monthEndSelectIndex==11)//大月的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i=1; i<=31; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else
            {
                [_endDateDayArray removeAllObjects];
                for (int i=1; i<=30; i++)//小月的天数
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
//                if (!(dayEndIndex<30))
//                {
//                    dayEndIndex=29;
//                    dayEndSelectIndex=29;
//                }
            }
        }
        else//平年
        {
            if (monthEndSelectIndex==1)//2月份平年的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i=1; i<=28; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else if(monthEndSelectIndex==0 || monthEndSelectIndex==2 || monthEndSelectIndex==4 || monthEndSelectIndex==6 || monthEndSelectIndex==7 || monthEndSelectIndex==9 || monthEndSelectIndex==11)//大月的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i=1; i<=31; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
            }
            else if(monthEndSelectIndex==3 || monthEndSelectIndex==5 || monthEndSelectIndex==8 || monthEndSelectIndex==10)//小月的天数
            {
                [_endDateDayArray removeAllObjects];
                for (int i=1; i<=30; i++)
                {
                    NSString *dayStr=[NSString stringWithFormat:@"%d",i];
                    [_endDateDayArray addObject:dayStr];
                }
//                if (!(dayEndIndex<30))
//                {
//                    dayEndIndex=29;
//                    dayEndSelectIndex=29;
//                }
            }
        }
        [PickerView reloadComponent:2];
    }
}

#pragma mark -
#pragma mark URL Connection Data Delegate Methods

// 刚开始接受响应时调用
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response
{
    [webData setLength: 0];
}

// 每接收到一部分数据就追加到webData中
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *) data
{
    [webData appendData:data];
}

// 出现错误时
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    conn = nil;
    webData = nil;
}

// 完成接收数据时调用
-(void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes]
                                                length:[webData length]
                                              encoding:NSUTF8StringEncoding];
    
    // 打印出得到的XML
    NSLog(@"%@", theXML);
    // 使用NSXMLParser解析出我们想要的结果
    xmlParser = [[NSXMLParser alloc] initWithData: webData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
}


#pragma mark -
#pragma mark XML Parser Delegate Methods

// 开始解析一个元素名
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:matchingElement])
    {
        if (!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        elementFound = YES;
    }
}

// 追加找到的元素值，一个元素值可能要分几次追加
-(void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if (elementFound)
    {
        [soapResults appendString: string];
    }
}

// 结束解析这个元素名
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:matchingElement])
    {
        if ([matchingElement isEqualToString:@"APP_GetEvaluateDataResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            if (resultArray.count!=0)
            {
                //EvaluateInfo *tmp_evaluateInfo=[[EvaluateInfo alloc] init];
                for (int i=0; i<resultArray.count; i++)
                {
                    EvaluateInfo *tmp_evaluateInfo=[[EvaluateInfo alloc] init];
                    tmp_evaluateInfo.PatientID=_patientInfo.PatientID;
                    tmp_evaluateInfo.ListFlag=[[resultArray objectAtIndex:i] objectForKey:@"Type"];
                    tmp_evaluateInfo.Date=[[resultArray objectAtIndex:i] objectForKey:@"Date"];
                    tmp_evaluateInfo.Time=[[resultArray objectAtIndex:i] objectForKey:@"SaveTime"];
                    tmp_evaluateInfo.Score=[[resultArray objectAtIndex:i] objectForKey:@"Score"];
                    tmp_evaluateInfo.Quality=[[resultArray objectAtIndex:i] objectForKey:@"Quality"];
                    
                    EvaluateInfo *tmpInfo;
                    for (EvaluateInfo *tmp in evaluateData)
                    {
                        if ([tmp_evaluateInfo.Date isEqualToString:tmp.Date] && [tmp_evaluateInfo.ListFlag isEqualToString:tmp.ListFlag] && [tmp_evaluateInfo.PatientID isEqualToString:_patientInfo.PatientID])
                        {
                            tmpInfo=tmp;
                        }
                    }
                    if (tmpInfo==nil)
                    {
                        [evaluateData addObject:tmp_evaluateInfo];
                        dbOpration=[[DataBaseOpration alloc] init];
                        [dbOpration insertEvaluateInfo:tmp_evaluateInfo];
                        [dbOpration closeDataBase];
                    }
                }
                [SleepEvaluate removeAllObjects];
                [DepressedEvaluate removeAllObjects];
                [WorriedEvaluate removeAllObjects];
                [BodyEvaluate removeAllObjects];
                [self putEvaluateDataToArray];
                [DataTableView reloadData];
            }
            
        }
        elementFound = FALSE;
        // 强制放弃解析
        [xmlParser abortParsing];
    }
}

// 解析整个文件结束后
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

// 出错时，例如强制结束解析
- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

//计算两个时间点之间的时间差（即计算治疗时间）
-(NSInteger)getIntervalTimeFrom:(NSDate *)StartDate toDate:(NSDate *)FinishDate
{
    NSCalendar *cal=[[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    unsigned int unitFlags=NSCalendarUnitDay;
    NSDateComponents *interval=[cal components:unitFlags fromDate:StartDate toDate:FinishDate options:0];
//    NSLog(@"%ld",(long)[interval day]);
    return [interval day];
}
//把字符串转换成日期
-(NSDate *)stringToDate:(NSString *)dateString
{
    NSDateFormatter *inputForMatter=[[NSDateFormatter alloc] init];
    [inputForMatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *inputDate=[inputForMatter dateFromString:dateString];
    return inputDate;
}
//把日期转换成字符串
-(NSString *)dateToString:(NSDate *)stringDate
{
    NSDateFormatter *outputForMatter=[[NSDateFormatter alloc] init];
    [outputForMatter setDateFormat:@"yyyy/MM/dd"];
    NSString *outputDate=[outputForMatter stringFromDate:stringDate];
    return outputDate;
}

//冒泡排序
-(void)bubbleSort:(NSMutableArray *)array
{
    for (int j=0; j<array.count-1; j++)
    {
        for (int i=0; i<array.count-1-j; i++)
        {
            EvaluateInfo *index_One=[array objectAtIndex:i];
            EvaluateInfo *index_Two=[array objectAtIndex:i+1];
            if ([index_One.Date compare:index_Two.Date]==NSOrderedDescending)
            {
                [array exchangeObjectAtIndex:i withObjectAtIndex:i+1];
            }
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
