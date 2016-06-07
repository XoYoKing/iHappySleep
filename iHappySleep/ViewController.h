//
//  ViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/9/24.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PatientInfo.h"
#import "TreatInfo.h"
#import "BluetoothInfo.h"
#import "DataBaseOpration.h"

@interface ViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate,NSURLConnectionDelegate>

@property PatientInfo *patientInfo;
@property BluetoothInfo *bluetoothInfo;

@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end

