//
//  AssessmentViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 16/3/2.
//  Copyright © 2016年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientInfo.h"

@interface AssessmentViewController : UIViewController<UIPickerViewDelegate,UIPickerViewDataSource>

@property NSInteger tableListTag;            //标志哪一种量表
@property PatientInfo *patientInfo;

@property NSArray *EvaluateInfoArray;
@property NSArray *sleepTipsArray;           //存储睡眠贴士的23条建议
@property NSMutableArray *sleepTipsResultArray;//存储睡眠贴士结果包括哪几条

@property (strong,nonatomic) UIPickerView *pickerView;
@property NSMutableArray *dateHourArray;
@property NSMutableArray *dateMinuteArray;

@end
