//
//  FreeBindViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/8.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "FreeBindViewController.h"
#import "DataBaseOpration.h"
#import "myHeader.h"

@interface FreeBindViewController ()

@end

@implementation FreeBindViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    UIImageView *device=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_device"]];
    UIImageView *phone=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_phone"]];
    UIImageView *unbind=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_unbind"]];
    if (SCREEN_HEIGHT==480)
    {
        device.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/30+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        phone.frame=CGRectMake(SCREEN_WIDTH*12/20, SCREEN_HEIGHT/30+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        unbind.frame=CGRectMake(SCREEN_WIDTH*9/20, SCREEN_HEIGHT/8+65, SCREEN_WIDTH*2/20, SCREEN_WIDTH*3/20);
    }
    else
    {
        device.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/10+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        phone.frame=CGRectMake(SCREEN_WIDTH*12/20, SCREEN_HEIGHT/10+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        unbind.frame=CGRectMake(SCREEN_WIDTH*9/20, SCREEN_HEIGHT/6+65, SCREEN_WIDTH*2/20, SCREEN_WIDTH*2/20);
    }
    
    [self.view addSubview:device];
    [self.view addSubview:phone];
    [self.view addSubview:unbind];
    
    if (SCREEN_HEIGHT==480)
    {
        _Label_One.font=[UIFont systemFontOfSize:12];
        _Label_Two.font=[UIFont systemFontOfSize:12];
    }
    _Label_One.textAlignment=NSTextAlignmentCenter;
    _Label_One.text=@"解除绑定后，疗疗将无法正常使用";
    _Label_Two.textAlignment=NSTextAlignmentCenter;
    _Label_Two.text=@"解除绑定后，可以使用其他手机连接疗疗，或更换疗疗";
    _Label_Two.numberOfLines=0;
    if (SCREEN_HEIGHT==667)
    {
        _Label_One.font=[UIFont systemFontOfSize:20];
        _Label_Two.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==736)
    {
        _Label_One.font=[UIFont systemFontOfSize:22.5];
        _Label_Two.font=[UIFont systemFontOfSize:22.5];
    }
    
    [_FreeBindButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    [_FreeBindButton setTitle:@"解除绑定" forState:UIControlStateNormal];
    if (SCREEN_HEIGHT==667)
    {
        _FreeBindButton.titleLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==736)
    {
        _FreeBindButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
    }
}

- (IBAction)FreeBindButtonClick:(UIButton *)sender
{
    //1.删除数据库中的蓝牙绑定数据
    DataBaseOpration *dbOpration=[[DataBaseOpration alloc] init];
    [dbOpration deletePeripheralInfo];
    [dbOpration closeDataBase];
    NSNotification *notification=[NSNotification notificationWithName:@"Free" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    //2.跳转界面
    //[self.navigationController popToRootViewControllerAnimated:YES];
    NSArray *arr=self.navigationController.viewControllers;
    if (arr.count==5)
    {
        [self.navigationController popToViewController:[arr objectAtIndex:2] animated:YES];
    }
    else if (arr.count==4)
    {
        [self.navigationController popToViewController:[arr objectAtIndex:1] animated:YES];
    }
    else
    {
        [self.navigationController popToViewController:[arr objectAtIndex:0] animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
