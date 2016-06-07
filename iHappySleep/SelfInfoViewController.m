//
//  SelfInfoViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/7.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "SelfInfoViewController.h"
#import "myHeader.h"
#import "DataBaseOpration.h"

@interface SelfInfoViewController ()<UITextFieldDelegate,NSXMLParserDelegate,NSURLConnectionDelegate,UIAlertViewDelegate,UITextViewDelegate>

@end

@implementation SelfInfoViewController
{
    NSArray *SelfInfoArray;
    NSString *code;                      //存储接口返回的短信验证码
    NSString *State;                     //修改绑定接口返回的状态
    NSString *Description;               //修改绑定接口返回的错误信息
    
    UITextField *userNameTextField;
    UILabel *sex_Label;
    UIButton *birthButton;
    UITextField *homeTextField;
    UITextField *emailTextField;
    UITextView *addressTextView;
    UITextView *remarkTextView;
    
    UITableView *sexTableView;
    
    UIPickerView *PickerView;
    NSInteger monthIndex;
    NSInteger yearIndex;
    NSString *sexString;
    NSInteger year;
    NSInteger month;
    
    UIView *view;
    UIView *childView;
    UILabel *sexLabel;
    UIView *lineBlue;
    UIView *dateView;
    
    UIAlertView *alert;
    
    DataBaseOpration *dbOpration;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    _SelfInfoTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT*9/10)];
    _SelfInfoTableView.tableFooterView=[[UIView alloc] init];
    _SelfInfoTableView.tag=1;
    //_SelfInfoTableView.contentInset=UIEdgeInsetsMake(-64, 0, 0, 0);
    _SelfInfoTableView.delegate=self;
    _SelfInfoTableView.dataSource=self;
    [self.view addSubview:_SelfInfoTableView];
    
    UIButton *quitLogin=[UIButton buttonWithType:UIButtonTypeSystem];
    quitLogin.frame=CGRectMake(SCREEN_WIDTH/3, SCREEN_HEIGHT-SCREEN_HEIGHT/10, SCREEN_WIDTH/3, SCREEN_HEIGHT/15);
    [quitLogin setTitle:@"退出登录" forState:UIControlStateNormal];
    quitLogin.titleLabel.font=[UIFont systemFontOfSize:20];
    [quitLogin addTarget:self action:@selector(quitLoginClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:quitLogin];
    
    SelfInfoArray=@[@"账号",@"姓名",@"性别",@"出生年月",@"联系方式",@"电子邮箱",@"住址",@"备注"];

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
    [_SelfInfoTableView.backgroundView addGestureRecognizer:tap];
    [self.view  addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}
/*点击编辑区域外的view收起键盘*/
-(void)doHideKeyBoard
{
    [userNameTextField resignFirstResponder];
    [homeTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
    [addressTextView resignFirstResponder];
    [remarkTextView resignFirstResponder];
}

-(void)quitLoginClick:(UIButton *)sender
{
    //切换用户提示
    UIAlertView *alertView=[[UIAlertView alloc] initWithTitle:@"是否切换用户？" message:nil delegate:self cancelButtonTitle:@"是" otherButtonTitles:@"否", nil];
    alertView.tag=0;
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag==0)
    {
        if (buttonIndex==0)
        {
            //切换账号
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientID"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"PatientPwd"];
            //清除缓存（例：绑定刺激仪后，切换用户，不断开外设以及清楚缓存，刺激仪将一致处于连接状态）
            NSNotification *notification=[NSNotification notificationWithName:@"ChangeUser" object:self];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            //删除本地数据库蓝牙绑定信息
            dbOpration=[[DataBaseOpration alloc] init];
            [dbOpration deletePeripheralInfo];
            //调用AppDelegate的代理方法，切换根视图
            UIApplication *app=[UIApplication sharedApplication];
            AppDelegate *appDelegate=app.delegate;
            [appDelegate application:app didFinishLaunchingWithOptions:nil];
        }
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag==1)
    {
        return SelfInfoArray.count;
    }
    else
    {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1)
    {
        return (SCREEN_HEIGHT-65)/11;
    }
    else
    {
        return 49;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1)
    {
        static NSString *identify=@"SelfInfoTableViewCell";
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        cell.textLabel.text=[SelfInfoArray objectAtIndex:indexPath.row];
        if (SCREEN_WIDTH==320)
        {
            cell.textLabel.font=[UIFont systemFontOfSize:18];
        }
        else
        {
            cell.textLabel.font=[UIFont systemFontOfSize:20];
        }
        if (indexPath.row==0)
        {
            UITextField *userTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2-10, (SCREEN_HEIGHT-65)/11)];
            userTextField.textAlignment=NSTextAlignmentRight;
            if (SCREEN_WIDTH==320)
            {
                userTextField.font=[UIFont systemFontOfSize:18];
            }
            else
            {
                userTextField.font=[UIFont systemFontOfSize:20];
            }
            if (_patientInfo.PatientID.length>0)
            {
                userTextField.text=_patientInfo.PatientID;
            }
            [userTextField setEnabled:NO];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:userTextField];
        }
        else if (indexPath.row==1)
        {
            userNameTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2-10, (SCREEN_HEIGHT-65)/11)];
            [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFiledEditChanged:)
                                                       name:@"UITextFieldTextDidChangeNotification"
                                                     object:userNameTextField];
            userNameTextField.textAlignment=NSTextAlignmentRight;
            if (SCREEN_WIDTH==320)
            {
                userNameTextField.font=[UIFont systemFontOfSize:18];
            }
            else
            {
                userNameTextField.font=[UIFont systemFontOfSize:20];
            }
            if (_patientInfo.PatientName.length>0)
            {
                userNameTextField.text=_patientInfo.PatientName;
            }
            userNameTextField.tag=1;
            userNameTextField.delegate=self;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:userNameTextField];
        }
        else if (indexPath.row==2)
        {
            sex_Label=[[UILabel alloc] init];
            sex_Label.userInteractionEnabled=YES;
            sex_Label.frame=CGRectMake(SCREEN_WIDTH*9/10, 0, SCREEN_WIDTH/15, (SCREEN_HEIGHT-65)/11);
            sex_Label.textAlignment=NSTextAlignmentRight;
            if (SCREEN_WIDTH==320)
            {
                sex_Label.font=[UIFont systemFontOfSize:18];
            }
            else
            {
                sex_Label.font=[UIFont systemFontOfSize:20];
            }
            if (_patientInfo.PatientSex.length>0)
            {
                sex_Label.text=_patientInfo.PatientSex;
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:sex_Label];
        }
        else if (indexPath.row==3)
        {
            birthButton=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2-10, (SCREEN_HEIGHT-65)/11)];
            birthButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
            if (SCREEN_WIDTH==320)
            {
                birthButton.titleLabel.font=[UIFont systemFontOfSize:18];
            }
            else
            {
                birthButton.titleLabel.font=[UIFont systemFontOfSize:20];
            }
            if (_patientInfo.Birthday.length>0)
            {
                [birthButton setTitle:_patientInfo.Birthday forState:UIControlStateNormal];
                [birthButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [birthButton addTarget:self action:@selector(chooseBirthday) forControlEvents:UIControlEventTouchUpInside];
            }
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:birthButton];
        }
        else if (indexPath.row==4)
        {
            UITextField *connectTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2-10, (SCREEN_HEIGHT-65)/11)];
            connectTextField.textAlignment=NSTextAlignmentRight;
            if (SCREEN_WIDTH==320)
            {
                connectTextField.font=[UIFont systemFontOfSize:18];
            }
            else
            {
                connectTextField.font=[UIFont systemFontOfSize:20];
            }
            if (_patientInfo.CellPhone.length>0)
            {
                connectTextField.text=_patientInfo.CellPhone;
            }
            [connectTextField setEnabled:NO];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:connectTextField];
        }
        else if (indexPath.row==5)
        {
            emailTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, 0, SCREEN_WIDTH*2/3-10, (SCREEN_HEIGHT-65)/11)];
            emailTextField.textAlignment=NSTextAlignmentRight;
            if (SCREEN_WIDTH==320)
            {
                emailTextField.font=[UIFont systemFontOfSize:18];
            }
            else
            {
                emailTextField.font=[UIFont systemFontOfSize:20];
            }
            if (_patientInfo.Email.length>0 && ![_patientInfo.Email isEqualToString:@"(null)"])
            {
                emailTextField.text=_patientInfo.Email;
            }
            else if ([_patientInfo.Email isEqualToString:@"(null)"])
            {
                emailTextField.placeholder=@"未填写";
            }
            else
            {
                emailTextField.placeholder=@"未填写";
            }
            emailTextField.tag=6;
            emailTextField.delegate=self;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:emailTextField];
        }
        else if (indexPath.row==6)
        {
            addressTextView=[[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, 0, SCREEN_WIDTH*2/3-10, (SCREEN_HEIGHT-65)/11)];
            addressTextView.textAlignment=NSTextAlignmentRight;
            addressTextView.font=[UIFont systemFontOfSize:20];
            if (_patientInfo.Address.length>0 && ![_patientInfo.Address isEqualToString:@"(null)"])
            {
                addressTextView.text=_patientInfo.Address;
            }
            else if ([_patientInfo.Address isEqualToString:@"(null)"])
            {
                addressTextView.text=@"";
            }
            else
            {
                addressTextView.text=@"";
            }
            addressTextView.tag=7;
            addressTextView.delegate=self;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:addressTextView];
        }
        else if (indexPath.row==7)
        {
            remarkTextView=[[UITextView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/3, 0, SCREEN_WIDTH*2/3-10, (SCREEN_HEIGHT-65)/11)];
            remarkTextView.textAlignment=NSTextAlignmentRight;
            remarkTextView.font=[UIFont systemFontOfSize:20];
            if (_patientInfo.PatientRemarks.length>0 && ![_patientInfo.Email isEqualToString:@"(null)"])
            {
                remarkTextView.text=_patientInfo.PatientRemarks;
            }
            else if ([_patientInfo.Email isEqualToString:@"(null)"])
            {
                remarkTextView.text=@"";
            }
            else
            {
                remarkTextView.text=@"";
            }
            remarkTextView.tag=8;
            remarkTextView.delegate=self;
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            [cell.contentView addSubview:remarkTextView];
        }
        
        return cell;
    }
    else
    {
        static NSString *identify=@"SexTableView";
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identify];
        if (indexPath.row==0)
        {
            cell.textLabel.text=@"男";
        }
        else if (indexPath.row==1)
        {
            cell.textLabel.text=@"女";
        }
        
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag==1)
    {
        if (indexPath.row==2)
        {
            //选择性别
            [self chooseSex];
        }
        else if (indexPath.row==3)
        {
            //调用选择生日按钮的点击事件方法
            [self chooseBirthday];
        }
    }
    else
    {
        if (indexPath.row==0)
        {
            //选择男
            if (![_patientInfo.PatientSex isEqual:@"男"])
            {
                //更新信息
                _patientInfo.PatientSex=@"男";
                sex_Label.text=@"男";
                [self alterSelfInfo];
            }
            
            [sexTableView removeFromSuperview];
            [sexLabel removeFromSuperview];
            [lineBlue removeFromSuperview];
            [childView removeFromSuperview];
            [view removeFromSuperview];
        }
        else if (indexPath.row==1)
        {
            //选择女
            if (![_patientInfo.PatientSex isEqual:@"女"])
            {
                //更新信息
                _patientInfo.PatientSex=@"女";
                sex_Label.text=@"女";
                [self alterSelfInfo];
            }
            
            [sexTableView removeFromSuperview];
            [sexLabel removeFromSuperview];
            [lineBlue removeFromSuperview];
            [childView removeFromSuperview];
            [view removeFromSuperview];
        }
    }
    
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag==5 || textField.tag==6 || textField.tag==7 || textField.tag==8)
    {
        //键盘高度216
        
        //滑动效果（动画）
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -166.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
        
        [UIView commitAnimations];
    }
}

-(void)textFiledEditChanged:(NSNotification*)obj
{
    UITextField *textField = (UITextField *)obj.object;
    NSString *toBeString = textField.text;
    if(toBeString.length > 15)
    {
        textField.text= [toBeString substringToIndex:15];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag==1)
    {
        //修改姓名
        if (_patientInfo!=nil)
        {
            _patientInfo.PatientName=textField.text;
            [self alterSelfInfo];
        }
    }
    else if (textField.tag==5)
    {
        //修改家庭号码
        if (_patientInfo!=nil)
        {
            _patientInfo.FamilyPhone=textField.text;
            [self alterSelfInfo];
        }
    }
    else if (textField.tag==6)
    {
        //修改电子邮件
        if (_patientInfo!=nil)
        {
            if ([self isValidateEmail:textField.text])
            {
                _patientInfo.Email=textField.text;
                [self alterSelfInfo];
            }
            else
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"请检查邮箱输入是否正确" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
            }
        }
    }
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
}

-(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    
    return [emailTest evaluateWithObject:email];
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if (textView.tag==7 || textView.tag==8)
    {
        //键盘高度216
        
        //滑动效果（动画）
        NSTimeInterval animationDuration = 0.30f;
        [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
        [UIView setAnimationDuration:animationDuration];
        
        //将视图的Y坐标向上移动，以使下面腾出地方用于软键盘的显示
        self.view.frame = CGRectMake(0.0f, -166.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
        
        [UIView commitAnimations];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
   if (textView.tag==7)
    {
        //修改地址
        if (_patientInfo!=nil)
        {
            _patientInfo.Address=textView.text;
            [self alterSelfInfo];
        }
    }
    else if (textView.tag==8)
    {
        //修改备注
        if (_patientInfo!=nil)
        {
            _patientInfo.PatientRemarks=textView.text;
            [self alterSelfInfo];
        }
    }
    
    //滑动效果
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@ "ResizeForKeyboard"  context:nil];
    [UIView setAnimationDuration:animationDuration];
    
    //恢复屏幕
    self.view.frame = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height); //64-216
    
    [UIView commitAnimations];
}

/*******修改个人信息借口方法*******/
-(void)alterSelfInfo
{
    NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:_patientInfo.PatientID,@"PatientID",_patientInfo.PatientName,@"PatientName",_patientInfo.PatientPwd,@"PatientPwd",_patientInfo.PatientSex,@"PatientSex",_patientInfo.Birthday,@"Birthday",@"",@"IDCard",[NSString stringWithFormat:@"%ld",(long)_patientInfo.Age],@"Age",_patientInfo.Marriage,@"Marriage",_patientInfo.NativePlace,@"NativePlace",_patientInfo.BloodModel,@"BloodModel",_patientInfo.FamilyPhone,@"FamilyPhone",_patientInfo.CellPhone,@"CellPhone",_patientInfo.Email,@"Email",_patientInfo.Vocation,@"Vocation",_patientInfo.Address,@"Address",_patientInfo.PatientHeight,@"PatientHeight",_patientInfo.PatientWeight,@"PatientWeight",_patientInfo.PatientRemarks,@"PatientRemarks",@"",@"Picture",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    NSLog(@"JsonString>>>>%@",jsonString);
    
    // 设置我们之后解析XML时用的关键字
    matchingElement = @"APP_SavePatientInfoResponse";
    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         "<soap12:Envelope "
                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                         "<soap12:Body>"
                         "<APP_SavePatientInfo xmlns=\"MeetingOnline\">"
                         "<JsonSaveInfo>%@</JsonSaveInfo>"
                         "</APP_SavePatientInfo>"
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
        else if ([matchingElement isEqualToString:@"APP_SavePatientInfoResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            State=[resultDic objectForKey:@"state"];
            Description=[resultDic objectForKey:@"description"];
            NSLog(@"%@,%@",State,Description);
            
            //判断修改绑定状态（如果OK返回系统设置界面，否则弹出错误信息）
            if ([State isEqualToString:@"OK"])
            {
                //把patientInfo更新到本地数据库
                dbOpration=[[DataBaseOpration alloc] init];
                [dbOpration updataUserInfo:_patientInfo];
                [dbOpration closeDataBase];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    alert = [[UIAlertView alloc] initWithTitle:nil message:@"修改成功" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                    [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                    [alert show];
                });
                
            }
            else if ([State isEqualToString:@"NO"])
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:Description delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
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

//alertview自动消失
- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}

/*对输入的字符进行限制的代理方法*/
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.tag==5)
    {
        NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
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
    else if (textField.tag==6)
    {
        NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:ALPHANUM_EMAIL] invertedSet];
        NSString *filtered=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        return [string isEqualToString:filtered];
    }
    else
    {
        return YES;
    }
}

//选择性别并跟新保存，提示保存成功
-(void)chooseSex
{
    view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    view.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view.window addSubview:view];
    
    childView=[[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, SCREEN_HEIGHT*3/8, SCREEN_WIDTH*4/5, 150)];
    childView.backgroundColor=[UIColor whiteColor];
    sexLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*7/20, 0, SCREEN_WIDTH*2/5, 50)];
    lineBlue=[[UIView alloc] initWithFrame:CGRectMake(0, 49, SCREEN_WIDTH*4/5, 2)];
    lineBlue.backgroundColor=[UIColor blueColor];
    //sexLabel.backgroundColor=[UIColor blueColor];
    sexLabel.textColor=[UIColor blueColor];
    sexLabel.font=[UIFont systemFontOfSize:18];
    sexLabel.text=@"性别";
    sexTableView=[[UITableView alloc] initWithFrame:CGRectMake(0, 51, SCREEN_WIDTH*4/5, 100)];
    sexTableView.tag=2;
    sexTableView.backgroundColor=[UIColor whiteColor];
    sexTableView.tableFooterView=[[UIView alloc] init];
    sexTableView.scrollEnabled=NO;
    sexTableView.delegate=self;
    sexTableView.dataSource=self;
    
    [childView addSubview:sexLabel];
    [childView addSubview:lineBlue];
    [childView addSubview:sexTableView];
    [view.window addSubview:childView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestureRemove:)];
    [view addGestureRecognizer:tapGesture];
    
}

//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGestureRemove:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<dateView.frame.origin.x || point.x >dateView.frame.origin.x+dateView.frame.size.width || point.y<dateView.frame.origin.y || point.y>dateView.frame.origin.y+dateView.frame.size.height)
    {
        [sexTableView removeFromSuperview];
        [sexLabel removeFromSuperview];
        [lineBlue removeFromSuperview];
        [childView removeFromSuperview];
        [view removeFromSuperview];
    }
}

//选择生日并跟新保存，提示保存成功
-(void)chooseBirthday
{
    //添加UIPickerView
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
    [PickerView selectRow:yearIndex inComponent:0 animated:YES];
    [PickerView selectRow:monthIndex inComponent:1 animated:YES];
    [PickerView reloadAllComponents];
    [PickerView addSubview:yearLabel];
    [PickerView addSubview:monthLabel];
    
    UIButton *determineButton=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*8/25, 162, SCREEN_WIDTH*4/25, SCREEN_HEIGHT/20)];
    [determineButton setTitle:@"确定" forState:UIControlStateNormal];
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
    NSString *yearString=[NSString stringWithFormat:@"%@",[_dateYearArray objectAtIndex:yearIndex]];
    NSString *monthString=[NSString stringWithFormat:@"%@",[_dateMonthArray objectAtIndex:monthIndex]];
    NSString *birthday=[NSString stringWithFormat:@"%@年%@月",yearString,monthString];
    _patientInfo.Birthday=birthday;
    [birthButton setTitle:birthday forState:UIControlStateNormal];
    [self alterSelfInfo];
    //计算用户的Age
    _patientInfo.Age=year-[yearString integerValue]+1;
    
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
