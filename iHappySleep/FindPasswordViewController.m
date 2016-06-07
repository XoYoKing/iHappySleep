//
//  FindPasswordViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/14.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "FindPasswordViewController.h"
#import "myHeader.h"
#import "PatientInfo.h"
#import "DataBaseOpration.h"
#import "ResetPasswordViewController.h"

@interface FindPasswordViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate,UITextFieldDelegate>

@end

@implementation FindPasswordViewController
{
    UIAlertView *alert;
    
    UITextField *phoneNumTextField;
    UITextField *verifyNumTextField;
    
    NSString *code;
    
    PatientInfo *patientInfo;
    
    DataBaseOpration *dataBaseOpration;
    NSMutableArray *patientArray;                //存储从数据库中取出的用户信息
    
    UIButton *verifyButton;
    
    NSTimer *m_timer; //设置验证按钮计时器
    int secondsCountDown;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    _findPasswordTableView.backgroundColor=[UIColor colorWithWhite:0.95 alpha:0.9];
    _findPasswordTableView.scrollEnabled=NO;
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    _findPasswordTableView.separatorColor=[UIColor colorWithWhite:0.7 alpha:0.9];
    
    if ([_findPasswordTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_findPasswordTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_findPasswordTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_findPasswordTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    _findPasswordTableView.dataSource=self;
    _findPasswordTableView.delegate=self;
    
    [_nextButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    [_nextButton setTitle:@"下一步" forState:UIControlStateNormal];
    
    patientInfo=[PatientInfo new];
    
    dataBaseOpration=[[DataBaseOpration alloc] init];
    patientArray=[NSMutableArray array];
    patientArray=[dataBaseOpration getPatientDataFromDataBase];
    for (PatientInfo *tmp in patientArray)
    {
        if ([tmp.CellPhone isEqualToString:self.PatientID])
        {
            patientInfo=tmp;
        }
    }
    [dataBaseOpration closeDataBase];
    
    if (patientInfo.PatientID==nil)
    {
        [self getPatientInfo];
    }
}

-(void)getPatientInfo
{
    NSDictionary *jsonPatientID = [NSDictionary dictionaryWithObjectsAndKeys:_PatientID,@"PatientID",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonPatientID, nil];
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

//下一步 按钮点击事件
- (IBAction)nextButtonClick:(UIButton *)sender
{
    if ([verifyNumTextField.text isEqualToString:code])
    {
        //页面跳转到重置密码界面
        ResetPasswordViewController *resetPasswordController=[[ResetPasswordViewController alloc] initWithNibName:@"ResetPasswordViewController" bundle:nil];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"密码重置";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        resetPasswordController.patientInfo=patientInfo;
        [self.navigationController pushViewController:resetPasswordController animated:YES];
    }
    else if(verifyNumTextField.text.length==0 || verifyNumTextField.text==nil)
    {
        //提示验证码不能为空
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"验证码不能为空，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        [alert show];
    }
    else if (verifyNumTextField.text.length!=0 && ![verifyNumTextField.text isEqualToString:code])
    {
        //提示验证码输入不正确
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"验证码输入不正确，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        [alert show];
    }
}

-(void)backClick
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void) performDismiss: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}

//tableview的代理方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identity=@"FindPassword";
    if (indexPath.row==0)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        phoneNumTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, 0, SCREEN_WIDTH*11/20, 50)];
        phoneNumTextField.font=[UIFont systemFontOfSize:20];
        if (patientInfo.PatientID==nil)
        {
            phoneNumTextField.text=self.PatientID;
        }
        else
        {
            phoneNumTextField.text=patientInfo.CellPhone;
        }
        phoneNumTextField.userInteractionEnabled=NO;
        
        //verifyButton=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, 0, SCREEN_WIDTH/4, 50)];
        verifyButton=[UIButton buttonWithType:UIButtonTypeSystem];
        verifyButton.frame=CGRectMake(SCREEN_WIDTH*3/4, 0, SCREEN_WIDTH/4, 50);
        verifyButton.titleLabel.font=[UIFont systemFontOfSize:20];
        [verifyButton setTitle:@"验证" forState:UIControlStateNormal];
        //[verifyButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [verifyButton addTarget:self action:@selector(verifyButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4, 0.0f, 0.5f, 50.0f)];
        [lineView setBackgroundColor:[UIColor lightGrayColor]];
        
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
        
        verifyNumTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, 0, SCREEN_WIDTH*11/20, 50)];
        verifyNumTextField.font=[UIFont systemFontOfSize:20];
        verifyNumTextField.placeholder=@"短信验证码";
        verifyNumTextField.keyboardType=UIKeyboardTypeNumberPad;
        verifyNumTextField.delegate=self;
        
        [cell.contentView addSubview:verifyNumTextField];
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

//验证按钮的点击事件
-(void)verifyButton:(UIButton *)sender
{
    NSString *phoneNum=phoneNumTextField.text;
    NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:phoneNum,@"CellPhone",nil];
    NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
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
    //做90秒倒计时
    m_timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calcuRemainTime) userInfo:nil repeats:YES];
    secondsCountDown=90;
    verifyButton.userInteractionEnabled=NO;
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
        else if ([matchingElement isEqualToString:@"APP_GetPatientInfoResponse"])
        {
            //对soapResults返回的json字符串进行解析
            patientInfo=[[PatientInfo alloc] init];
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSArray *resultArray=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSDictionary *resultDic=[resultArray objectAtIndex:0];
            
            patientInfo.PatientID=_PatientID;
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
    [verifyNumTextField resignFirstResponder];
}
/*对输入的字符进行限制的代理方法*/
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSCharacterSet *cs=[[NSCharacterSet characterSetWithCharactersInString:ALPHANUM] invertedSet];
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
