//
//  LoginViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/9/28.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBaseOpration.h"
#import "PatientInfo.h"
#import "BluetoothInfo.h"

@interface LoginViewController : UIViewController<NSXMLParserDelegate,NSURLConnectionDelegate>

@property (strong, nonatomic) IBOutlet UITableView *LoginTableView;
@property (strong, nonatomic) IBOutlet UIButton *LoginButton;
@property (strong, nonatomic) IBOutlet UIButton *RegisterButton;
@property (strong, nonatomic) IBOutlet UIButton *ForgetPassword;
//@property (strong, nonatomic) IBOutlet UILabel *LoginLabel;
//@property (strong, nonatomic) IBOutlet UIButton *TryDirectly;

@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@property BluetoothInfo *bluetoothInfo;

@property NSArray *PatientInfoArray;

@end
