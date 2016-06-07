//
//  LoginViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/9/28.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "FindPasswordViewController.h"
#import "myHeader.h"
#import "PatientInfo.h"
#import "ViewController.h"
#import <SystemConfiguration/SystemConfiguration.h>
#import <netdb.h>
#import "Reachability.h"
#import "MyIndicatorView.h"

@interface LoginViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@end

@implementation LoginViewController
{
    UITextField *userName;
    UITextField *passWord;
    
    UIView *view;
    UIAlertView *alert;
    
    DataBaseOpration *dbOpration;
    PatientInfo *patientInfo;
    
    NSArray *treatInfoArray;
    NSArray *evaluateInfoArray;
    
    BOOL isOverTime;
}

@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"title_bg"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    UIButton *btn_Logo=[UIButton buttonWithType:UIButtonTypeSystem];
    btn_Logo.frame=CGRectMake(0, 0, SCREEN_WIDTH/4, 44);
    [btn_Logo setTitle:@"疗疗失眠" forState:UIControlStateNormal];
    btn_Logo.titleLabel.font=[UIFont systemFontOfSize:18];
    btn_Logo.userInteractionEnabled=NO;
    [btn_Logo setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem *menu_LogoItem=[[UIBarButtonItem alloc] initWithCustomView:btn_Logo];
    [self.navigationItem setLeftBarButtonItem:menu_LogoItem];
    
    [_LoginButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    [_RegisterButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    
    isOverTime=YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    [_LoginTableView.layer setCornerRadius:10.0];
    _LoginTableView.backgroundColor=[UIColor colorWithWhite:0.95 alpha:0.9];
    _LoginTableView.scrollEnabled=NO;
    
    _LoginTableView.separatorColor=[UIColor colorWithWhite:0.7 alpha:0.9];
    
    if ([_LoginTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_LoginTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_LoginTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_LoginTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    _LoginTableView.delegate=self;
    _LoginTableView.dataSource=self;
    
    _LoginButton.titleLabel.font=[UIFont systemFontOfSize:20];
    _RegisterButton.titleLabel.font=[UIFont systemFontOfSize:20];
    
    dbOpration=[[DataBaseOpration alloc] init];
    treatInfoArray=[dbOpration getTreatDataFromDataBase];
    evaluateInfoArray=[dbOpration getEvaluateDataFromDataBase];
    [dbOpration closeDataBase];
    
    //注册切换用户通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUser) name:@"ChangeUser" object:nil];
}

//切换用户，释放蓝牙绑定信息
-(void)changeUser
{
    self.bluetoothInfo=nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[[UITableViewCell alloc] init];
    
    if (indexPath.row==0)
    {
        cell=[[UITableViewCell alloc] init];
        
        UIImageView *userImage=[[UIImageView alloc] init];
        userImage.frame=CGRectMake((SCREEN_WIDTH-40)/20, 20, (SCREEN_WIDTH-40)/16, 20);
        if (SCREEN_WIDTH==320)
        {
            userImage.frame=CGRectMake((SCREEN_WIDTH-40)/20, 20, (SCREEN_WIDTH-40)/14, 20);
        }
        userImage.image=[UIImage imageNamed:@"login_head"];
        
        userName=[[UITextField alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH-40)*9/80, 0, (SCREEN_WIDTH-40)*2/3, 60)];
        userName.tag=1;
        userName.font=[UIFont systemFontOfSize:20];
        userName.placeholder=@"账号";
        userName.keyboardType=UIKeyboardTypeNumberPad;
        userName.delegate=self;
        
        [cell.contentView addSubview:userImage];
        [cell.contentView addSubview:userName];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        return cell;
    }
    else if (indexPath.row==1)
    {
        cell=[[UITableViewCell alloc] init];
        
        UIImageView *pwdImage=[[UIImageView alloc] init];
        pwdImage.frame=CGRectMake((self.view.frame.size.width-40)/20, 20, (self.view.frame.size.width-40)/18, 20);
        if (SCREEN_WIDTH==320)
        {
            pwdImage.frame=CGRectMake((self.view.frame.size.width-40)/20, 20, (self.view.frame.size.width-40)/16, 20);
        }
        pwdImage.image=[UIImage imageNamed:@"login_password"];
        
        passWord=[[UITextField alloc] initWithFrame:CGRectMake(20+(SCREEN_WIDTH-40)*9/80, 0, (SCREEN_WIDTH-40)*2/3, 60)];
        passWord.secureTextEntry=YES;
        passWord.font=[UIFont systemFontOfSize:20];
        passWord.placeholder=@"密码";
        passWord.delegate=self;
        passWord.tag=2;
        
        [cell.contentView addSubview:pwdImage];
        [cell.contentView addSubview:passWord];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        return cell;
    }
    else
    {
        [cell setBackgroundColor:[UIColor clearColor]];
        return cell;
    }
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

//登陆
- (IBAction)userLogin:(id)sender
{
    //判断是否有网络
    NSString *result;
    if ([self connectedToNetWork])
    {
        if(userName.text.length==0)
        {
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"账号不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
        else if(passWord.text.length==0)
        {
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
        else
        {
            NSString *userId=userName.text;
            NSString *pwd=passWord.text;
            NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"UserID",pwd,@"Upwd",nil];
            NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
            NSLog(@"JsonString>>>>%@",jsonString);
            
            // 设置我们之后解析XML时用的关键字
            matchingElement = @"APP_LoginResponse";
            // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
            NSString *soapMsg = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap12:Envelope "
                                 "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                 "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                 "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap12:Body>"
                                 "<APP_Login xmlns=\"MeetingOnline\">"
                                 "<JsonLoginInfo>%@</JsonLoginInfo>"
                                 "</APP_Login>"
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
    else
    {
        result = @"网络连接不可用!";
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"账号首次登录，需要连接网络" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        
        [alert show];
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

//注册
- (IBAction)RegisterButtonClick:(UIButton *)sender
{
    if ([self connectedToNetWork])
    {
        RegisterViewController *registerController=[[RegisterViewController alloc] initWithNibName:@"RegisterViewController" bundle:nil];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"用户注册";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:registerController animated:YES];
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络连接不可用，请稍后再试" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        
        [alert show];
    }
}

-(BOOL)connectedToNetWork
{
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus])
    {
        case NotReachable:
            isExistenceNetwork = NO;
            NSLog(@"notReachable");
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            NSLog(@"WIFI");
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            NSLog(@"3G");
            break;
    }
    return isExistenceNetwork;
}

//忘记密码
- (IBAction)ForgetPasswordClick:(UIButton *)sender
{
    if ([self connectedToNetWork])
    {
        if (userName.text.length==0)
        {
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"账号不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
        else
        {
            //判断不为空时，输入的账号是否存在
            //验证账号是否存在
            NSString *userId=userName.text;
            NSString *pwd=passWord.text;
            NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"UserID",pwd,@"Upwd",nil];
            //NSDictionary *jsonPassword = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"UserID",pwd,@"Upwd",nil];
            NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
            NSLog(@"JsonString>>>>%@",jsonString);
            
            // 设置我们之后解析XML时用的关键字
            matchingElement = @"soap:Envelope";
            // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
            NSString *soapMsg = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap12:Envelope "
                                 "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                 "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                 "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap12:Body>"
                                 "<APP_Login xmlns=\"MeetingOnline\">"
                                 "<JsonLoginInfo>%@</JsonLoginInfo>"
                                 "</APP_Login>"
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
            
            _ForgetPassword.userInteractionEnabled=NO;
        }
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"网络异常，请稍后再试" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        
        [alert show];
    }
}

////直接体验
//- (IBAction)tryDirectly:(id)sender
//{
//    ViewController *next = [[ViewController alloc] init];
//    //1.将读取的蓝牙外设信息传递给 直接体验 之后的主界面
//    next.bluetoothInfo=self.bluetoothInfo;
//    //2.跳转到直接体验主界面
//    [self.navigationController pushViewController:next animated:YES];
//}

- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
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
        if ([matchingElement isEqualToString:@"APP_LoginResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *state=[resultDic objectForKey:@"state"];
            NSString *description=[resultDic objectForKey:@"description"];
            if(userName.text.length==0)
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"账号不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
            }
            else if(passWord.text.length==0)
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
            }
            else if(userName.text.length>0 && passWord.text>0 && [state isEqualToString:@"OK"])
            {
                //添加Loading
                view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
                view.backgroundColor=[UIColor colorWithWhite:0.2 alpha:0.7];
                [self.view addSubview:view];
                [MyIndicatorView show:@"Loading..."];
                [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(overTime) userInfo:nil repeats:NO];
                
                //记住密码
                NSUserDefaults *userDefault=[NSUserDefaults standardUserDefaults];
                [userDefault setValue:userName.text forKey:@"PatientID"];
                [userDefault setValue:passWord.text forKey:@"PatientPwd"];
                
                //网络请求用户个人信息
                NSString *userId=userName.text;
                NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:userId,@"PatientID",nil];
                NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
                NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
                NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
                NSLog(@"JsonString>>>>%@",jsonString);
                
                // 设置我们之后解析XML时用的关键字
                matchingElement = @"APP_GetPatientInfoResponse";
                // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
                NSString *soapMsg = [NSString stringWithFormat:
                                     @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                     "<soap12:Envelope "
                                     "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                     "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                     "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                     "<soap12:Body>"
                                     "<APP_GetPatientInfo xmlns=\"MeetingOnline\">"
                                     "<JsonPatientID>%@</JsonPatientID>"
                                     "</APP_GetPatientInfo>"
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
                alert = [[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"%@",description] delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                
                [alert show];
            }
        }
        else if ([matchingElement isEqualToString:@"soap:Envelope"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *state=[resultDic objectForKey:@"state"];
            NSString *description=[resultDic objectForKey:@"description"];
            if ([description isEqualToString:@"账号不存在！"])
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"账号不存在，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
                _ForgetPassword.userInteractionEnabled=YES;
            }
            else if ([state isEqualToString:@"NO"] && [description isEqualToString:@"密码错误！"])
            {
                FindPasswordViewController *findPasswordController=[[FindPasswordViewController alloc] initWithNibName:@"FindPasswordViewController" bundle:nil];
                findPasswordController.PatientID=userName.text;
                UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
                temporaryBarButtonItem.title = @"密码找回";
                self.navigationItem.backBarButtonItem= temporaryBarButtonItem;
                [self.navigationController pushViewController:findPasswordController animated:YES];
                
                _ForgetPassword.userInteractionEnabled=YES;
            }
            
        }
        else if ([matchingElement isEqualToString:@"APP_GetPatientInfoResponse"])
        {
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultDic=[resultArray objectAtIndex:0];
            
            patientInfo=[[PatientInfo alloc] init];
            patientInfo.PatientID=userName.text;
            patientInfo.PatientPwd=passWord.text;
            patientInfo.PatientName=[resultDic objectForKey:@"PatientName"];
            patientInfo.PatientSex=[resultDic objectForKey:@"PatientSex"];
            patientInfo.Birthday=[resultDic objectForKey:@"Birthday"];
            patientInfo.Age=[[resultDic objectForKey:@"Age"] integerValue];
            patientInfo.Marriage=[resultDic objectForKey:@"Marriage"];
            patientInfo.NativePlace=[resultDic objectForKey:@"NativePlace"];
            patientInfo.BloodModel=[resultDic objectForKey:@"BloodModel"];
            patientInfo.CellPhone=[resultDic objectForKey:@"CellPhone"];
            patientInfo.FamilyPhone=[resultDic objectForKey:@"FamilyPhone"];
            patientInfo.Email=[resultDic objectForKey:@"Email"];
            patientInfo.Vocation=[resultDic objectForKey:@"Vocation"];
            patientInfo.Address=[resultDic objectForKey:@"Address"];
            patientInfo.Picture=[resultDic objectForKey:@"PhotoUrl"];
            patientInfo.PatientHeight=[resultDic objectForKey:@"PatientHeight"];
            patientInfo.PatientWeight=[resultDic objectForKey:@"PatientWeight"];
            patientInfo.PatientContactWay=@"";
            patientInfo.PatientRemarks=@"";
            
            //循环将治疗数据以及评估数据上传至服务器
            if (treatInfoArray.count!=0)
            {
                TreatInfo *treatInfo=[[TreatInfo alloc] init];
                for (int i=1; i<=treatInfoArray.count; i++)
                {
                    treatInfo=[treatInfoArray objectAtIndex:i-1];
                    //循环调用插入治疗数据接口
                    NSString *Freq;
                    if ([treatInfo.Frequency isEqualToString:@"1"])
                    {
                        Freq=@"0.5";
                    }
                    else if ([treatInfo.Frequency isEqualToString:@"2"])
                    {
                        Freq=@"1.5";
                    }
                    else if ([treatInfo.Frequency isEqualToString:@"3"])
                    {
                        Freq=@"100";
                    }
                    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:treatInfo.PatientID,@"PatientID",treatInfo.Strength,@"Strength",Freq,@"Freq",treatInfo.BeginTime ,@"BeginTime",treatInfo.EndTime,@"EndTime",treatInfo.CureTime,@"CureTime",nil];
                    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
                    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
                    NSLog(@"JsonString>>>>%@",jsonString);
                    
                    // 设置我们之后解析XML时用的关键字
                    matchingElement = @"APP_InsertCureDataResponse";
                    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
                    NSString *soapMsg = [NSString stringWithFormat:
                                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                         "<soap12:Envelope "
                                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                         "<soap12:Body>"
                                         "<APP_InsertCureData xmlns=\"MeetingOnline\">"
                                         "<JsonCureData>%@</JsonCureData>"
                                         "</APP_InsertCureData>"
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
            if (evaluateInfoArray.count!=0)
            {
                EvaluateInfo *evaluateInfo=[[EvaluateInfo alloc] init];
                for (int i=1; i<=evaluateInfoArray.count; i++)
                {
                    evaluateInfo=[evaluateInfoArray objectAtIndex:i-1];
                    //循环调用插入评估数据接口
                    NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:evaluateInfo.PatientID,@"PatientID",evaluateInfo.Time,@"SaveTime",evaluateInfo.Quality,@"Quality",evaluateInfo.Date,@"Date",evaluateInfo.Score,@"Score",evaluateInfo.ListFlag,@"Type",nil];
                    NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
                    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
                    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
                    NSLog(@"JsonString>>>>%@",jsonString);
                    
                    // 设置我们之后解析XML时用的关键字
                    matchingElement = @"APP_InsertAndUpdateEvaluateDataResponse";
                    // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
                    NSString *soapMsg = [NSString stringWithFormat:
                                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                         "<soap12:Envelope "
                                         "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                         "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                         "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                         "<soap12:Body>"
                                         "<APP_InsertAndUpdateEvaluateData xmlns=\"MeetingOnline\">"
                                         "<JsonEvaluateData>%@</JsonEvaluateData>"
                                         "</APP_InsertAndUpdateEvaluateData>"
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
            
            //隐藏Loading
            [MyIndicatorView dismiss];
            [view removeFromSuperview];
            isOverTime=NO;
            //页面跳转(并传值)
            ViewController *Main=[[ViewController alloc] init];
            
            //判断数据库是否存在这个patientInfo，存在则更新数据库，不存在插入数据库
            dbOpration=[[DataBaseOpration alloc] init];
            PatientInfo *temp=[[PatientInfo alloc] init];
            if (_PatientInfoArray.count==0)
            {
                [dbOpration insertUserInfo:patientInfo];
            }
            else
            {
                for (PatientInfo *tmp in _PatientInfoArray)
                {
                    if ([tmp.PatientID isEqualToString:patientInfo.PatientID])
                    {
                        //更新数据库中的信息
                        temp=tmp;
                        [dbOpration updataUserInfo:patientInfo];
                    }
                }
                if (temp.PatientID==nil)
                {
                    [dbOpration insertUserInfo:patientInfo];
                }
            }
            Main.patientInfo=patientInfo;
            Main.bluetoothInfo=_bluetoothInfo;
            [dbOpration closeDataBase];
            [self.navigationController pushViewController:Main animated:YES];
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

/*点击编辑区域外的view收起键盘*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [userName resignFirstResponder];
    [passWord resignFirstResponder];
}

/*对输入的字符进行限制的代理方法*/
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
    NSString *filtered=[[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    NSString *toBeString=[textField.text stringByReplacingCharactersInRange:range withString:string];
    if (toBeString.length>18 && range.length!=1)
    {
        textField.text=[toBeString substringToIndex:11];
        alert=[[UIAlertView alloc] initWithTitle:nil message:@"输入过长！" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    
    return [string isEqualToString:filtered];
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
