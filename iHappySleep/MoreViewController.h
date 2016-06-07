//
//  MoreViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/9/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PatientInfo.h"

@protocol MoreView <NSObject>

-(void)alterBackBarButtonItemTitle:(NSString *)title;

@end

@interface MoreViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property id<MoreView>delegate;
@property PatientInfo *patientInfo;

@end
