//
//  MethodViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/12/25.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import "MethodViewController.h"
#import "myHeader.h"

@interface MethodViewController ()

@end

@implementation MethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _scrollView=[[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _scrollView.pagingEnabled=YES;
    _scrollView.contentSize=CGSizeMake(SCREEN_WIDTH*6, 0);
    _scrollView.contentOffset=CGPointMake(0, 0);
    _scrollView.bounces=NO;
    
    UIImageView  *imageview_one=[[UIImageView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT/15, SCREEN_WIDTH, SCREEN_WIDTH*128/95)];
    [imageview_one setImage:[UIImage imageNamed:@"use1.png"]];
    UIImageView *imageview_two=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH, SCREEN_HEIGHT/15, SCREEN_WIDTH, SCREEN_WIDTH*220/140)];
    [imageview_two setImage:[UIImage imageNamed:@"use2.png"]];
    UIImageView *imageview_three=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*2, SCREEN_HEIGHT/15, SCREEN_WIDTH, SCREEN_WIDTH*135/95)];
    [imageview_three setImage:[UIImage imageNamed:@"use3.png"]];
    UIImageView  *imageview_foure=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*3, SCREEN_HEIGHT/15, SCREEN_WIDTH, SCREEN_WIDTH*100/95)];
    [imageview_foure setImage:[UIImage imageNamed:@"use4.png"]];
    UIImageView *imageview_five=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*4, SCREEN_HEIGHT/15, SCREEN_WIDTH, SCREEN_WIDTH*105/95)];
    [imageview_five setImage:[UIImage imageNamed:@"use5.png"]];
    UIImageView *imageview_six=[[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH*5, SCREEN_HEIGHT/15, SCREEN_WIDTH, SCREEN_WIDTH*100/95)];
    [imageview_six setImage:[UIImage imageNamed:@"use6.png"]];
    
    [_scrollView addSubview:imageview_one];
    [_scrollView addSubview:imageview_two];
    [_scrollView addSubview:imageview_three];
    [_scrollView addSubview:imageview_foure];
    [_scrollView addSubview:imageview_five];
    [_scrollView addSubview:imageview_six];
    
    [self.view addSubview:_scrollView];
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
