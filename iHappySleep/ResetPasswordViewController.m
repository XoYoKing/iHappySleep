//
//  ResetPasswordViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/14.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "ResetPasswordViewController.h"
#import "myHeader.h"
#import "PatientInfo.h"
#import "DataBaseOpration.h"

@interface ResetPasswordViewController ()<NSXMLParserDelegate,NSURLConnectionDelegate,UITextFieldDelegate>

@end

@implementation ResetPasswordViewController
{
    UIAlertView *alert;
    
    UITextField *newPasswordTextField;
    UITextField *repeatTextField;
    
    DataBaseOpration *dataBaseOpration;
}
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    _resetPasswordTableView.backgroundColor=[UIColor colorWithWhite:0.95 alpha:0.9];
    _resetPasswordTableView.scrollEnabled=NO;
    
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    _resetPasswordTableView.separatorColor=[UIColor colorWithWhite:0.7 alpha:0.9];
    
    if ([_resetPasswordTableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_resetPasswordTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_resetPasswordTableView respondsToSelector:@selector(setLayoutMargins:)])
    {
        [_resetPasswordTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    _resetPasswordTableView.dataSource=self;
    _resetPasswordTableView.delegate=self;
    
    [_submitButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    _submitButton.titleLabel.font=[UIFont systemFontOfSize:20];
}

- (IBAction)submitButtonClick:(UIButton *)sender
{
    if (newPasswordTextField.text.length>5)
    {
        if ([newPasswordTextField.text isEqualToString:repeatTextField.text])
        {
            NSString *PatientID=_patientInfo.PatientID;
            NSString *PatientPwd=repeatTextField.text;
            NSDictionary *jsonPhoneNum = [NSDictionary dictionaryWithObjectsAndKeys:PatientID,@"PatientID",PatientPwd,@"PatientNewPwd",nil];
            NSArray *jsonArray=[NSArray arrayWithObjects:jsonPhoneNum, nil];
            NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
            NSLog(@"JsonString>>>>%@",jsonString);
            
            // 设置我们之后解析XML时用的关键字
            matchingElement = @"APP_PatientUpdatePwdResponse";
            // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
            NSString *soapMsg = [NSString stringWithFormat:
                                 @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                                 "<soap12:Envelope "
                                 "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                                 "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                                 "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                                 "<soap12:Body>"
                                 "<APP_PatientUpdatePwd xmlns=\"MeetingOnline\">"
                                 "<JsonUpdatePwd>%@</JsonUpdatePwd>"
                                 "</APP_PatientUpdatePwd>"
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
            //提示输入不一致
            alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码输入不一致，请检查后重新输入" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
            [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
            [alert show];
        }
    }
    else
    {
        //提示输入密码过短
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"密码长度过短，请重新设置" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
        [alert show];
    }
}

//alertview自动消失
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
        
        newPasswordTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, 0, SCREEN_WIDTH*16/20, 50)];
        newPasswordTextField.font=[UIFont systemFontOfSize:20];
        newPasswordTextField.placeholder=@"输入6-18位新密码";
        //newPasswordTextField.keyboardType=UIKeyboardTypeASCIICapable;
        newPasswordTextField.secureTextEntry=YES;
        newPasswordTextField.delegate=self;
        
        [cell.contentView addSubview:newPasswordTextField];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if (indexPath.row==1)
    {
        UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        
        repeatTextField=[[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, 0, SCREEN_WIDTH*16/20, 50)];
        repeatTextField.font=[UIFont systemFontOfSize:20];
        repeatTextField.placeholder=@"请再次输入新密码";
        repeatTextField.secureTextEntry=YES;
        //repeatTextField.keyboardType=UIKeyboardTypeASCIICapable;
        repeatTextField.delegate=self;
        
        [cell.contentView addSubview:repeatTextField];
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
        if ([matchingElement isEqualToString:@"APP_PatientUpdatePwdResponse"])
        {
            //对soapResults返回的json字符串进行解析
            NSData *jsonResult=[soapResults dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *resultDic=[NSJSONSerialization JSONObjectWithData:jsonResult options:NSJSONReadingMutableContainers error:nil];
            NSString *state=[resultDic objectForKey:@"state"];
            //NSString *description=[resultDic objectForKey:@"description"];
            if ([state isEqualToString:@"OK"])
            {
                _patientInfo.PatientPwd=repeatTextField.text;
                dataBaseOpration=[[DataBaseOpration alloc] init];
                [dataBaseOpration updataUserInfo:_patientInfo];
                [dataBaseOpration closeDataBase];
                //提示输入密码过短
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"修改成功" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismiss:) userInfo:nil repeats:NO];
                [alert show];
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            else
            {
                //没有更新到服务器，查看网络连接是否正常
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

/*点击编辑区域外的view收起键盘*/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [newPasswordTextField resignFirstResponder];
    [repeatTextField resignFirstResponder];
}
/*对输入的字符进行限制的代理方法*/
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
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
