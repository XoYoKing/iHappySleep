//
//  AttentionDetailViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/12/29.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AttentionDetailViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property NSInteger index;
@property NSDictionary *questionAndAnswer;

@end
