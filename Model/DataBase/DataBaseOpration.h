//
//  DataBaseOpration.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "PatientInfo.h"
#import "TreatInfo.h"
#import "EvaluateInfo.h"
#import "BluetoothInfo.h"

@interface DataBaseOpration : NSObject

@property sqlite3 *mySqlite;
@property NSMutableArray *dataArray;//存储从数据库中取出的数据

-(id)init;
//用户信息的插入以及更新
-(void)insertUserInfo:(PatientInfo *)patientInfo;
-(void)updataUserInfo:(PatientInfo *)patientInfo;
//治疗数据的插入以及更新
-(void)insertTreatInfo:(TreatInfo *)treatInfo;
-(void)updateTreatInfo:(TreatInfo *)treatInfo;
//评估数据的插入以及更新
-(void)insertEvaluateInfo:(EvaluateInfo *)evaluateInfo;
-(void)updateEvaluateInfo:(EvaluateInfo *)evaluateInfo;
-(void)deleteEvaluateInfo;
//蓝牙外设的插入、更新以及删除
-(void)insertPeripheralInfo:(BluetoothInfo *)bluetoothInfo;
-(void)updatePeripheralInfo:(BluetoothInfo *)bluetoothInfo;
-(void)deletePeripheralInfo;

//取得用户信息表中的全部数据
-(NSMutableArray *)getPatientDataFromDataBase;
//取得治疗数据表中的全部数据
-(NSMutableArray *)getTreatDataFromDataBase;
//取得评估数据表中的全部数据
-(NSMutableArray *)getEvaluateDataFromDataBase;
//取得蓝牙外设表中的全部数据
-(NSMutableArray *)getBluetoothDataFromDataBase;

-(void)closeDataBase;

@end
