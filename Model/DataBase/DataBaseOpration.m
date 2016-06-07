//
//  DataBaseOpration.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "DataBaseOpration.h"

@implementation DataBaseOpration
{
    NSArray *arr;
}

@synthesize mySqlite;

-(id)init
{
    if (self)
    {
        self=[super init];
    }
    [self dataBase_initail];
    return self;
}

//数据库初始化（打开数据库）
-(void)dataBase_initail
{
    NSString *dataBasePath=[self getDataBasePath];
    if (sqlite3_open([dataBasePath UTF8String], &(mySqlite))==SQLITE_OK)
    {
        NSLog(@"打开数据库成功！");
    }
    else
    {
        [self closeDataBase];
        NSLog(@"打开数据库失败！");
    }
}

//关闭数据库
-(void)closeDataBase
{
    sqlite3_close(mySqlite);
    NSLog(@"关闭数据库成功！");
}

//获得数据库沙盒路径
-(NSString *)getDataBasePath
{
    NSString *path=[[NSBundle mainBundle] pathForResource:@"iHappySleep" ofType:@"db"];
    
    NSString *sandBoxPath=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    //NSLog(@"%@",sandBoxPath);
    NSString *dataBaseFileName=[sandBoxPath stringByAppendingString:@"/iHappySleep.db"];
    
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:dataBaseFileName]!=YES)
    {
        [fileManager copyItemAtPath:path toPath:dataBaseFileName error:nil];
    }
    
    return dataBaseFileName;
}

//从数据库中读取用户信息表的数据
-(NSMutableArray *)getPatientDataFromDataBase
{
    _dataArray=[NSMutableArray array];
    char zSql[]="select * from tbl_Patient";/*设置查询语句的C语言数组*/
    sqlite3_stmt *statement;
    if (sqlite3_prepare(mySqlite, zSql, -1, &statement, nil)==SQLITE_OK)
    {
        while (sqlite3_step(statement)==SQLITE_ROW)
        {
            PatientInfo *patientInfo=[PatientInfo new];
            
            char *tmp_PatientID=(char *)sqlite3_column_text(statement, 1);
            char *tmp_PatientPwd=(char *)sqlite3_column_text(statement, 2);
            char *tmp_PatientName=(char *)sqlite3_column_text(statement, 3);
            char *tmp_PatientSex=(char *)sqlite3_column_text(statement, 4);
            char *tmp_CellPhone=(char *)sqlite3_column_text(statement, 5);
            char *tmp_Birthday=(char *)sqlite3_column_text(statement, 6);
            int   tmp_Age=sqlite3_column_int(statement, 7);
            char *tmp_Marriage=(char *)sqlite3_column_text(statement, 8);
            char *tmp_NativePlace=(char *)sqlite3_column_text(statement, 9);
            char *tmp_BloodModel=(char *)sqlite3_column_text(statement, 10);
            char *tmp_PatientContactWay=(char *)sqlite3_column_text(statement, 11);
            char *tmp_FamilyPhone=(char *)sqlite3_column_text(statement, 12);
            char *tmp_Email=(char *)sqlite3_column_text(statement, 13);
            char *tmp_Vocation=(char *)sqlite3_column_text(statement, 14);
            char *tmp_Address=(char *)sqlite3_column_text(statement, 15);
            char *tmp_PatientHeight=(char *)sqlite3_column_text(statement, 16);
            char *tmp_PatientWeight=(char *)sqlite3_column_text(statement, 17);
            char *tmp_PatientRemarks=(char *)sqlite3_column_text(statement, 18);
            char *tmp_Picture=(char *)sqlite3_column_text(statement, 19);
            
            patientInfo.PatientID=[NSMutableString stringWithUTF8String:tmp_PatientID];
            patientInfo.PatientPwd=[NSMutableString stringWithUTF8String:tmp_PatientPwd];
            patientInfo.PatientName=[NSMutableString stringWithUTF8String:tmp_PatientName];
            patientInfo.PatientSex=[NSMutableString stringWithUTF8String:tmp_PatientSex];
            patientInfo.CellPhone=[NSMutableString stringWithUTF8String:tmp_CellPhone];
            patientInfo.Birthday=[NSMutableString stringWithUTF8String:tmp_Birthday];
            patientInfo.Age=tmp_Age;
            if (tmp_PatientWeight==NULL)
            {
                patientInfo.Marriage=@"";
            }
            else
            {
                patientInfo.Marriage=[NSMutableString stringWithUTF8String:tmp_Marriage];
            }
            if (tmp_NativePlace==NULL)
            {
                patientInfo.NativePlace=@"";
            }
            else
            {
                patientInfo.NativePlace=[NSMutableString stringWithUTF8String:tmp_NativePlace];
            }
            if (tmp_BloodModel==NULL)
            {
                patientInfo.BloodModel=@"";
            }
            else
            {
                patientInfo.BloodModel=[NSMutableString stringWithUTF8String:tmp_BloodModel];
            }
            if (tmp_PatientContactWay==NULL)
            {
                patientInfo.PatientContactWay=@"";
            }
            else
            {
                patientInfo.PatientContactWay=[NSMutableString stringWithUTF8String:tmp_PatientContactWay];
            }
            if (tmp_FamilyPhone==NULL)
            {
                patientInfo.FamilyPhone=@"";
            }
            else
            {
                patientInfo.FamilyPhone=[NSMutableString stringWithUTF8String:tmp_FamilyPhone];
            }
            if (tmp_Email==NULL)
            {
                patientInfo.Email=@"";
            }
            else
            {
                 patientInfo.Email=[NSMutableString stringWithUTF8String:tmp_Email];
            }
            if (tmp_Vocation==NULL)
            {
                patientInfo.Vocation=@"";
            }
            else
            {
                patientInfo.Vocation=[NSMutableString stringWithUTF8String:tmp_Vocation];
            }
            if (tmp_Address==NULL)
            {
                patientInfo.Address=@"";
            }
            else
            {
                patientInfo.Address=[NSMutableString stringWithUTF8String:tmp_Address];
            }
            if (tmp_PatientHeight==NULL)
            {
                patientInfo.PatientHeight=@"";
            }
            else
            {
                patientInfo.PatientHeight=[NSMutableString stringWithUTF8String:tmp_PatientHeight];
            }
            if (tmp_PatientWeight==NULL)
            {
                patientInfo.PatientWeight=@"";
            }
            else
            {
                patientInfo.PatientWeight=[NSMutableString stringWithUTF8String:tmp_PatientWeight];
            }
            if (tmp_PatientRemarks==NULL)
            {
                patientInfo.PatientRemarks=@"";
            }
            else
            {
                patientInfo.PatientRemarks=[NSMutableString stringWithUTF8String:tmp_PatientRemarks];
            }
            if (tmp_Picture==NULL)
            {
                patientInfo.Picture=@"";
            }
            else
            {
                patientInfo.Picture=[NSMutableString stringWithUTF8String:tmp_Picture];
            }

            [_dataArray addObject:patientInfo];
        }
    }
    return _dataArray;
}
//从数据库中读取治疗数据表的数据
-(NSMutableArray *)getTreatDataFromDataBase
{
    _dataArray=[NSMutableArray array];
    char zSql[]="select * from tbl_Treat";/*设置查询语句的C语言数组*/
    sqlite3_stmt *statement;
    if (sqlite3_prepare(mySqlite, zSql, -1, &statement, nil)==SQLITE_OK)
    {
        while (sqlite3_step(statement)==SQLITE_ROW)
        {
            TreatInfo *treatInfo=[TreatInfo new];
            
            char *tmp_PatientID=(char *)sqlite3_column_text(statement, 1);
            char *tmp_Date=(char *)sqlite3_column_text(statement, 2);
            char *tmp_Strength=(char *)sqlite3_column_text(statement, 3);
            char *tmp_Frequency=(char *)sqlite3_column_text(statement, 4);
            char *tmp_Time=(char *)sqlite3_column_text(statement, 5);
            char *tmp_BeginTime=(char *)sqlite3_column_text(statement, 6);
            char *tmp_EndTime=(char *)sqlite3_column_text(statement, 7);
            char *tmp_CureTime=(char *)sqlite3_column_text(statement, 8);
            
            treatInfo.PatientID=[NSMutableString stringWithUTF8String:tmp_PatientID];
            treatInfo.Date=[NSMutableString stringWithUTF8String:tmp_Date];
            treatInfo.Strength=[NSMutableString stringWithUTF8String:tmp_Strength];
            treatInfo.Frequency=[NSMutableString stringWithUTF8String:tmp_Frequency];
            treatInfo.Time=[NSMutableString stringWithUTF8String:tmp_Time];
            treatInfo.BeginTime=[NSMutableString stringWithUTF8String:tmp_BeginTime];
            treatInfo.EndTime=[NSMutableString stringWithUTF8String:tmp_EndTime];
            treatInfo.CureTime=[NSMutableString stringWithUTF8String:tmp_CureTime];
            
            [_dataArray addObject:treatInfo];
        }
    }
    return _dataArray;
}
//从数据库中读取评估数据表的数据
-(NSMutableArray *)getEvaluateDataFromDataBase
{
    _dataArray=[NSMutableArray array];
    char zSql[]="select * from tbl_Evaluate";/*设置查询语句的C语言数组*/
    sqlite3_stmt *statement;
    if (sqlite3_prepare(mySqlite, zSql, -1, &statement, nil)==SQLITE_OK)
    {
        while (sqlite3_step(statement)==SQLITE_ROW)
        {
            EvaluateInfo *evaluateInfo=[EvaluateInfo new];
            
            char *tmp_PatientID=(char *)sqlite3_column_text(statement, 1);
            char *tmp_ListFlag=(char *)sqlite3_column_text(statement, 2);
            char *tmp_Date=(char *)sqlite3_column_text(statement, 3);
            char *tmp_Time=(char *)sqlite3_column_text(statement, 4);
            char *tmp_Score=(char *)sqlite3_column_text(statement, 5);
            char *tmp_Quality=(char *)sqlite3_column_text(statement, 6);
            char *tmp_AdviceFreq=(char *)sqlite3_column_text(statement, 7);
            char *tmp_AdviceTime=(char *)sqlite3_column_text(statement, 8);
            char *tmp_AdviceStrength=(char *)sqlite3_column_text(statement, 9);
            char *tmp_AdviceNum=(char *)sqlite3_column_text(statement, 10);
            
            evaluateInfo.PatientID=[NSMutableString stringWithUTF8String:tmp_PatientID];
            evaluateInfo.ListFlag=[NSMutableString stringWithUTF8String:tmp_ListFlag];
            evaluateInfo.Date=[NSMutableString stringWithUTF8String:tmp_Date];
            evaluateInfo.Time=[NSMutableString stringWithUTF8String:tmp_Time];
            evaluateInfo.Score=[NSMutableString stringWithUTF8String:tmp_Score];
            evaluateInfo.Quality=[NSMutableString stringWithUTF8String:tmp_Quality];
            evaluateInfo.AdviceFreq=(tmp_AdviceFreq) ? [NSString stringWithUTF8String:tmp_AdviceFreq] : nil;
            evaluateInfo.AdviceTime=(tmp_AdviceTime) ? [NSMutableString stringWithUTF8String:tmp_AdviceTime] : nil;
            evaluateInfo.AdviceStrength=(tmp_AdviceStrength) ? [NSMutableString stringWithUTF8String:tmp_AdviceStrength] : nil;
            evaluateInfo.AdviceNum=(tmp_AdviceNum) ? [NSMutableString stringWithUTF8String:tmp_AdviceNum] : nil;
            
            [_dataArray addObject:evaluateInfo];
        }
    }
    return _dataArray;
}
//从数据库中读取蓝牙外射表的数据
-(NSMutableArray *)getBluetoothDataFromDataBase
{
    _dataArray=[NSMutableArray array];
    char zSql[]="select * from tbl_Bluetooth";/*设置查询语句的C语言数组*/
    sqlite3_stmt *statement;
    if (sqlite3_prepare(mySqlite, zSql, -1, &statement, nil)==SQLITE_OK)
    {
        while (sqlite3_step(statement)==SQLITE_ROW)
        {
            BluetoothInfo *bluetoothInfo=[[BluetoothInfo alloc] init];
            
            char *tmp_saveId=(char *)sqlite3_column_text(statement, 1);
            char *tmp_peripheralIdentify=(char *)sqlite3_column_text(statement, 2);
            
            bluetoothInfo.saveId=[NSMutableString stringWithUTF8String:tmp_saveId];
            bluetoothInfo.peripheralIdentify=[NSMutableString stringWithUTF8String:tmp_peripheralIdentify];
            
            [_dataArray addObject:bluetoothInfo];
        }
    }
    return _dataArray;
}

/**********(对表tbl_Patient进行操作)**********/
//数据库插入数据，添加数据
-(void)insertUserInfo:(PatientInfo *)patientInfo
{
    NSString *sql=[NSString stringWithFormat:@"insert into tbl_Patient ('PatientID','PatientPwd','PatientName','PatientSex','CellPhone','Birthday','PatientContactWay','FamilyPhone','Email','PatientRemarks') VALUES('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@')",patientInfo.PatientID,patientInfo.PatientPwd,patientInfo.PatientName,patientInfo.PatientSex,patientInfo.CellPhone,patientInfo.Birthday,patientInfo.PatientContactWay,patientInfo.FamilyPhone,patientInfo.Email,patientInfo.PatientRemarks];
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updataUserInfo:(PatientInfo *)patientInfo
{
     NSString *sql=[NSString stringWithFormat:@"update tbl_Patient set 'PatientPwd'='%@','PatientName'='%@','PatientSex'='%@','CellPhone'='%@','Birthday'='%@','PatientContactWay'='%@','FamilyPhone'='%@','Email'='%@','PatientRemarks'='%@' where PatientID=%@",patientInfo.PatientPwd,patientInfo.PatientName,patientInfo.PatientSex,patientInfo.CellPhone,patientInfo.Birthday,patientInfo.PatientContactWay,patientInfo.FamilyPhone,patientInfo.Email,patientInfo.PatientRemarks,patientInfo.PatientID];
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"更新成功！");
    }
    else
    {
        NSLog(@"更新失败！");
    }
}

/**********(对表tbl_TREAT进行操作)**********/
//数据库插入数据，添加数据
-(void)insertTreatInfo:(TreatInfo *)treatInfo
{
    NSString *sql=[NSString stringWithFormat:@"insert into tbl_Treat ('PatientID','Date','Strength','Frequency','Time','BeginTime','EndTime','CureTime') VALUES('%@','%@','%@','%@','%@','%@','%@',%@)",treatInfo.PatientID,treatInfo.Date,treatInfo.Strength,treatInfo.Frequency,treatInfo.Time,treatInfo.BeginTime,treatInfo.EndTime,treatInfo.CureTime];
    NSLog(@"%@",sql);
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updateTreatInfo:(TreatInfo *)treatInfo
{
    NSString *sql=[NSString stringWithFormat:@"update tbl_Treat set 'Strength'='%@','Frequency'='%@','Time'='%@','EndTime'='%@','CureTime'='%@' where PatientID='%@' and BeginTime='%@'",treatInfo.Strength,treatInfo.Frequency,treatInfo.Time,treatInfo.EndTime,treatInfo.CureTime,treatInfo.PatientID,treatInfo.BeginTime];
     NSLog(@"%@",sql);
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"更新成功！");
    }
    else
    {
        NSLog(@"更新失败！");
    }
}

/**********(对表tbl_Evaluate进行操作)**********/
//数据库插入数据，添加数据
-(void)insertEvaluateInfo:(EvaluateInfo *)evaluateInfo
{
    NSString *sql=[NSString stringWithFormat:@"insert into tbl_Evaluate ('PatientID','ListFlag','Date','Time','Score','Quality') VALUES('%@','%@','%@','%@','%@','%@')",evaluateInfo.PatientID,evaluateInfo.ListFlag,evaluateInfo.Date,evaluateInfo.Time,evaluateInfo.Score,evaluateInfo.Quality];
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updateEvaluateInfo:(EvaluateInfo *)evaluateInfo
{
    NSString *sql=[NSString stringWithFormat:@"update tbl_Evaluate set 'Time'='%@','Score'='%@','Quality'='%@' where ListFlag='%@' and Date='%@' and PatientID='%@'",evaluateInfo.Time,evaluateInfo.Score,evaluateInfo.Quality,evaluateInfo.ListFlag,evaluateInfo.Date,evaluateInfo.PatientID];
    NSLog(@"%@",sql);
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"更新成功！");
        arr=[self getEvaluateDataFromDataBase];
    }
    else
    {
        NSLog(@"更新失败！");
    }
}

-(void)deleteEvaluateInfo
{
    NSString *sql=[NSString stringWithFormat:@"delete from tbl_Evaluate where PatientID='13122359761'"];
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"删除成功！");
    }
    else
    {
        NSLog(@"删除失败！");
    }
}

/**********(对表tbl_Bluetooth进行操作)**********/
//数据库插入数据，添加数据
-(void)insertPeripheralInfo:(BluetoothInfo *)bluetoothInfo
{
    NSString *sql=[NSString stringWithFormat:@"insert into tbl_Bluetooth ('saveId','peripheralIdentify') VALUES('1','%@')",bluetoothInfo.peripheralIdentify];
    NSLog(@"%@",sql);
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"插入成功！");
    }
    else
    {
        NSLog(@"插入失败！");
    }
}
//更新数据操作
-(void)updatePeripheralInfo:(BluetoothInfo *)bluetoothInfo
{
    NSString *sql=[NSString stringWithFormat:@"update tbl_Bluetooth set 'peripheraiIdentify'='%@', where savaId='1'",bluetoothInfo.peripheralIdentify];
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"更新成功！");
    }
    else
    {
        NSLog(@"更新失败！");
    }
}
//删除数据操作
-(void)deletePeripheralInfo
{
    NSString *sql=[NSString stringWithFormat:@"delete from tbl_Bluetooth where saveId='1'"];
    if (sqlite3_exec(mySqlite, [sql UTF8String], nil, nil, nil)==SQLITE_OK)
    {
        NSLog(@"删除成功！");
    }
    else
    {
        NSLog(@"删除失败！");
    }
}


@end