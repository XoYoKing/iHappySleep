//
//  RegisterViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/2.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyButton.h"

@interface RegisterViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *registerTableView;
@property (strong, nonatomic) IBOutlet UIButton *registerAndLoginButton;

@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

//用来存日期年月的数组
@property NSMutableArray *dateYearArray;
@property NSMutableArray *dateMonthArray;

@end
