//
//  RelatedAnswerViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/11/20.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RelatedAnswerViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property NSInteger questionIndex;
@property NSDictionary *answerDic;

@end
