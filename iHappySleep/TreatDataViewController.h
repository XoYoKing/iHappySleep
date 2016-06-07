//
//  TreatDataViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/11/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientInfo.h"
#import "TreatInfo.h"

@interface TreatDataViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,UIPickerViewDelegate,UIPickerViewDataSource>

@property PatientInfo *patientInfo;
@property TreatInfo *treatInfo;

//用来存开始日期年月的数组
@property NSMutableArray *begainDateYearArray;
@property NSMutableArray *begainDateMonthArray;
@property NSMutableArray *begainDateDayArray;
//用来存结束日期年月的数组
@property NSMutableArray *endDateYearArray;
@property NSMutableArray *endDateMonthArray;
@property NSMutableArray *endDateDayArray;
//服务器请求数据
@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end
