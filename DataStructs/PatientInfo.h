//
//  PatientInfo.h
//  iHappySleep
//
//  Created by 诺之家 on 15/10/9.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PatientInfo : NSObject

@property (strong,nonatomic) NSString *PatientID;
@property (strong,nonatomic) NSString *PatientPwd;
@property (strong,nonatomic) NSString *PatientName;
@property (strong,nonatomic) NSString *PatientSex;
@property (strong,nonatomic) NSString *CellPhone;
@property (strong,nonatomic) NSString *Birthday;
@property                    NSInteger Age;
@property (strong,nonatomic) NSString *Marriage;
@property (strong,nonatomic) NSString *NativePlace;
@property (strong,nonatomic) NSString *BloodModel;
@property (strong,nonatomic) NSString *PatientContactWay;
@property (strong,nonatomic) NSString *FamilyPhone ;
@property (strong,nonatomic) NSString *Email;
@property (strong,nonatomic) NSString *Vocation;
@property (strong,nonatomic) NSString *Address;
@property (strong,nonatomic) NSString *PatientRemarks;
@property (strong,nonatomic) NSString *PatientHeight;
@property (strong,nonatomic) NSString *PatientWeight;
@property (strong,nonatomic) NSString *Picture;

@end
