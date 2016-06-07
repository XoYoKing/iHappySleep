//
//  IntelligentHardwareViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/11/6.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntelligentHardwareViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property NSString *identify; //标志刺激仪是否绑定
@property NSString *electricQuality;
@property (strong, nonatomic) IBOutlet UITableView *IntelligentHardwareTableView;

@end
