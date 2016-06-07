//
//  EvaluateViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/9/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataBaseOpration.h"
#import "PatientInfo.h"
#import "EvaluateInfo.h"

@protocol EvaluateView <NSObject>

-(void)evaluateViewAlterBackBarButtonItemTitle:(NSString *)title;

@end

@interface EvaluateViewController : UIViewController

@property PatientInfo *patientInfo;

@property id<EvaluateView>delegate;

@end
