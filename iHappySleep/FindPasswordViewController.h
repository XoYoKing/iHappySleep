//
//  FindPasswordViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/14.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientInfo.h"

@interface FindPasswordViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property NSString *PatientID;

@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@property (strong, nonatomic) IBOutlet UITableView *findPasswordTableView;
@property (strong, nonatomic) IBOutlet UIButton *nextButton;

@end
