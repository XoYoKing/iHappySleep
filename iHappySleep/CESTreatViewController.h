//
//  CESTreatViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/9/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BLEInfo.h"
#import "BindViewController.h"
#import "PatientInfo.h"
#import "TreatInfo.h"
#import "BluetoothInfo.h"

@protocol sendElectricQuality <NSObject>

-(void)sendElectricQualityValue:(NSString *)string;
-(void)alertBackTitle:(NSString *)string;

@end

@interface CESTreatViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>

@property BLEInfo *BLEinfo;
@property (nonatomic,strong) CBCentralManager *centralMgr;
@property (nonatomic, strong) CBPeripheral *discoveredPeripheral;
// tableview sections，保存蓝牙设备里面的services字典，字典第一个为service，剩下是特性与值
@property (nonatomic, strong) NSMutableArray *arrayServices;
// 用来记录有多少特性，当全部特性保存完毕，刷新列表
@property (atomic, assign) int characteristicNum;

//设置程序进入后台的时间
@property (nonatomic, strong) NSTimer *_updateTimer;

@property PatientInfo *patientInfo;
@property TreatInfo *treatInfo;
@property BluetoothInfo *bluetoothInfo;

@property NSArray *BluetoothInfoArray;

@property (nonatomic) NSTimeInterval elapsedTime;
@property (nonatomic) NSTimeInterval timeLimit;

@property id<sendElectricQuality>delegate;

@property (strong,nonatomic) NSMutableData *webData;
@property (strong,nonatomic) NSMutableString *soapResults;
@property (strong,nonatomic) NSXMLParser *xmlParser;
@property (nonatomic) BOOL elementFound;
@property (strong,nonatomic) NSString *matchingElement;
@property (strong,nonatomic) NSURLConnection *conn;

@end
