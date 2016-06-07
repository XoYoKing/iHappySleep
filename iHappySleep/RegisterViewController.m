//
//  RegisterViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/2.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "RegisterViewController.h"
#import "myHeader.h"
#import "PatientInfo.h"
#import "DataBaseOpration.h"
#import "ViewController.h"
#import "MyIndicatorView.h"

@interface RegisterViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate,UITextFieldDelegate>

@end

@implementation RegisterViewController
{
    UITextField *phoneNumTextField;
    UIButton *verifyButton;
    UITextField *verifyNumTextField;
    UITextField *passwordTextField;
    UITextField *userNameTextField;
    UILabel *dateLabel;
    MyButton *choseManButton;
    MyButton *choseWomanButton;
    
    UIView *view;
    UIView *dateView;
    
    UIAlertView *alert;
    
    NSString *code;
    NSString *state;
    NSString *description;
    NSString *verifyState;
    NSString *verifyDescription;
    
    UIPickerView *PickerView;
    NSInteger monthIndex;
    NSInteger yearIndex;
    NSString *sexString;
    
    NSInteger year;
    NSInteger month;
    
    PatientInfo *patientInfo;
    
    DataBaseOpration *dataBaseOpration;
    
    NSTimer *m_timer; //设置验证按钮计时器
    int secondsCountDown;
    
    BOOL isOverTime;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    patientInfo=[PatientInfo new];
    
    dataBaseOpration=[[DataBaseOpration alloc] init];
    
    
    
    _registerTableView.backgroundColor=[UIColor colorWithWhite:0.95 alpha:0.9];
    _registerTableView.scrollEnabled=NO;
    
    _registerTableView.separatorColor=[UIColor colorWithWhite:0.7 alpha:0.9];
    
    if ([_registerTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_registerTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_registerTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_registerTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    _registerTableView.dataSource=self;
    _registerTableView.delegate=self;
    
    [_registerAndLoginButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    _registerAndLoginButton.titleLabel.font=[UIFont systemFontOfSize:20];
    
    //获取系统当前时间
    NSDate *date=[NSDate date];
    unsigned units  = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay;
    NSCalendar *myCal = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *component = [myCal components:units fromDate:date];
    month = [component month];
    year = [component year];
    
    _dateMonthArray=[NSMutableArray array];
    _dateYearArray=[NSMutableArray array];
    
    for (int i=1; i<=12; i++)
    {
        NSString *monthStr=[NSString stringWithFormat:@"%d",i];
        [_dateMonthArray addObject:monthStr];
    }
    monthIndex=month-1;
    for (int i=1900; i<=year; i++)
    {
        NSString *yearStr=[NSString stringWithFormat:@"%d",i];
        [_dateYearArray addObject:yearStr];
    }
    yearIndex=year-1900;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doHideKeyBoard)];
    tap.numberOfTapsRequired = 1;
    [_registerTableView.backgroundView addGestureRecognizer:tap];
    [self.view  addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    isOverTime=YES;
}

-(void)doHideKeyBoard
{
    [phoneNumTextField resignFirstResponder];
    [verifyNumTextField resignFirstResponder];
    [passwordTextField resignFirstResponder];
    [userNameTextField resignFirstResponder];
}

//注册并登陆按钮的点击事件
- (IBAction)registerAndLoginButtonClick:(id)sender
{
    
    if ([verifyNumTextField.text isEqualToString:code])
    {
        if (passwordTextField.text.length<6 && passwordTextField.text.length>0)
        {
            //提示密码过短
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码不能低于6位，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
        else if (passwordTextField.text.length==0)
        {
            //提示密码过短
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
        else
        {
            //需要加入判断，判断姓名不能为空
            if (userNameTextField.text.length>0)
            {
                //需要加入判断，判断出声日起不能为空
                if (![dateLabel.text isEqualToString:@"选择出生年月"])
                {
                    //需要加入判断，判断性别不能为空
                    if (sexString!=nil)
                    {
                        //添加Loading
                        view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                        view.backgroundColor=[UIColor colorWithWhite:0.2 alpha:0.7];
                        [self.view addSubview:view];
                        [MyIndicatorView show:@"Loading..."];
                        [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(overTime) userInfo:nil repeats:NO];
                        
                        patientInfo.PatientID=phoneNumTextField.text;
                        patientInfo.PatientName=userNameTextField.text;
                        patientInfo.PatientPwd=passwordTextField.text;
                        patientInfo.PatientSex=sexString;
                        patientInfo.CellPhone=phoneNumTextField.text;
                        
                        NSString *yearString=[NSString stringWithFormat:@"%@",[_dateYearArray objectAtIndex:yearIndex]];
                        NSString *monthString=[NSString stringWithFormat:@"%@",[_dateMonthArray objectAtIndex:monthIndex]];
                        patientInfo.Birthday=[NSString stringWithFormat:@"%@年%@月",yearString,monthString];
                        
                        NSDictionary *jsonRegisterPatient = [NSDictionary dictionaryWithObjectsAndKeys:patientInfo.PatientID,@"PatientID",patientInfo.PatientName,@"PatientName",patientInfo.PatientPwd,@"PatientPwd",patientInfo.PatientSex,@"PatientSex",patientInfo.CellPhone,@"CellPhone",patientInfo.Birthday,@"Birthday",@"",@"IDCard",[NSString stringWithFormat:@"%ld",(long)patientInfo.Age],@"Age",@" ",@"Marriage",@"",@"NativePlace",@"",@"BloodModel",@"",@"FamilyPhone",@"",@"Email",@"",@"Vocation",@"",@"Address",@"",@"PatientHeight",@"",@"PatientWeight",@"",@"PatientRemarks",@"",@"Picture",@"2",@"PatientType", nil];
                        NSArray *jsonArray=[NSArray arrayWithObjects:jsonRegisterPatient, nil];
                        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
                        NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
                        NSLog(@"JsonString>>>>%@",jsonString);
                        
                        // 设置我们之后解析XML时用的关键字
                        matchingElement = @"APP_RegisterPatientResponse";
                        // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
                        NSString *soapMsg = [NSString stringWithFormat:
                                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                             "<soap12:Envelope "
                                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                             "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                             "<soap12:Body>"
                                             "<APP_RegisterPatient xmlns=\"MeetingOnline\">"
                                             "<JsonRegisterInfo>%@</JsonRegisterInfo>"
                                             "</APP_RegisterPatient>"
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
                    else
                    {
                        //提示请选择性别
                        alert = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择性别" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                        [alert show];
                    }
                }
                else
                {
                    //提示请选择出生年月
                    alert = [[UIAlertView alloc] initWithTitle:nil message:@"请先选择出生年月" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                    [alert show];
                }
            }
            else
            {
                //提示姓名不能为空
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"姓名不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
            }
        }
    }
    else if(verifyNumTextField.text==nil)
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"验证码不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        [alert show];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"验证码输入错误，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        [alert show];
    }
}

- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}

//tableview的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 6;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identity=@"Register";
    if (indexPath.row==0)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        UIImageView *cellPhoneImageView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/15, 15, SCREEN_WIDTH/18, 20)];
        [cellPhoneImageView setImage:[UIImage imageNamed:@"register_phone"]];
        
        phoneNumTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 0, SCREEN_WIDTH*11/20, 50)];
        phoneNumTextField.font=[UIFont systemFontOfSize:20];
        phoneNumTextField.placeholder=@"11位手机号";
        phoneNumTextField.keyboardType=UIKeyboardTypeNumberPad;
        phoneNumTextField.delegate=self;
        
        //verifyButton=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, 0, SCREEN_WIDTH/4, 50)];
        verifyButton=[UIButton buttonWithType:UIButtonTypeSystem];
        verifyButton.frame=CGRectMake(SCREEN_WIDTH*3/4, 0, SCREEN_WIDTH/4, 50);
        verifyButton.tag=1;
        verifyButton.titleLabel.font=[UIFont systemFontOfSize:20];
        [verifyButton setTitle:@"验证" forState:UIControlStateNormal];
        //[verifyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [verifyButton addTarget:self action:@selector(verifyButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, 0.0f, 0.5f, 50.0f)];
        [lineView setBackgroundColor:[UIColor lightGrayColor]];
        
        
        [cell.contentView addSubview:cellPhoneImageView];
        [cell.contentView addSubview:phoneNumTextField];
        [cell.contentView addSubview:verifyButton];
        [cell addSubview:lineView];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row==1)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        UIImageView *verifyImageView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/15, 15, SCREEN_WIDTH/18, 20)];
        [verifyImageView setImage:[UIImage imageNamed:@"register_message"]];
        
        verifyNumTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 0, SCREEN_WIDTH*11/20, 50)];
        verifyNumTextField.tag=1;
        verifyNumTextField.font=[UIFont systemFontOfSize:20];
        verifyNumTextField.placeholder=@"短信验证码";
        verifyNumTextField.keyboardType=UIKeyboardTypeNumberPad;
        verifyNumTextField.delegate=self;
        
        [cell.contentView addSubview:verifyImageView];
        [cell.contentView addSubview:verifyNumTextField];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row==2)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        UIImageView *passwordImageView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/15, 15, SCREEN_WIDTH/18, 20)];
        [passwordImageView setImage:[UIImage imageNamed:@"register_password"]];
        
        passwordTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 0, SCREEN_WIDTH*11/20, 50)];
        passwordTextField.tag=2;
        passwordTextField.font=[UIFont systemFontOfSize:20];
        passwordTextField.placeholder=@"6-18位密码";
        passwordTextField.secureTextEntry=YES;
        passwordTextField.delegate=self;
        
        [cell.contentView addSubview:passwordImageView];
        [cell.contentView addSubview:passwordTextField];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row==3)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        UIImageView *userNameImageView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/15, 15, SCREEN_WIDTH/18, 20)];
        [userNameImageView setImage:[UIImage imageNamed:@"register_head"]];
        
        userNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 0, SCREEN_WIDTH*11/20, 50)];
        userNameTextField.font=[UIFont systemFontOfSize:20];
        userNameTextField.placeholder=@"姓名";
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEditChanged:) name:UITextFieldTextDidChangeNotification object:userNameTextField];
        
        [cell.contentView addSubview:userNameImageView];
        [cell.contentView addSubview:userNameTextField];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row==4)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        UIImageView *dateImageView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/15, 15, SCREEN_WIDTH/18, 20)];
        [dateImageView setImage:[UIImage imageNamed:@"register_age"]];
        
        dateLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 0, SCREEN_WIDTH*11/20, 50)];
        dateLabel.font=[UIFont systemFontOfSize:20];
        dateLabel.textColor=[UIColor lightGrayColor];
        dateLabel.text=@"选择出生年月";
        
        [cell.contentView addSubview:dateImageView];
        [cell.contentView addSubview:dateLabel];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row==5)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        choseManButton=[[MyButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH/5, 50)];
        UILabel *menLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/5, 0, SCREEN_WIDTH/5, 50)];
        menLabel.font=[UIFont systemFontOfSize:20];
        menLabel.textColor=[UIColor lightGrayColor];
        menLabel.text=@"男";
        UIImageView *register_male=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_male"]];
        register_male.frame=CGRectMake(SCREEN_WIDTH*7/25, 15, SCREEN_WIDTH/20, SCREEN_WIDTH/18);
        choseManButton.tag=0;
        choseManButton.flag=@"男";
        [choseManButton setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [choseManButton addTarget:self action:@selector(choseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        choseWomanButton=[[MyButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2/5, 0, SCREEN_WIDTH/5, 50)];
        UILabel *womenLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/5, 0, SCREEN_WIDTH/5, 50)];
        womenLabel.font=[UIFont systemFontOfSize:20];
        womenLabel.textColor=[UIColor lightGrayColor];
        womenLabel.text=@"女";
        UIImageView *register_female=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"register_female"]];
        register_female.frame=CGRectMake(SCREEN_WIDTH*17/25, 15, SCREEN_WIDTH/23, SCREEN_WIDTH/18);
        choseWomanButton.tag=0;
        choseWomanButton.flag=@"女";
        [choseWomanButton setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [choseWomanButton addTarget:self action:@selector(choseButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.contentView addSubview:choseManButton];
        [cell.contentView addSubview:menLabel];
        [cell.contentView addSubview:register_male];
        [cell.contentView addSubview:choseWomanButton];
        [cell.contentView addSubview:womenLabel];
        [cell.contentView addSubview:register_female];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

//点击选中某个cell时调用
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //判断是不是选择出生年月所在的cell（是，执行下面代码；不是跳出，什么也不执行）
    if (indexPath.row==4)
    {
        view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        view.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
        [self.view.window addSubview:view];
        dateView=[[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, SCREEN_HEIGHT*3/8, SCREEN_WIDTH*4/5, 162+SCREEN_HEIGHT/20)];
        dateView.backgroundColor=[UIColor whiteColor];
        [dateView.layer setCornerRadius:10.0];
        
        PickerView=[[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*4/5, 162)];
        PickerView.autoresizingMask=UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        PickerView.backgroundColor=[UIColor whiteColor];
        [PickerView.layer setCornerRadius:10.0];
        UILabel *yearLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*8/25, 67.5, 30, 27)];
        yearLabel.text=@"年";
        UILabel *monthLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*2/3, 67.5, 30, 27)];
        monthLabel.text=@"月";
        PickerView.delegate=self;
        PickerView.dataSource=self;
        
        if ([dateLabel.text isEqualToString:@"选择出生年月"])
        {
            [PickerView selectRow:year-1900 inComponent:0 animated:YES];
            [PickerView selectRow:month-1 inComponent:1 animated:YES];
        }
        else
        {
            [PickerView selectRow:yearIndex inComponent:0 animated:YES];
            [PickerView selectRow:monthIndex inComponent:1 animated:YES];
        }
        
        [_dateMonthArray removeAllObjects];
        if (yearIndex==year-1900)
        {
            for (int i=1; i<=month; i++)
            {
                NSString *monthStr=[NSString stringWithFormat:@"%d",i];
                [_dateMonthArray addObject:monthStr];
            }
        }
        else
        {
            for (int i=1; i<=12; i++)
            {
                NSString *monthStr=[NSString stringWithFormat:@"%d",i];
                [_dateMonthArray addObject:monthStr];
            }
        }
        [PickerView reloadAllComponents];
        [PickerView addSubview:yearLabel];
        [PickerView addSubview:monthLabel];
        
        UIButton *determineButton=[UIButton buttonWithType:UIButtonTypeSystem];
        determineButton.frame=CGRectMake(SCREEN_WIDTH*8/25, 162, SCREEN_WIDTH*4/25, SCREEN_HEIGHT/20);
        determineButton.titleLabel.font=[UIFont systemFontOfSize:20];
        [determineButton setTitle:@"确定" forState:UIControlStateNormal];
        [determineButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
        [determineButton addTarget:self action:@selector(determineButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [dateView addSubview:PickerView];
        [dateView addSubview:determineButton];
        [view addSubview:dateView];
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGesture:)];
        [view addGestureRecognizer:tapGesture];
    }
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
    NSString *yearString=[NSString stringWithFormat:@"%@",[_dateYearArray objectAtIndex:yearIndex]];
    if (yearIndex==year-1900 && monthIndex>month-1)
    {
        monthIndex=month-1;
    }
    NSString *monthString=[NSString stringWithFormat:@"%@",[_dateMonthArray objectAtIndex:monthIndex]];
    NSString *birthday=[NSString stringWithFormat:@"%@年%@月",yearString,monthString];
    dateLabel.text=birthday;
    //计算用户的Age
    patientInfo.Age=year-[yearString integerValue]+1;
    
    [dateView removeFromSuperview];
    [view removeFromSuperview];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if(component==0)
    {
        return [self.dateYearArray count];
    }
    else
    {
        return [self.dateMonthArray count];
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        return self.dateYearArray[row];
    }
    else
    {
        return self.dateMonthArray[row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0)
    {
        yearIndex=row;
        if (yearIndex==year-1900)
        {
            [_dateMonthArray removeAllObjects];
            for (int i=1; i<=month; i++)
            {
                NSString *monthStr=[NSString stringWithFormat:@"%d",i];
                [_dateMonthArray addObject:monthStr];
            }
        }
        else
        {
            [_dateMonthArray removeAllObjects];
            for (int i=1; i<=12; i++)
            {
                NSString *monthStr=[NSString stringWithFormat:@"%d",i];
                [_dateMonthArray addObject:monthStr];
            }
        }
        [PickerView reloadComponent:1];
    }
    else
    {
        monthIndex=row;
    }
}

//验证按钮的点击事件
-(void)verifyButton:(UIButton *)sender
{
    //发送短信之前调用验证手机号借口（根据返回结果判断此手机号是否能注册）
    if ([self isMobileNumber:phoneNumTextField.text])
    {
        NSString *phoneNum=phoneNumTextField.text;
        NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:phoneNum,@"CellPhone",nil];
        NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
        
        // 设置我们之后解析XML时用的关键字
        matchingElement = @"APP_VerifyPhoneResponse";
        // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
        NSString *soapMsg = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap12:Envelope "
                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                             "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap12:Body>"
                             "<APP_VerifyPhone xmlns=\"MeetingOnline\">"
                             "<JsonPhone>%@</JsonPhone>"
                             "</APP_VerifyPhone>"
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
    else
    {
        //提示输入的不是手机号码
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"手机号格式错误，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        
        [alert show];
    }
}
-(void)calcuRemainTime
{
    secondsCountDown--;
    NSString *strTime = [NSString stringWithFormat:@"%.2d秒", secondsCountDown];
    [verifyButton setTitle:strTime forState:UIControlStateNormal];
    if (secondsCountDown<=0)
    {
        [m_timer invalidate];
        [verifyButton setTitle:@"验证" forState:UIControlStateNormal];
        verifyButton.userInteractionEnabled=YES;
    }
}

//单选框的点击事件
-(void)choseButtonClick:(MyButton *)sender
{
    if ([sender.flag isEqualToString:@"男"])
    {
        if (sender.tag==0 && choseWomanButton.tag==0)
        {
            sender.tag=1;
            [sender setImage:[UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
            sexString=@"男";
        }
        else if (sender.tag==0 && choseWomanButton.tag==1)
        {
            sender.tag=1;
            choseWomanButton.tag=0;
            [sender setImage:[UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
            [choseWomanButton setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
            sexString=@"男";
        }
        else if (sender.tag==1 && choseWomanButton.tag==0)
        {
            sender.tag=0;
            [sender setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
            sexString=@"";
        }
    }
    else if ([sender.flag isEqualToString:@"女"])
    {
        if (sender.tag==0 && choseManButton.tag==0)
        {
            sender.tag=1;
            [sender setImage:[UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
            sexString=@"女";
        }
        else if (sender.tag==0 && choseManButton.tag==1)
        {
            sender.tag=1;
            choseManButton.tag=0;
            [sender setImage:[UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
            [choseManButton setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
            sexString=@"女";
        }
        else if (sender.tag==1 && choseManButton.tag==0)
        {
            sender.tag=0;
            [sender setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
            sexString=@"";
        }
    }
}

-(void)overTime
{
    if (isOverTime==YES)
    {
        //隐藏Loading
        [MyIndicatorView dismiss];
        [view removeFromSuperview];
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"登录超时" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil];
        [alert show];
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
        if ([matchingElement isEqualToString:@"APP_SendShortMessageResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            code=[resultDic objectForKey:@"Code"];
            NSLog(@"%@",code);
        }
        else if ([matchingElement isEqualToString:@"APP_RegisterPatientResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            state=[resultDic objectForKey:@"state"];
            description=[resultDic objectForKey:@"description"];
            NSLog(@"%@,%@",state,description);
            if ([state isEqualToString:@"OK"])
            {
                ViewController *Main=[[ViewController alloc] init];
                Main.patientInfo=patientInfo;
                [self.navigationController pushViewController:Main animated:YES];
                
                //隐藏Loading
                [MyIndicatorView dismiss];
                [view removeFromSuperview];
                isOverTime=NO;
                
                //设置自动登录
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                [userDefault setValue:phoneNumTextField.text forKey:@"PatientID"];
                [userDefault setValue:passwordTextField.text forKey:@"PatientPwd"];
                
                
                //将Patient对象存储到本地sqlite数据库
                [dataBaseOpration insertUserInfo:patientInfo];
                [dataBaseOpration closeDataBase];
            }
            else if ([state isEqualToString:@"NO"])
            {
                //按照服务器返回 提示description中返回的内容
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"该手机号已注册，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
            }
        }
        else if ([matchingElement isEqualToString:@"APP_VerifyPhoneResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            verifyState=[resultDic objectForKey:@"state"];
            verifyDescription=[resultDic objectForKey:@"description"];
            
            //判断输入的手机号是否可以注册
            if ([verifyState isEqualToString:@"OK"])
            {
                //做90秒倒计时
                m_timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calcuRemainTime) userInfo:nil repeats:YES];
                secondsCountDown=90;
                NSString *strTime = [NSString stringWithFormat:@"%.2d秒", secondsCountDown];
                [verifyButton setTitle:strTime forState:UIControlStateNormal];
                verifyButton.userInteractionEnabled=NO;
                
                NSString *phoneNum=phoneNumTextField.text;
                NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:phoneNum,@"CellPhone",nil];
                NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
                NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
                NSLog(@"JsonString>>>>%@",jsonString);
                
                // 设置我们之后解析XML时用的关键字
                matchingElement = @"APP_SendShortMessageResponse";
                // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
                NSString *soapMsg = [NSString stringWithFormat:
                                     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                     "<soap12:Envelope "
                                     "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                     "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                     "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                     "<soap12:Body>"
                                     "<APP_SendShortMessage xmlns=\"MeetingOnline\">"
                                     "<JsonPhoneInfo>%@</JsonPhoneInfo>"
                                     "</APP_SendShortMessage>"
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
            else
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:verifyDescription delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                
                [alert show];
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

//姓名输入汉字长度设置的通知方法实现
-(void)textFieldEditChanged:(NSNotification *)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    if(toBeString.length > 15)
    {
        textField.text= [toBeString substringToIndex:15];
    }
}

/*对输入的字符进行限制的代理方法*/
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag==1)
    {
        NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:NUM] invertedSet];
        NSString *filtered=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        NSString *toBeString=[textField.text stringByReplacingCharactersInRange:range withString:string];
        if (toBeString.length>6 && range.length!=1)
        {
            textField.text=[toBeString substringToIndex:6];
            alert=[[UIAlertView alloc] initWithTitle:nil message:@"输入过长！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        return [string isEqualToString:filtered];
    }
    else if (textField.tag==2)
    {
        NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:ALNUM] invertedSet];
        NSString *filtered=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        NSString *toBeString=[textField.text stringByReplacingCharactersInRange:range withString:string];
        if (toBeString.length>18 && range.length!=1)
        {
            textField.text=[toBeString substringToIndex:18];
            alert=[[UIAlertView alloc] initWithTitle:nil message:@"输入过长！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
            return NO;
        }
        return [string isEqualToString:filtered];
    }
    else
    {
        return YES;
    }
}

///// 手机号码的有效性判断

//检测是否是手机号码
- (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:mobileNum] == YES)
        || ([regextestcm evaluateWithObject:mobileNum] == YES)
        || ([regextestct evaluateWithObject:mobileNum] == YES)
        || ([regextestcu evaluateWithObject:mobileNum] == YES))
    {
        return YES;
    }
    else
    {
        return NO;
    }
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
