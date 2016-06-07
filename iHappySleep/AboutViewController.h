//
//  AboutViewController.h
//  iHappySleep
//
//  Created by 诺之家 on 15/12/1.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) IBOutlet UITableView *aboutTableView;

@end
