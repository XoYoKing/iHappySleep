//
//  IntelligentHardwareViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/11/6.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "IntelligentHardwareViewController.h"
#import "myHeader.h"
#import "BindViewController.h"
#import "FreeBindViewController.h"
#import "CircleView.h"

@interface IntelligentHardwareViewController ()

@end

@implementation IntelligentHardwareViewController
{
    CAShapeLayer *myLayer;
    CAShapeLayer *progressLayer;
    UILabel *percentLabel;
    NSString *numberStr_One;
    NSString *numberStr_Two;
    
    NSArray *IntelligentHardwareArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    myLayer=[[CAShapeLayer alloc] init];
    if (SCREEN_WIDTH==320)
    {
        myLayer.frame=CGRectMake(72.5, 114, 175, 175);
    }
    else if (SCREEN_WIDTH==375)
    {
        myLayer.frame=CGRectMake(95, 124, 185, 185);
    }
    else if (SCREEN_WIDTH==414)
    {
        myLayer.frame=CGRectMake(109.5, 114, 195, 195);
    }
    myLayer.path = [self drawPathWithArcCenter:4];
    myLayer.fillColor = [UIColor clearColor].CGColor;
    myLayer.strokeColor = [UIColor colorWithRed:0.86f green:0.86f blue:0.86f alpha:0.4f].CGColor;
    myLayer.lineWidth = 10;
    
    percentLabel=[[UILabel alloc] init];
    percentLabel.textAlignment=NSTextAlignmentCenter;
    percentLabel.font=[UIFont systemFontOfSize:20];
    
    UIView *lineOne=[[UIView alloc] initWithFrame:CGRectMake(_IntelligentHardwareTableView.frame.origin.x, _IntelligentHardwareTableView.frame.origin.y, SCREEN_WIDTH, 1)];
    lineOne.backgroundColor=[UIColor grayColor];
    [self.view addSubview:lineOne];
    
    _IntelligentHardwareTableView.contentInset=UIEdgeInsetsMake(-64, 0, 0, 0);
    _IntelligentHardwareTableView.scrollEnabled=NO;
    
    UIView *lineTwo=[[UIView alloc] initWithFrame:CGRectMake(_IntelligentHardwareTableView.frame.origin.x, _IntelligentHardwareTableView.frame.origin.y+50, SCREEN_WIDTH, 1)];
    lineTwo.backgroundColor=[UIColor grayColor];
    [self.view addSubview:lineTwo];
    
    if ([_identify isEqualToString:@"已绑定"])
    {
        IntelligentHardwareArray=@[@"解除绑定"];
        if (_electricQuality!=nil)
        {
            if ([_electricQuality isEqualToString:@"未连接疗疗"])
            {
                percentLabel.text=_electricQuality;
            }
            else
            {
                numberStr_One=[_electricQuality substringWithRange:NSMakeRange(14, 1)];
                numberStr_Two=[_electricQuality substringWithRange:NSMakeRange(15, 1)];
                unichar numberStr=[_electricQuality characterAtIndex:15];
                if (numberStr>='a' && numberStr<='f')
                {
                    numberStr_Two=[NSString stringWithFormat:@"%d",numberStr-87];
                }
                percentLabel.text=[NSString stringWithFormat:@"%d%%",[numberStr_One intValue]*16+[numberStr_Two intValue]];
            }
        }
        else
        {
            percentLabel.text=@"未连接疗疗";
        }
    }
    else if ([_identify isEqualToString:@"未绑定"])
    {
        IntelligentHardwareArray=@[@"绑定疗疗"];
        percentLabel.textAlignment=NSTextAlignmentCenter;
        percentLabel.text=@"未连接疗疗";
    }

    if (SCREEN_WIDTH==320)
    {
        percentLabel.frame=CGRectMake(5, 70, 165, 35);
    }
    else if (SCREEN_WIDTH==375)
    {
        percentLabel.frame=CGRectMake(5, 75, 175, 35);
    }
    else if (SCREEN_WIDTH==414)
    {
        percentLabel.frame=CGRectMake(5, 80, 185, 35);
    }
    [self setupLayer];
    [myLayer addSublayer:percentLabel.layer];
    
    [self.view.layer addSublayer:myLayer];
    
    _IntelligentHardwareTableView.delegate=self;
    _IntelligentHardwareTableView.dataSource=self;
}

- (void)setupLayer
{
    progressLayer = [CAShapeLayer layer];
    NSLog(@"%f",([numberStr_One floatValue]*16+[numberStr_Two floatValue])/25);
    //progressLayer.path = [self drawPathWithArcCenter:([numberStr_One floatValue]*16+[numberStr_Two floatValue])/25];
    CGFloat position_y = myLayer.frame.size.height/2;
    CGFloat position_x = myLayer.frame.size.width/2;
    progressLayer.path =[UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y) radius:position_y startAngle:((3-([numberStr_One floatValue]*16+[numberStr_Two floatValue])/25)*M_PI/2) endAngle:(3*M_PI/2)clockwise:YES].CGPath;
    
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0].CGColor;
    progressLayer.lineWidth = 10;
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.lineJoin = kCALineJoinRound;
    [myLayer addSublayer:progressLayer];
}

- (CGPathRef)drawPathWithArcCenter:(CGFloat)x
{
    CGFloat position_y = myLayer.frame.size.height/2;
    CGFloat position_x = myLayer.frame.size.width/2; // Assuming that width == height
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y) radius:position_y startAngle:(-M_PI/2) endAngle:((x-1)*M_PI/2)clockwise:YES].CGPath;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return IntelligentHardwareArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"IntelligentHardwareCell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    cell.textLabel.textAlignment=NSTextAlignmentCenter;
    if (SCREEN_WIDTH==320)
    {
        cell.textLabel.font=[UIFont systemFontOfSize:18];
    }
    else if (SCREEN_WIDTH==375)
    {
        cell.textLabel.font=[UIFont systemFontOfSize:20];
    }
    else
    {
        cell.textLabel.font=[UIFont systemFontOfSize:22];
    }
    cell.textLabel.text=[IntelligentHardwareArray objectAtIndex:indexPath.row];
    [cell setBackgroundColor:[UIColor clearColor]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([_identify isEqualToString:@"已绑定"])
    {
        FreeBindViewController *freeBindViewController=[[FreeBindViewController alloc] initWithNibName:@"FreeBindViewController" bundle:nil];
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"绑定疗疗";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:freeBindViewController animated:YES];
    }
    else if ([_identify isEqualToString:@"未绑定"])
    {
        BindViewController *bindViewController=[[BindViewController alloc] initWithNibName:@"BindViewController" bundle:nil];
        bindViewController.bindFlag=@"2";
        UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
        temporaryBarButtonItem.title = @"绑定疗疗";
        self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
        [self.navigationController pushViewController:bindViewController animated:YES];
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
