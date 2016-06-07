//
//  CESTreatViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/9/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "CESTreatViewController.h"
#import "myHeader.h"
#import "DataBaseOpration.h"
#import "BindViewController.h"
#import "UIButton+Common.h"

@interface CESTreatViewController ()<UITableViewDelegate,UITableViewDataSource,NSXMLParserDelegate,NSURLConnectionDelegate>

@property (strong, nonatomic) NSTimer *CircleProgressTimer;
@property (assign, nonatomic) double initialProgress;
@property (assign, nonatomic, readonly) double percent;
@property (nonatomic) UIColor *progressColor;

@property (strong, nonatomic) NSTimer *circleTimer;

@end

@implementation CESTreatViewController
{
    NSString *bleState;  //蓝牙状态
    
    NSTimer *checkElectric;                //设置阻抗检测的NSTimer对象
    
    NSInteger electricCurrentNum;          //读取本地数据库中电流强度
    
    UIButton *modelButton;                 //刺激模式按钮
    
    UIButton *optionButton;                //操作按钮（显示开始、倒计时等等信息及功能，为圆形按钮）
    UIButton *anotherOptionButton;
    CAShapeLayer *myLayer;
    CAShapeLayer *progressLayer;
    UIColor *tintColor;
    
    NSMutableArray *electricCurrentButtonArray;  //存储电流强度12个button的数组
    UILabel *electricNumLabel;                   //用来显示电流强度大小

    NSArray *modelArray;                         //存储刺激模式的数组
    
    UIView *view;                          //创建门板的view
    UITableView *tableView;                //在view上添加的tableview
    UIButton *selectButton;                //标志是否选中这一行，或者是否选择这个频率或者时间
    
    NSMutableArray *modelButtonArray;           //存储tableviewcell中模式按钮的数组
    NSInteger timeIndex;                                 //用来记录选择时间的index
    NSInteger modelIndex;                                //用来记录选择模式的index
    
    NSString *order;
    NSString *value;
    NSMutableArray *characteristicArray;
    CBCharacteristic *characteristicUUID;

    
    UIButton *clickButton;
    
    NSMutableArray *stringArray;                         //存储应答数据的字符串数组
    
    NSString *connectedStateText;
    
    DataBaseOpration *dbOpration;
    
    __block int timeout;
    int time;
    int minutes;
    int seconds;
    dispatch_queue_t queue;
    dispatch_source_t _timer;
    
    UIBackgroundTaskIdentifier backgroundTask;
    NSTimeInterval backgroundUpdateInterval;
    
    NSDate *BegainDate;
    
    NSString *Date;
    NSString *BegainTime;
    NSString *EndTime;
    NSString *CureTime;
    
    NSArray *array;
    
    UIAlertView *alert;
    
    int count;
    int countAlert;
    int num;
    
    char chOUTFinal[8];
    
    NSString *optionButtonState;
    UIButton *connectIng;                          //设置正在连接按钮，不做任何点击事件
    
    BOOL hasConnect;                               //判断是否连接上蓝牙外设
    int percent;                                   //电量的百分比
    
    NSTimer *readElectricQuality;                  //设置读取电量的NSTimer对象
    NSTimer *autoDisconnectTimer;                  //设置自动断开的计时器(每秒执行)
    int countSeconds;                              //记录自动断开前计时
    int countElectric;                             //记录电量提示弹出次数
    int countElectric_Two;                         //记录电量提示弹出次数
    int countElectric_Three;                       //记录电量大于20%时发送电流调节命令次数
    int countElectricQuality;                      //记录电量命令发送次数
    int addBtn;                                    //记录添加“正在连接...”次数
    int deviceInfo;                                //记录上传设备序列号次数
}
@synthesize percent = _percent;
@synthesize webData,soapResults,xmlParser,elementFound,matchingElement,conn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.view.backgroundColor=[UIColor whiteColor];
    
    //1.创建CBCentralManager
    self.centralMgr=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //将CES界面分成四个部分
    UIView *lineOne=[[UIView alloc] initWithFrame:CGRectMake(20, CES_SCREENH_HEIGHT/4+CES_SCREENH_HEIGHT/30, SCREEN_WIDTH-40, 0.5)];
    lineOne.backgroundColor=[UIColor blackColor];
    UIView *lineThree=[[UIView alloc] initWithFrame:CGRectMake(20, CES_SCREENH_HEIGHT/2, SCREEN_WIDTH-40, 0.5)];
    lineThree.backgroundColor=[UIColor blackColor];
    [self.view addSubview:lineOne];
    [self.view addSubview:lineThree];
    
    modelArray=[NSArray arrayWithObjects:@"1",@"2",@"3", nil];
    
    dbOpration=[[DataBaseOpration alloc] init];
    NSArray *treatInfoArray=[dbOpration getTreatDataFromDataBase];
    [dbOpration closeDataBase];
    if (_patientInfo!=nil)
    {
        NSMutableArray *treatInfoAtPatientID=[NSMutableArray array];
        for (TreatInfo *tmp in treatInfoArray)
        {
            if ([tmp.PatientID isEqualToString:_patientInfo.PatientID])
            {
                [treatInfoAtPatientID addObject:tmp];
            }
        }
        //判断数据库中是否有治疗数据
        if (treatInfoAtPatientID.count>0)
        {
            _treatInfo=[treatInfoAtPatientID objectAtIndex:treatInfoAtPatientID.count-1];
        }
    }
    
    modelButtonArray=[NSMutableArray array];
    stringArray=[NSMutableArray array];
    
    if (_treatInfo==nil)
    {
        modelIndex=0;
        timeIndex=1;
        time=1200;
        timeout=1200;
        electricCurrentNum=1;
    }
    else
    {
        time=[_treatInfo.Time intValue]; //倒计时时间
        if ([_treatInfo.Frequency isEqualToString:@"1"])
        {
            modelIndex=0;
        }
        else if ([_treatInfo.Frequency isEqualToString:@"2"])
        {
            modelIndex=1;
        }
        else if ([_treatInfo.Frequency isEqualToString:@"3"])
        {
            modelIndex=2;
        }
        if ([_treatInfo.Time isEqualToString:@"600"])
        {
            timeIndex=0;
            timeout=600;
        }
        else if ([_treatInfo.Time isEqualToString:@"1200"])
        {
            timeIndex=1;
            timeout=1200;
        }
        else if ([_treatInfo.Time isEqualToString:@"2400"])
        {
            timeIndex=2;
            timeout=2400;
        }
        else if ([_treatInfo.Time isEqualToString:@"3600"])
        {
            timeIndex=3;
            timeout=3600;
        }
        electricCurrentNum=[_treatInfo.Strength integerValue];
    }
    
    /***************第一部分**************/
    electricCurrentButtonArray=[NSMutableArray array];
    [self addSectionOne];
    /***************第二、三部分合并**************/
    [self addSectionTwoAndThree];
    /***************第四部分**************/
    [self addSectionFour];
    
    //注册通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendBluetoothInfoValue:) name:@"Note" object:nil];
    //注册解绑通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(freeBluetoothInfo) name:@"Free" object:nil];
    //注册切换用户通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUser) name:@"ChangeUser" object:nil];
    
    hasConnect=NO;
}

//每秒发送一次命令，检测是否连通
-(void)impedancePerseconds
{
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            characteristicUUID=characteristic;
            NSString *str=@"55AA0306848C";
            NSData *dataToWrite=[self dataWithHexstring:str];
            [_discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
}
/***************第一部分**************/
-(void)addSectionOne
{
    UIImageView *electricView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/12, CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT/30, SCREEN_WIDTH/15, CES_SCREENH_HEIGHT/21)];
    [electricView setImage:[UIImage imageNamed:@"ces_strength"]];
    UILabel *electricLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/12+SCREEN_WIDTH/10, CES_SCREENH_HEIGHT/30+CES_SCREENH_HEIGHT/30, SCREEN_WIDTH/3, CES_SCREENH_HEIGHT/16)];
    electricLabel.text=@"舒适我做主";
    electricNumLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH/4, CES_SCREENH_HEIGHT/30+CES_SCREENH_HEIGHT/30, SCREEN_WIDTH/8, CES_SCREENH_HEIGHT/16)];
    if (SCREEN_WIDTH==320)
    {
        electricLabel.font=[UIFont systemFontOfSize:20];
        electricNumLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==375)
    {
        electricLabel.font=[UIFont systemFontOfSize:22.5];
        electricNumLabel.font=[UIFont systemFontOfSize:22.5];
    }
    else
    {
        electricLabel.font=[UIFont systemFontOfSize:25];
        electricNumLabel.font=[UIFont systemFontOfSize:25];
    }
    NSString *str=[NSString stringWithFormat:@"%ld",(long)electricCurrentNum];
    electricNumLabel.textColor=[UIColor redColor];
    electricNumLabel.text=str;
    [self.view addSubview:electricView];
    [self.view addSubview:electricLabel];
    [self.view addSubview:electricNumLabel];
    
    //添加12个button (作为刺激强度)
    for (int i=1; i<=12; i++)
    {
        UIButton *btnElectric=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/9+(SCREEN_WIDTH/15)*(i-1), CES_SCREENH_HEIGHT/16+CES_SCREENH_HEIGHT/15+CES_SCREENH_HEIGHT/30, SCREEN_WIDTH*2/45, CES_SCREENH_HEIGHT/14)];
        btnElectric.btnFlag=@"00";
        
        if (i<=electricCurrentNum)
        {
            if (i<=3)
            {
                btnElectric.backgroundColor=[UIColor colorWithRed:0X84/255.0 green:0xfe/255.0 blue:0x37/255.0 alpha:1];
                btnElectric.tag=i;
                [btnElectric addTarget:self action:@selector(electricCurrentChoose:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btnElectric];
            }
            else if (i>3 && i<=6)
            {
                btnElectric.backgroundColor=[UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0x40/255.0 alpha:1];
                btnElectric.tag=i;
                [btnElectric addTarget:self action:@selector(electricCurrentChoose:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btnElectric];
            }
            else if (i>6 && i<=9)
            {
                
                btnElectric.backgroundColor=[UIColor colorWithRed:0xff/255.0 green:0xa5/255.0 blue:0x00/255.0 alpha:1];
                btnElectric.tag=i;
                [btnElectric addTarget:self action:@selector(electricCurrentChoose:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btnElectric];
            }
            else if (i>9 && i<=12)
            {
                btnElectric.backgroundColor=[UIColor colorWithRed:0xfc/255.0 green:0x5e/255.0 blue:0x5e/255.0 alpha:1];
                btnElectric.tag=i;
                [btnElectric addTarget:self action:@selector(electricCurrentChoose:) forControlEvents:UIControlEventTouchUpInside];
                [self.view addSubview:btnElectric];
            }
        }
        else
        {
            btnElectric.backgroundColor=[UIColor colorWithRed:0xed/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
            btnElectric.tag=i;
            [btnElectric addTarget:self action:@selector(electricCurrentChoose:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:btnElectric];
        }
        [electricCurrentButtonArray addObject:btnElectric];
    }
}
-(void)electricCurrentChoose:(UIButton *)sender
{
    if ([sender.btnFlag isEqualToString:@"11"])
    {
        if (sender.tag>electricCurrentNum)
        {
            UIButton *tmpButton=[electricCurrentButtonArray objectAtIndex:electricCurrentNum];
            electricCurrentNum++;
            if (electricCurrentNum<=3)
            {
                tmpButton.backgroundColor=[UIColor colorWithRed:0x84/255.0 green:0xfe/255.0 blue:0x37/255.0 alpha:1];
            }
            else if (electricCurrentNum>3 && electricCurrentNum<=6)
            {
                tmpButton.backgroundColor=[UIColor colorWithRed:0xff/255.0 green:0xff/255.0 blue:0x40/255.0 alpha:1];
            }
            else if (electricCurrentNum>6 && electricCurrentNum<=9)
            {
                tmpButton.backgroundColor=[UIColor colorWithRed:0xff/255.0 green:0xa5/255.0 blue:0x00/255.0 alpha:1];
            }
            else if (electricCurrentNum>9 && electricCurrentNum<=12)
            {
                tmpButton.backgroundColor=[UIColor colorWithRed:0xfc/255.0 green:0x5e/255.0 blue:0x5e/255.0 alpha:1];
            }
        }
        else if (sender.tag<electricCurrentNum)
        {
            electricCurrentNum--;
            UIButton *tmpButton=[electricCurrentButtonArray objectAtIndex:electricCurrentNum];
            tmpButton.backgroundColor=[UIColor colorWithRed:0xed/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];;
        }
        NSString *str=[NSString stringWithFormat:@"%ld",(long)electricCurrentNum];
        electricNumLabel.text=str;
        
        NSString *strElectric=[NSString string];
        NSString *strElectricVerify=[NSString string];
        if (electricCurrentNum==0)
        {
            strElectric=@"00";
            strElectricVerify=@"8E";
        }
        else if (electricCurrentNum==1)
        {
            strElectric=@"01";
            strElectricVerify=@"8F";
        }
        else if (electricCurrentNum==2)
        {
            strElectric=@"02";
            strElectricVerify=@"90";
        }
        else if (electricCurrentNum==3)
        {
            strElectric=@"03";
            strElectricVerify=@"91";
        }
        else if (electricCurrentNum==4)
        {
            strElectric=@"04";
            strElectricVerify=@"92";
        }
        else if (electricCurrentNum==5)
        {
            strElectric=@"05";
            strElectricVerify=@"93";
        }
        else if (electricCurrentNum==6)
        {
            strElectric=@"06";
            strElectricVerify=@"94";
        }
        else if (electricCurrentNum==7)
        {
            strElectric=@"07";
            strElectricVerify=@"95";
        }
        else if (electricCurrentNum==8)
        {
            strElectric=@"08";
            strElectricVerify=@"96";
        }
        else if (electricCurrentNum==9)
        {
            strElectric=@"09";
            strElectricVerify=@"97";
        }
        else if (electricCurrentNum==10)
        {
            strElectric=@"0A";
            strElectricVerify=@"98";
        }else if (electricCurrentNum==11)
        {
            strElectric=@"0B";
            strElectricVerify=@"99";
        }
        else if (electricCurrentNum==12)
        {
            strElectric=@"0C";
            strElectricVerify=@"9A";
        }
        for (CBCharacteristic *characteristic in characteristicArray)
        {
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
            {
                NSString *strSet=[NSString stringWithFormat:@"55AA030785%@%@",strElectric,strElectricVerify];
                NSData *dataToWriteSet=[self dataWithHexstring:strSet];
                [_discoveredPeripheral writeValue:dataToWriteSet forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
            }
        }
    }
    else
    {
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"请先连接疗疗" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismissAtCES:) userInfo:nil repeats:NO];
        [alert show];
    }
}
/***************第二、三部分合并**************/
-(void)addSectionTwoAndThree
{
    UIImageView *modelView=[[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/12, CES_SCREENH_HEIGHT/25+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60, SCREEN_WIDTH/15, CES_SCREENH_HEIGHT/21)];
    [modelView setImage:[UIImage imageNamed:@"ces_freq"]];
    UILabel *modelLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/12+SCREEN_WIDTH/10, CES_SCREENH_HEIGHT/30+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60, SCREEN_WIDTH/4, CES_SCREENH_HEIGHT/16)];
    modelLabel.text=@"模式选择";
    modelButton=[UIButton buttonWithType:UIButtonTypeSystem];
    modelButton.tag=3;
    modelButton.frame=CGRectMake(SCREEN_WIDTH-SCREEN_WIDTH*3.5/8, CES_SCREENH_HEIGHT/30+CES_SCREENH_HEIGHT*5/16+CES_SCREENH_HEIGHT/60, SCREEN_WIDTH/3, CES_SCREENH_HEIGHT/16);
    if (SCREEN_WIDTH==320)
    {
        modelLabel.font=[UIFont systemFontOfSize:20];
        modelButton.titleLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==375)
    {
        modelLabel.font=[UIFont systemFontOfSize:22.5];
        modelButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
    }
    else
    {
        modelLabel.font=[UIFont systemFontOfSize:25];
        modelButton.titleLabel.font=[UIFont systemFontOfSize:25];
    }
    if (modelIndex==0)
    {
        [modelButton setTitle:@"模式一" forState:UIControlStateNormal];
    }
    else if (modelIndex==1)
    {
        [modelButton setTitle:@"模式二" forState:UIControlStateNormal];
    }
    else if (modelIndex==2)
    {
        [modelButton setTitle:@"模式三" forState:UIControlStateNormal];
    }
    
    [modelButton addTarget:self action:@selector(chooseModel:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:modelView];
    [self.view addSubview:modelLabel];
    [self.view addSubview:modelButton];

}
/***************第四部分**************/
-(void)addSectionFour
{
    myLayer=[[CAShapeLayer alloc] init];
    
    if (SCREEN_WIDTH==320 && SCREEN_HEIGHT==568)
    {
        myLayer.frame=CGRectMake(87, 271, 146, 146);
    }
    if (SCREEN_WIDTH==320 && SCREEN_HEIGHT==480)
    {
        myLayer.frame=CGRectMake(87, 218, 146, 146);
    }
    else if (SCREEN_WIDTH==375)
    {
        myLayer.frame=CGRectMake(102, 329, 171, 171);
    }
    else if (SCREEN_WIDTH==414)
    {
        myLayer.frame=CGRectMake(112.5, 370.5, 189, 189);
    }
    myLayer.path = [self drawPathWithArcCenter:-1 andEnd:3];
    myLayer.fillColor = [UIColor clearColor].CGColor;
    myLayer.strokeColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0].CGColor;
    myLayer.lineWidth = 10;
    
    [self setupLayer];
    [self.view.layer addSublayer:myLayer];
    
    _timeLimit=time;
    _elapsedTime=0;
    
    optionButton=[UIButton buttonWithType:UIButtonTypeSystem];
    anotherOptionButton=[UIButton buttonWithType:UIButtonTypeSystem];
    [optionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
    [anotherOptionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
    
    if (SCREEN_WIDTH==320)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:20];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==375)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
    }
    else
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:25];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
    }
    if (SCREEN_WIDTH==414)
    {
        optionButton.frame=CGRectMake(SCREEN_WIDTH*2/7, CES_SCREENH_HEIGHT/10+CES_SCREENH_HEIGHT/2, SCREEN_WIDTH*3/7, SCREEN_WIDTH*3/7);
        anotherOptionButton.frame=CGRectMake(SCREEN_WIDTH*2.5/7, CES_SCREENH_HEIGHT/10+CES_SCREENH_HEIGHT*6.7/10, SCREEN_WIDTH*2/7, SCREEN_WIDTH/7);
    }
    else
    {
        optionButton.frame=CGRectMake(SCREEN_WIDTH*2/7, CES_SCREENH_HEIGHT/10+CES_SCREENH_HEIGHT/2, SCREEN_WIDTH*3/7, SCREEN_WIDTH*3/7);
        anotherOptionButton.frame=CGRectMake(SCREEN_WIDTH*2.5/7, CES_SCREENH_HEIGHT/10+CES_SCREENH_HEIGHT*6.7/10, SCREEN_WIDTH*2/7, SCREEN_WIDTH/7);
    }
    if (_bluetoothInfo!=nil)
    {
        if (SCREEN_WIDTH==320)
        {
            optionButton.titleLabel.font=[UIFont systemFontOfSize:20];
            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
        }
        else if (SCREEN_WIDTH==375)
        {
            optionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
        }
        else
        {
            optionButton.titleLabel.font=[UIFont systemFontOfSize:25];
            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
        }
        [optionButton setTitle:@"未连接疗疗" forState:UIControlStateNormal];
        optionButton.tag=11;
        anotherOptionButton.tag=11;
        [anotherOptionButton setTitle:@" " forState:UIControlStateNormal];
    }
    else
    {
        [optionButton setTitle:@"未绑定疗疗" forState:UIControlStateNormal];
    }
    optionButton.backgroundColor=[UIColor whiteColor];
    optionButton.layer.cornerRadius=SCREEN_WIDTH*3/14;
    optionButton.tag=0;
    anotherOptionButton.tag=0;
    [optionButton addTarget:self action:@selector(optionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [anotherOptionButton addTarget:self action:@selector(anotherOptionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:optionButton];
    [self.view addSubview:anotherOptionButton];
}

#pragma mark - Timer
- (void)startTimer
{
    if ((!self.circleTimer) || (![self.circleTimer isValid]))
    {
        self.circleTimer = [NSTimer scheduledTimerWithTimeInterval:1.00 target:self selector:@selector(poolTimer) userInfo:nil repeats:YES];
    }
}

- (void)poolTimer
{
    [self setElapsedTime:time-timeout];
}

- (void)setupLayer {
    
    progressLayer = [CAShapeLayer layer];
    progressLayer.path = [self drawPathWithArcCenter:-1 andEnd:3];
    progressLayer.fillColor = [UIColor clearColor].CGColor;
    progressLayer.strokeColor = [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0].CGColor;
    progressLayer.lineWidth = 10;
    progressLayer.lineCap = kCALineCapRound;
    progressLayer.lineJoin = kCALineJoinRound;
    [myLayer addSublayer:progressLayer];
}

- (CGPathRef)drawPathWithArcCenter:(CGFloat)x andEnd:(CGFloat)y
{
    CGFloat position_y = myLayer.frame.size.height/2;
    CGFloat position_x = myLayer.frame.size.width/2; // Assuming that width == height
    return [UIBezierPath bezierPathWithArcCenter:CGPointMake(position_x, position_y) radius:position_y startAngle:(x*M_PI/2) endAngle:(y*M_PI/2)clockwise:YES].CGPath;
}

- (void)setElapsedTime:(NSTimeInterval)elapsedTime {
    _initialProgress = [self calculatePercent:_elapsedTime toTime:_timeLimit];
    _elapsedTime = elapsedTime;
    
    progressLayer.strokeEnd = self.percent;
    [self startAnimation];
}

- (double)percent
{
    _percent = [self calculatePercent:_elapsedTime toTime:_timeLimit];
    
    myLayer.path = [self drawPathWithArcCenter:4*_percent-1 andEnd:3];
    myLayer.strokeColor= [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0].CGColor;
    
    return _percent;
}

- (double)calculatePercent:(NSTimeInterval)fromTime toTime:(NSTimeInterval)toTime
{
    if ((toTime > 0) && (fromTime > 0))
    {
        CGFloat progress = 0;
        progress = fromTime / toTime;
        if ((progress * 100) > 100)
        {
            progress = 1.0f;
        }
        return progress;
    }
    else
    {
        return 0.0f;
    }
}

- (void)setProgressColor:(UIColor *)progressColor
{
    progressLayer.strokeColor = progressColor.CGColor;
}

- (void)startAnimation
{
    progressLayer.strokeColor=tintColor.CGColor;
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    pathAnimation.duration = 1.0;
    pathAnimation.fromValue = @(self.initialProgress);
    pathAnimation.toValue = @(self.percent);
    pathAnimation.removedOnCompletion = YES;
    
    [progressLayer addAnimation:pathAnimation forKey:nil];
}

//添加一层半透明灰色的UIview
-(void)addAGrayView:(CGFloat)tableviewHeight
{
    view=[[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    view.backgroundColor=[UIColor colorWithWhite:0.1 alpha:0.5];
    [self.view.window addSubview:view];
    
    [modelButtonArray removeAllObjects];
    
    tableView=[[UITableView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/10, SCREEN_HEIGHT*3/8, SCREEN_WIDTH*4/5, tableviewHeight+SCREEN_HEIGHT/20)];
    [tableView.layer setCornerRadius:10.0];
    tableView.backgroundColor=[UIColor whiteColor];
    tableView.delegate=self;
    tableView.dataSource=self;
    
    [view.window addSubview:tableView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handletapPressGestures:)];
    [view addGestureRecognizer:tapGesture];
}

//点击弹出view之外的地方清楚弹出的view
-(void)handletapPressGestures:(UITapGestureRecognizer*)sender
{
    CGPoint point = [sender locationInView:view];
    if (point.x<tableView.frame.origin.x || point.x >tableView.frame.origin.x+tableView.frame.size.width || point.y<tableView.frame.origin.y || point.y>tableView.frame.origin.y+tableView.frame.size.height)
    {
        [tableView removeFromSuperview];
        [view removeFromSuperview];
    }
}

//实现刺激模式选择
-(void)chooseModel:(UIButton *)sender
{
    if (sender.tag==1)
    {
        [self addAGrayView:120];
    }
    else if (sender.tag==2)
    {
        //提示刺激过程中不可被点击
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"请先停止疗疗" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismissAtCES:) userInfo:nil repeats:NO];
        [alert show];
    }
    else if (sender.tag==3)
    {
        //提示刺激过程中不可被点击
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"请先连接疗疗" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismissAtCES:) userInfo:nil repeats:NO];
        [alert show];
    }
}

//圆形操作按钮点击事件（绑定疗疗、开始点刺激、停止等等）
-(void)optionButtonClick:(UIButton *)sender
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doSomething:) object:sender];
    [self performSelector:@selector(doSomething:) withObject:sender afterDelay:0.5f];
}
-(void)anotherOptionButtonClick:(UIButton *)sender
{
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(doSomething:) object:sender];
    [self performSelector:@selector(doSomething:) withObject:sender afterDelay:0.5];
}
-(void)doSomething:(UIButton *)sender
{
    if (autoDisconnectTimer!=nil)
    {
        [autoDisconnectTimer invalidate];
        countSeconds=0;
        autoDisconnectTimer=nil;
    }
    
    if ([bleState isEqualToString:@"PoweredOff"])
    {
        //提示蓝牙未开启
        alert = [[UIAlertView alloc] initWithTitle:nil message:@"蓝牙未打开" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismissAtCES:) userInfo:nil repeats:NO];
        [alert show];
    }
    else
    {
        if (sender.tag==0)
        {
            BindViewController *bindViewController=[[BindViewController alloc] initWithNibName:@"BindViewController" bundle:nil];
            bindViewController.bindFlag=@"1";
            [self.delegate alertBackTitle:@"绑定疗疗"];
            [self.navigationController pushViewController:bindViewController animated:YES];
        }
        else if (sender.tag==1)
        {
            countElectric=0;
            countElectric_Two=0;
            [self sendElectricQuantity];
            [self sendElectricRegulateOrder];
        }
        else if (sender.tag==11)
        {
            sender.userInteractionEnabled=NO;
            [optionButton setTitle:@"" forState:UIControlStateNormal];
            if (_discoveredPeripheral!=nil)
            {
                self.centralMgr=nil;
                self.centralMgr=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
            }
            
            connectIng=[UIButton buttonWithType:UIButtonTypeSystem];
            [connectIng setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
            connectIng.frame=optionButton.frame;
            [connectIng setTitle:@"正在连接..." forState:UIControlStateNormal];
            if (SCREEN_WIDTH==320)
            {
                connectIng.titleLabel.font=[UIFont systemFontOfSize:20];
            }
            else if (SCREEN_WIDTH==375)
            {
                connectIng.titleLabel.font=[UIFont systemFontOfSize:22.5];
            }
            else
            {
                connectIng.titleLabel.font=[UIFont systemFontOfSize:25];
            }
            [self.view addSubview:connectIng];
        }
        else
        {
            [self sendStopOrder];
        }
    }
}

-(void)sendSetTimeAndFrequencyOrder
{
    NSString *strFrequency=[NSString string];
    NSString *strTime=[NSString string];
    NSString *strVerify=[NSString string];
    if (modelIndex==0)
    {
        strFrequency=@"00";
        if (timeIndex==0)
        {
            strTime=@"0A";
            strVerify=@"96";
        }
        else if (timeIndex==1)
        {
            strTime=@"14";
            strVerify=@"A0";
        }
        else if (timeIndex==2)
        {
            strTime=@"28";
            strVerify=@"B4";
        }
        else if (timeIndex==3)
        {
            strTime=@"3C";
            strVerify=@"C8";
        }
    }
    else if (modelIndex==1)
    {
        strFrequency=@"01";
        if (timeIndex==0)
        {
            strTime=@"0A";
            strVerify=@"97";
        }
        else if (timeIndex==1)
        {
            strTime=@"14";
            strVerify=@"A1";
        }
        else if (timeIndex==2)
        {
            strTime=@"28";
            strVerify=@"B5";
        }
        else if (timeIndex==3)
        {
            strTime=@"3C";
            strVerify=@"C9";
        }
    }
    else if (modelIndex==2)
    {
        strFrequency=@"02";
        if (timeIndex==0)
        {
            strTime=@"0A";
            strVerify=@"98";
        }
        else if (timeIndex==1)
        {
            strTime=@"14";
            strVerify=@"A2";
        }
        else if (timeIndex==2)
        {
            strTime=@"28";
            strVerify=@"B6";
        }
        else if (timeIndex==3)
        {
            strTime=@"3C";
            strVerify=@"CA";
        }
    }
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            characteristicUUID=characteristic;
            order=[NSString stringWithFormat:@"55AA030882%@%@%@",strTime,strFrequency,strVerify];
            NSData *dataToWrite=[self dataWithHexstring:order];
            [_discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
}

-(void)sendElectricSetOrder
{
    NSString *strElectric=[NSString string];
    NSString *strElectricVerify=[NSString string];
    if (electricCurrentNum==0)
    {
        strElectric=@"00";
        strElectricVerify=@"8E";
    }
    else if (electricCurrentNum==1)
    {
        strElectric=@"01";
        strElectricVerify=@"8F";
    }
    else if (electricCurrentNum==2)
    {
        strElectric=@"02";
        strElectricVerify=@"90";
    }
    else if (electricCurrentNum==3)
    {
        strElectric=@"03";
        strElectricVerify=@"91";
    }
    else if (electricCurrentNum==4)
    {
        strElectric=@"04";
        strElectricVerify=@"92";
    }
    else if (electricCurrentNum==5)
    {
        strElectric=@"05";
        strElectricVerify=@"93";
    }
    else if (electricCurrentNum==6)
    {
        strElectric=@"06";
        strElectricVerify=@"94";
    }
    else if (electricCurrentNum==7)
    {
        strElectric=@"07";
        strElectricVerify=@"95";
    }
    else if (electricCurrentNum==8)
    {
        strElectric=@"08";
        strElectricVerify=@"96";
    }
    else if (electricCurrentNum==9)
    {
        strElectric=@"09";
        strElectricVerify=@"97";
    }
    else if (electricCurrentNum==10)
    {
        strElectric=@"0A";
        strElectricVerify=@"98";
    }else if (electricCurrentNum==11)
    {
        strElectric=@"0B";
        strElectricVerify=@"99";
    }
    else if (electricCurrentNum==12)
    {
        strElectric=@"0C";
        strElectricVerify=@"9A";
    }
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            order=[NSString stringWithFormat:@"55AA030785%@%@",strElectric,strElectricVerify];
            NSData *dataToWriteSet=[self dataWithHexstring:order];
            [_discoveredPeripheral writeValue:dataToWriteSet forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
}

-(void)sendElectricRegulateOrder
{
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            characteristicUUID=characteristic;
            order=@"55AA030781028C";
            NSData *dataToWriteRegulate=[self dataWithHexstring:order];
            [_discoveredPeripheral writeValue:dataToWriteRegulate forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
}

-(void)sendStartWork
{
    countAlert=0;
    num=0;
    if (timeout==time)
    {
        for (CBCharacteristic *characteristic in characteristicArray)
        {
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
            {
                characteristicUUID=characteristic;
                order=@"55AA030781038D";
                NSData *dataToWrite=[self dataWithHexstring:order];
                [_discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
            }
        }
        BegainDate=[NSDate date];
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        BegainTime=[dateFormatter stringFromDate:[NSDate date]];
        
        //设置圆形进度条的进度填充颜色
        tintColor = [UIColor colorWithRed:0.86f green:0.86f blue:0.86f alpha:0.4f];
        _elapsedTime = 0;
        
        [self startTimer];
        
        queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
        dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
        dispatch_source_set_event_handler(_timer, ^{
            
            if ([connectedStateText isEqualToString:@"连通"])
            {
                countAlert=0;
                NSLog(@"%d",timeout);
                [optionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
                if(timeout<=0)
                {
                    //倒计时结束，关闭
                    [self sendStopOrder];
                }
                else if (timeout%60==0)
                {
                    if (timeout==time-60)
                    {
                        //存储治疗数据到数据库
                        //初始化数据库
                        dbOpration=[[DataBaseOpration alloc] init];
                        if (_patientInfo.PatientID!=nil)
                        {
                            TreatInfo *treatInfoTmp=[[TreatInfo alloc] init];
                            treatInfoTmp.PatientID=_patientInfo.PatientID;
                            treatInfoTmp.Date=[BegainTime substringWithRange:NSMakeRange(0, 10)];
                            treatInfoTmp.Strength=[NSString stringWithFormat:@"%ld",(long)electricCurrentNum];
                            if (modelIndex==0)
                            {
                                treatInfoTmp.Frequency=@"1";
                            }
                            else if (modelIndex==1)
                            {
                                treatInfoTmp.Frequency=@"2";
                            }
                            else if (modelIndex==2)
                            {
                                treatInfoTmp.Frequency=@"3";
                            }
                            if (timeIndex==0)
                            {
                                treatInfoTmp.Time=@"600";
                            }
                            else if (timeIndex==1)
                            {
                                treatInfoTmp.Time=@"1200";
                            }
                            else if (timeIndex==2)
                            {
                                treatInfoTmp.Time=@"2400";
                            }
                            else if (timeIndex==3)
                            {
                                treatInfoTmp.Time=@"3600";
                            }
                            treatInfoTmp.BeginTime=BegainTime;
                            treatInfoTmp.EndTime=BegainTime;
                            treatInfoTmp.CureTime=@"1";
                            
                            //插入CureTime为1的数据进入数据库
                            [dbOpration insertTreatInfo:treatInfoTmp];
                            [dbOpration closeDataBase];
                        }
                        minutes = timeout/60;
                        seconds = timeout%60;
                        NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
                        //设置界面的按钮显示 根据自己需求设置
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (SCREEN_WIDTH==320)
                            {
                                optionButton.titleLabel.font=[UIFont systemFontOfSize:28.5];
                                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
                            }
                            else if (SCREEN_WIDTH==375)
                            {
                                optionButton.titleLabel.font=[UIFont systemFontOfSize:31];
                                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
                            }
                            else
                            {
                                optionButton.titleLabel.font=[UIFont systemFontOfSize:33.5];
                                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
                            }
                            //设置界面的按钮显示 根据自己需求设置
                            optionButton.titleLabel.text=str;
                            [optionButton setTitle:str forState:UIControlStateNormal];
                            [anotherOptionButton setTitle:@"停止" forState:UIControlStateNormal];
                        });
                        timeout--;
                    }
                    else
                    {
                        if (_patientInfo.PatientID!=nil)
                        {
                            //更新治疗数据到数据库
                            //初始化数据库
                            dbOpration=[[DataBaseOpration alloc] init];
                            TreatInfo *treatInfoTmp=[[TreatInfo alloc] init];
                            treatInfoTmp.PatientID=_patientInfo.PatientID;
                            treatInfoTmp.Date=[BegainTime substringWithRange:NSMakeRange(0, 10)];
                            treatInfoTmp.Strength=[NSString stringWithFormat:@"%ld",(long)electricCurrentNum];;
                            if (modelIndex==0)
                            {
                                treatInfoTmp.Frequency=@"1";
                            }
                            else if (modelIndex==1)
                            {
                                treatInfoTmp.Frequency=@"2";
                            }
                            else if (modelIndex==2)
                            {
                                treatInfoTmp.Frequency=@"3";
                            }
                            if (timeIndex==0)
                            {
                                treatInfoTmp.Time=@"600";
                            }
                            else if (timeIndex==1)
                            {
                                treatInfoTmp.Time=@"1200";
                            }
                            else if (timeIndex==2)
                            {
                                treatInfoTmp.Time=@"2400";
                            }
                            else if (timeIndex==3)
                            {
                                treatInfoTmp.Time=@"3600";
                            }
                            treatInfoTmp.BeginTime=BegainTime;
                            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                            [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
                            EndTime=[dateFormatter stringFromDate:[NSDate date]];
                            treatInfoTmp.EndTime=EndTime;
                            treatInfoTmp.CureTime=[NSString stringWithFormat:@"%d",(time-timeout)/60];
                            //更新数据
                            if (![treatInfoTmp.CureTime isEqualToString:@"0"])
                            {
                                [dbOpration updateTreatInfo:treatInfoTmp];
                                [dbOpration closeDataBase];
                            }
                        }
                        minutes = timeout/60;
                        seconds = timeout%60;
                        NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
                        //设置界面的按钮显示 根据自己需求设置
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (SCREEN_WIDTH==320)
                            {
                                optionButton.titleLabel.font=[UIFont systemFontOfSize:28.5];
                                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
                            }
                            else if (SCREEN_WIDTH==375)
                            {
                                optionButton.titleLabel.font=[UIFont systemFontOfSize:31];
                                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
                            }
                            else
                            {
                                optionButton.titleLabel.font=[UIFont systemFontOfSize:33.5];
                                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
                            }
                            //设置界面的按钮显示 根据自己需求设置
                            optionButton.titleLabel.text=str;
                            [optionButton setTitle:str forState:UIControlStateNormal];
                            [anotherOptionButton setTitle:@"停止" forState:UIControlStateNormal];
                        });
                        timeout--;
                    }
                }
                else
                {
                    minutes = timeout/60;
                    seconds = timeout%60;
                    NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
                    //设置界面的按钮显示 根据自己需求设置
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (SCREEN_WIDTH==320)
                        {
                            optionButton.titleLabel.font=[UIFont systemFontOfSize:28.5];
                            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
                        }
                        else if (SCREEN_WIDTH==375)
                        {
                            optionButton.titleLabel.font=[UIFont systemFontOfSize:31];
                            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
                        }
                        else
                        {
                            optionButton.titleLabel.font=[UIFont systemFontOfSize:33.5];
                            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
                        }
                        //设置界面的按钮显示 根据自己需求设置
                        optionButton.titleLabel.text=str;
                        [optionButton setTitle:str forState:UIControlStateNormal];
                        [anotherOptionButton setTitle:@"停止" forState:UIControlStateNormal];
                    });
                    timeout--;
                }
            }
            else
            {
                if (![optionButton.titleLabel.text isEqualToString:@"未连接疗疗"] || ![optionButton.titleLabel.text isEqualToString:@"未绑定疗疗"])
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (countAlert%2==0 && countAlert>=3)
                        {
                            [optionButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
                        }
                        else if (countAlert%2==1)
                        {
                            [optionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
                        }
                        countAlert++;
                    });
                }
            }
        });
        dispatch_resume(_timer);
    }
//    optionButton.userInteractionEnabled=YES;
//    anotherOptionButton.userInteractionEnabled=YES;
}

-(void)sendStopOrder
{
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            characteristicUUID=characteristic;
            NSString *str=@"55AA030781008A";
            NSData *dataToWrite=[self dataWithHexstring:str];
            [_discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
    
    //停止时进度条归零
    progressLayer.strokeColor = [UIColor clearColor].CGColor;
    _elapsedTime = 0;
    
    //存储治疗数据到数据库
    if (_patientInfo!=nil && time-timeout>=60)
    {
        dbOpration=[[DataBaseOpration alloc] init];
        TreatInfo *treatInfoTmp=[[TreatInfo alloc] init];
        treatInfoTmp.PatientID=_patientInfo.PatientID;
        treatInfoTmp.Date=[BegainTime substringWithRange:NSMakeRange(0, 10)];
        treatInfoTmp.Strength=[NSString stringWithFormat:@"%ld",(long)electricCurrentNum];
        if (modelIndex==0)
        {
            treatInfoTmp.Frequency=@"1";
        }
        else if (modelIndex==1)
        {
            treatInfoTmp.Frequency=@"2";
        }
        else if (modelIndex==2)
        {
            treatInfoTmp.Frequency=@"3";
        }
        if (timeIndex==0)
        {
            treatInfoTmp.Time=@"600";
        }
        else if (timeIndex==1)
        {
            treatInfoTmp.Time=@"1200";
        }
        else if (timeIndex==2)
        {
            treatInfoTmp.Time=@"2400";
        }
        else if (timeIndex==3)
        {
            treatInfoTmp.Time=@"3600";
        }
        treatInfoTmp.BeginTime=BegainTime;
        NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        EndTime=[dateFormatter stringFromDate:[NSDate date]];
        treatInfoTmp.EndTime=EndTime;
        treatInfoTmp.CureTime=[NSString stringWithFormat:@"%d",(time-timeout)/60];
        //更新数据
        [dbOpration updateTreatInfo:treatInfoTmp];
        [dbOpration closeDataBase];
    }
    
    //倒计时结束，关闭
    dispatch_source_set_event_handler(_timer, ^{
        dispatch_source_cancel(_timer);
    });
    timeout=time;
    dispatch_async(dispatch_get_main_queue(), ^{
        [optionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
        //设置界面的按钮显示 根据自己需求设置
        minutes = time/60;
        seconds = time%60;
        NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
        if (_discoveredPeripheral!=nil)
        {
            optionButton.titleLabel.text=str;
            [optionButton setTitle:str forState:UIControlStateNormal];
            [anotherOptionButton setTitle:@"开始" forState:UIControlStateNormal];
        }
        else
        {
            [optionButton setTitle:@"未绑定疗疗" forState:UIControlStateNormal];
            [anotherOptionButton setTitle:@" " forState:UIControlStateNormal];
            optionButton.tag=0;
            anotherOptionButton.tag=0;
        }
        //设置一分钟之后如果不进行操作直接断开蓝牙外设
        autoDisconnectTimer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(cancelBlutooth:) userInfo:nil repeats:YES];
        optionButtonState=@"00:20:00";
    });
    optionButton.tag=1;
    optionButton.userInteractionEnabled=YES;
    anotherOptionButton.tag=1;
    anotherOptionButton.userInteractionEnabled=YES;
    modelButton.tag=1;
}
//发送电量命令
-(void)sendElectricQuantity
{
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            characteristicUUID=characteristic;
            order=@"55AA02060108";
            NSData *dataToWrite=[self dataWithHexstring:order];
            [_discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
}

-(void)cancelBlutooth:(NSTimer *)timer
{
    countSeconds++;
    NSLog(@"%d",countSeconds);
    if (countSeconds>=120)
    {
        NSLog(@"%@...%@",optionButtonState,optionButton.titleLabel.text);
        if ([optionButton.titleLabel.text isEqualToString:optionButtonState])
        {
            if (_timer!=nil)
            {
                dispatch_source_set_event_handler(_timer, ^{
                    dispatch_source_cancel(_timer);
                });
            }
            [self.centralMgr cancelPeripheralConnection:_discoveredPeripheral];
            if (SCREEN_WIDTH==320)
            {
                optionButton.titleLabel.font=[UIFont systemFontOfSize:20];
                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
            }
            else if (SCREEN_WIDTH==375)
            {
                optionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
            }
            else
            {
                optionButton.titleLabel.font=[UIFont systemFontOfSize:25];
                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
            }
            [optionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
            [optionButton setTitle:@"未连接疗疗" forState:UIControlStateNormal];
            [anotherOptionButton setTitle:@" " forState:UIControlStateNormal];
            optionButton.tag=11;
            anotherOptionButton.tag=11;
            modelButton.tag=3;
            for (UIButton *tmp in electricCurrentButtonArray)
            {
                tmp.btnFlag=@"00";
            }
            
            //初始化电量提示信息的次数全局变量
            countElectric=0;
            countElectric_Two=0;
            countElectricQuality=0;
            //结束阻抗检测以及读取电量的线程
            if (checkElectric!=nil)
            {
                [checkElectric invalidate];
                checkElectric=nil;
            }
            if (readElectricQuality!=nil)
            {
                [readElectricQuality invalidate];
                readElectricQuality=nil;
            }
            
            if (autoDisconnectTimer!=nil)
            {
                [autoDisconnectTimer invalidate];
                countSeconds=0;
                autoDisconnectTimer=nil;
            }
            
            //设置代理传值(电量)
            [self.delegate sendElectricQualityValue:@"未连接疗疗"];
        }
        [timer invalidate];
    }
}

//切换用户，释放蓝牙绑定信息
-(void)changeUser
{
    if (_timer!=nil && timeout!=time)
    {
        [self sendStopOrder];
    }
    if (_discoveredPeripheral.state==CBPeripheralStateConnected)
    {
        [_centralMgr cancelPeripheralConnection:_discoveredPeripheral];
    }
    self.discoveredPeripheral=nil;
    self.bluetoothInfo=nil;
    
    if (autoDisconnectTimer!=nil)
    {
        [autoDisconnectTimer invalidate];
        countSeconds=0;
        autoDisconnectTimer=nil;
    }
}

//清除蓝牙的相关的信息
-(void)freeBluetoothInfo
{
    if (_timer!=nil && timeout!=time)
    {
        [self sendStopOrder];
    }
    if (_discoveredPeripheral.state==CBPeripheralStateConnected)
    {
        [_centralMgr cancelPeripheralConnection:_discoveredPeripheral];
    }
    self.discoveredPeripheral=nil;
    self.bluetoothInfo=nil;
    
//    if (optionButton.userInteractionEnabled==NO || anotherOptionButton.userInteractionEnabled==NO)
//    {
//        optionButton.userInteractionEnabled=YES;
//        anotherOptionButton.userInteractionEnabled=YES;
//    }
    if (SCREEN_WIDTH==320)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:20];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==375)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
    }
    else
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:25];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
    }
    [optionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
    [optionButton setTitle:@"未绑定疗疗" forState:UIControlStateNormal];
    [anotherOptionButton setTitle:@" " forState:UIControlStateNormal];
    
    if (autoDisconnectTimer!=nil)
    {
        [autoDisconnectTimer invalidate];
        countSeconds=0;
        autoDisconnectTimer=nil;
    }
    
    //删除“正在连接...”按钮
    [connectIng removeFromSuperview];
//    optionButton.userInteractionEnabled=YES;
//    anotherOptionButton.userInteractionEnabled=YES;
    if (_timer!=nil)
    {
        dispatch_source_cancel(_timer);
    }
    optionButton.tag=0;
    anotherOptionButton.tag=0;
    modelButton.tag=3;
    for (UIButton *tmp in electricCurrentButtonArray)
    {
        tmp.btnFlag=@"00";
    }
    
    //初始化电量提示信息的次数全局变量
    countElectric=0;
    countElectric_Two=0;
    countElectricQuality=0;
    deviceInfo=0;
    //结束阻抗检测以及读取电量的线程
    if (checkElectric!=nil)
    {
        [checkElectric invalidate];
        checkElectric=nil;
    }
    if (readElectricQuality!=nil)
    {
        [readElectricQuality invalidate];
        readElectricQuality=nil;
    }
}

//实现通知传值
-(void)sendBluetoothInfoValue:(NSNotification *)bluetoothInfo
{
    self.centralMgr=[bluetoothInfo.userInfo objectForKey:@"CBCentralManager"];
    self.BLEinfo=[bluetoothInfo.userInfo objectForKey:@"BLEInfo"];
    
    [_centralMgr setDelegate:self];
    if (_bluetoothInfo==nil)
    {
        _bluetoothInfo=[[BluetoothInfo alloc] init];
        _discoveredPeripheral=_BLEinfo.discoveredPeripheral;
        _bluetoothInfo.peripheralIdentify=_discoveredPeripheral.identifier.UUIDString;
    }
    _bluetoothInfo.saveId=@"1";
    if (_discoveredPeripheral)
    {
        //连接设备
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
        [_centralMgr stopScan];
        //阻抗检测
        checkElectric=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(impedancePerseconds) userInfo:nil repeats:YES];
        //读取电量
        readElectricQuality=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendElectricQuantity) userInfo:nil repeats:YES];
//        //读取序列号
//        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(sendGetDeviceInfo) userInfo:nil repeats:NO];
    }
    
    _arrayServices = [[NSMutableArray alloc] init];
    
    characteristicUUID=[CBCharacteristic new];
    characteristicArray=[[NSMutableArray alloc] init];
    _characteristicNum = 0;
    
    optionButton.tag=1;
    anotherOptionButton.tag=1;
    modelButton.tag=1;
    minutes = time/60;
    seconds = time%60;
    NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
    if (SCREEN_WIDTH==320)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:28.5];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==375)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:31];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
    }
    else
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:33.5];
        anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
    }
    optionButton.titleLabel.numberOfLines=0;
    optionButton.titleLabel.textAlignment=NSTextAlignmentCenter;
    optionButton.titleLabel.text=str;
    [optionButton setTitle:str forState:UIControlStateNormal];
    [anotherOptionButton setTitle:@"开始" forState:UIControlStateNormal];
}

-(void)sendGetDeviceInfo
{
    for (int i=0; i<2; i++)
    {
        for (CBCharacteristic *characteristic in characteristicArray)
        {
            if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
            {
                characteristicUUID=characteristic;
                NSString *str=@"55AA0306878F";
                NSData *dataToWrite=[self dataWithHexstring:str];
                [_discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
            }
        }
    }
}

-(void)sendGetDeviceInfo_
{
    for (CBCharacteristic *characteristic in characteristicArray)
    {
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:@"0A66"]])
        {
            characteristicUUID=characteristic;
            NSString *str=@"55AA0306878F";
            NSData *dataToWrite=[self dataWithHexstring:str];
            [_discoveredPeripheral writeValue:dataToWrite forCharacteristic:characteristicUUID type:CBCharacteristicWriteWithResponse];
        }
    }
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if(interfaceOrientation == UIDeviceOrientationPortrait || interfaceOrientation == UIDeviceOrientationPortraitUpsideDown)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStateUnknown:
            NSLog(@">>>CBCentralManagerStateUnknown");
            break;
        case CBCentralManagerStateResetting:
            NSLog(@">>>CBCentralManagerStateResetting");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@">>>CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnauthorized:
            NSLog(@">>>CBCentralManagerStateUnauthorized");
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@">>>CBCentralManagerStatePoweredOff");
            bleState=@"PoweredOff";
            connectedStateText=@"未连通";
            count++;
            if (count==1)
            {
                self.centralMgr=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
            }
            //还需要对刺激开始按钮复位
            
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            bleState=@"PoweredOn";
            [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
            count=0;
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    //如果发现绑定的外设直接连接
    if ([peripheral.identifier.UUIDString isEqualToString:_bluetoothInfo.peripheralIdentify])
    {
        //删除“正在连接...”按钮
        [connectIng removeFromSuperview];
        optionButton.userInteractionEnabled=YES;
        anotherOptionButton.userInteractionEnabled=YES;
        
        _discoveredPeripheral=peripheral;
        [_centralMgr connectPeripheral:_discoveredPeripheral options:nil];
        [_centralMgr stopScan];
        //阻抗检测
        checkElectric=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(impedancePerseconds) userInfo:nil repeats:YES];
        //读取电量
        readElectricQuality=[NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(sendElectricQuantity) userInfo:nil repeats:YES];
        
        _arrayServices = [[NSMutableArray alloc] init];
        
        characteristicUUID=[CBCharacteristic new];
        characteristicArray=[[NSMutableArray alloc] init];
        _characteristicNum = 0;
        
        if (_timer!=nil)
        {
            timeout=time;
            dispatch_source_set_event_handler(_timer, ^{
                dispatch_source_cancel(_timer);
            });
        }
        optionButton.tag=1;
        anotherOptionButton.tag=1;
        modelButton.tag=1;
        minutes = time/60;
        seconds = time%60;
        NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
        optionButton.titleLabel.numberOfLines=0;
        optionButton.titleLabel.textAlignment=NSTextAlignmentCenter;
        optionButton.titleLabel.text=str;
        [optionButton setTitle:str forState:UIControlStateNormal];
        [anotherOptionButton setTitle:@"开始" forState:UIControlStateNormal];
        if (SCREEN_WIDTH==320)
        {
            optionButton.titleLabel.font=[UIFont systemFontOfSize:28.5];
            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
        }
        else if (SCREEN_WIDTH==375)
        {
            optionButton.titleLabel.font=[UIFont systemFontOfSize:31];
            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
        }
        else
        {
            optionButton.titleLabel.font=[UIFont systemFontOfSize:33.5];
            anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
        }
        
        progressLayer.strokeColor = [UIColor clearColor].CGColor;
        _elapsedTime = 0;
    }
    else
    {
        if (_bluetoothInfo!=nil)
        {
            optionButton.tag=11;
            anotherOptionButton.tag=11;
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"didFailToConnectPeripheral : %@", error.localizedDescription);
    NSLog(@"设备已被连接");
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    
    [self.arrayServices removeAllObjects];
    
    [_discoveredPeripheral setDelegate:self];
    
    [_discoveredPeripheral discoverServices:nil];
    
    //蓝牙已连接成功，设置 电流强度按钮、频率、时间以及绑定开始按钮 可与用户交互
    for (UIButton *tmp in electricCurrentButtonArray)
    {
        tmp.btnFlag=@"11";
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    NSLog(@"蓝牙外设断开连接");
    //倒计时结束，关闭
    if (_timer!=nil)
    {
        dispatch_source_set_event_handler(_timer, ^{
            dispatch_source_cancel(_timer);
        });
        timeout=time;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![optionButton.titleLabel.text isEqualToString:@"未连接疗疗"] && ![optionButton.titleLabel.text isEqualToString:@"未绑定疗疗"])
        {
            [optionButton setTitleColor:[UIColor colorWithRed:10/255.0 green:96/255.0 blue:254/255.0 alpha:1] forState:UIControlStateNormal];
            if (_timer!=nil)
            {
                dispatch_source_cancel(_timer);
            }
            if (SCREEN_WIDTH==320)
            {
                optionButton.titleLabel.font=[UIFont systemFontOfSize:20];
                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:20];
            }
            else if (SCREEN_WIDTH==375)
            {
                optionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
            }
            else
            {
                optionButton.titleLabel.font=[UIFont systemFontOfSize:25];
                anotherOptionButton.titleLabel.font=[UIFont systemFontOfSize:25];
            }
            if (_bluetoothInfo.peripheralIdentify!=nil)
            {
                [optionButton setTitle:@"未连接疗疗" forState:UIControlStateNormal];
                optionButton.tag=11;
                anotherOptionButton.tag=11;
            }
            else
            {
                [optionButton setTitle:@"未绑定疗疗" forState:UIControlStateNormal];
                optionButton.tag=0;
                anotherOptionButton.tag=0;
            }
            [anotherOptionButton setTitle:@" " forState:UIControlStateNormal];
            
            if (autoDisconnectTimer!=nil)
            {
                [autoDisconnectTimer invalidate];
                countSeconds=0;
                autoDisconnectTimer=nil;
            }
            
            //删除“正在连接...”按钮
            if ([connectIng.titleLabel.text isEqualToString:@"正在连接..."])
            {
                [connectIng removeFromSuperview];
//                optionButton.userInteractionEnabled=YES;
//                anotherOptionButton.userInteractionEnabled=YES;
            }
            modelButton.tag=3;
            for (UIButton *tmp in electricCurrentButtonArray)
            {
                tmp.btnFlag=@"00";
            }
            
            //初始化电量提示信息的次数全局变量
            countElectric=0;
            countElectric_Two=0;
            countElectricQuality=0;
            //结束阻抗检测以及读取电量的线程
            if (checkElectric!=nil)
            {
                [checkElectric invalidate];
                checkElectric=nil;
            }
            if (readElectricQuality!=nil)
            {
                [readElectricQuality invalidate];
                readElectricQuality=nil;
            }
        }
    });
}

//获取服务
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error)
    {
        NSLog(@"didDiscoverServices : %@", [error localizedDescription]);
        return;
    }
    
    for (CBService *s in peripheral.services)
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:@{peripheral.name:s.UUID.description}];
        [self.arrayServices addObject:dic];
        [s.peripheral discoverCharacteristics:nil forService:s];
    }
}

//获取特性
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *c in service.characteristics)
    {
        self.characteristicNum++;
        [peripheral readValueForCharacteristic:c];
        [characteristicArray addObject:c];
        [peripheral setNotifyValue:YES forCharacteristic:c];
    }
    
    if (countElectricQuality<1)
    {
        //        [self sendElectricQuantity];
        //        [self sendGetDeviceInfo];
        [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(sendGetDeviceInfo) userInfo:nil repeats:NO];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(sendElectricQuantity) userInfo:nil repeats:NO];
        [self sendElectricRegulateOrder];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSData* data = characteristic.value;
    value =[self hexadecimalString:data];
    
    if ([value containsString:@"55bb010b84"])
    {
        [stringArray removeAllObjects];
        
        for (int i=1; i<=value.length/2; i++)
        {
            NSString *str=[value substringWithRange:NSMakeRange(2*(i-1), 2)];
            [stringArray addObject:str];
        }
        if ([[stringArray objectAtIndex:8] isEqualToString:@"00"])
        {
            connectedStateText=@"未连通";
        }
        else if([[stringArray objectAtIndex:8] isEqualToString:@"01"])
        {
            connectedStateText=@"连通";
        }
    }
    if ([value containsString:@"55bb011387"] && [[value substringWithRange:NSMakeRange(34, 2)] isEqualToString:@"00"])
    {
        if (deviceInfo>=1)
        {
            return;
        }
        
        char myChar[8];
        for (int i=0; i<8; i++)
        {
            NSString *tmp=[value substringWithRange:NSMakeRange(18+2*i, 2)];
            unsigned int anInt;
            NSScanner * scanner = [[NSScanner alloc] initWithString:tmp];
            [scanner scanHexInt:&anInt];
            myChar[i]=anInt;
        }
        [self Deciphering:myChar];
        
        //发送序列号接口
        NSMutableArray *deviceIDArray=[NSMutableArray array];
        NSString *hexStr=@"";
        for(int i=0;i<6;i++)
        {
            NSString *newHexStr = [NSString stringWithFormat:@"%x",chOUTFinal[i]&0xff];///16进制数
            if([newHexStr length]==1)
            {
                hexStr = [NSString stringWithFormat:@"0%@",newHexStr];
            }
            else 
            {
                hexStr = [NSString stringWithFormat:@"%@",newHexStr];
            }
            [deviceIDArray addObject:hexStr];
        }
        
        NSString *deviceID=[NSString stringWithFormat:@"%@-%@%@-%@%@%@",[deviceIDArray objectAtIndex:0],[deviceIDArray objectAtIndex:1],[deviceIDArray objectAtIndex:2],[deviceIDArray objectAtIndex:3],[deviceIDArray objectAtIndex:4],[deviceIDArray objectAtIndex:5]];
        NSDictionary *jsonUserID = [NSDictionary dictionaryWithObjectsAndKeys:_patientInfo.PatientID,@"PatientID",deviceID,@"DeviceID",nil];
        NSArray *jsonArray=[NSArray arrayWithObjects:jsonUserID, nil];
        NSData *jsondata = [NSJSONSerialization dataWithJSONObject:jsonArray options:NSJSONWritingPrettyPrinted error:nil];
        NSString *jsonString=[[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    
        // 设置我们之后解析XML时用的关键字
        matchingElement = @"APP_SetPatientDeviceIDResponse";
        // 创建SOAP消息，内容格式就是网站上提示的请求报文的实体主体部分
        NSString *soapMsg = [NSString stringWithFormat:
                             @"<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                             "<soap12:Envelope "
                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" "
                             "xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" "
                             "xmlns:soap12=\"http://schemas.xmlsoap.org/soap/envelope/\">"
                             "<soap12:Body>"
                             "<APP_SetPatientDeviceID xmlns=\"MeetingOnline\">"
                             "<JsonDeviceInfo>%@</JsonDeviceInfo>"
                             "</APP_SetPatientDeviceID>"
                             "</soap12:Body>"
                             "</soap12:Envelope>", jsonString,nil];
        //打印soapMsg信息
        NSLog(@"%@",soapMsg);
        
        //设置网络连接的url
        NSString *urlStr = [NSString stringWithFormat:@"%@",ADDRESS];
        NSURL *url = [NSURL URLWithString:urlStr];
        //设置request
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        NSString *msgLength=[NSString stringWithFormat:@"%lu",(long)[soapMsg length]];
        // 添加请求的详细信息，与请求报文前半部分的各字段对应
        [request addValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request addValue:msgLength forHTTPHeaderField:@"Content-Length"];
        // 设置请求行方法为POST，与请求报文第一行对应
        [request setHTTPMethod:@"POST"];//默认是GET
        // 将SOAP消息加到请求中
        [request setHTTPBody: [soapMsg dataUsingEncoding:NSUTF8StringEncoding]];
        // 创建连接
        conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if (conn)
        {
            webData = [NSMutableData data];
        }
        
        deviceInfo++;
    }
    if ([value containsString:@"55bb010a"])
    {
        NSLog(@"%@",value);
        //电量提示
        NSString *numberStr_One=[value substringWithRange:NSMakeRange(14, 1)];
        NSString *numberStr_Two=[value substringWithRange:NSMakeRange(15, 1)];
        unichar numberStr=[value characterAtIndex:15];
        if (numberStr>='a' && numberStr<='f')
        {
            numberStr_Two=[NSString stringWithFormat:@"%d",numberStr-87];
        }
        percent=[numberStr_One intValue]*16+[numberStr_Two intValue];
        
        if (percent>5 && percent<=20)
        {
            if (countElectric<1)
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"电池电量小于20%，请及时给设备充电" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismissAtCES:) userInfo:nil repeats:NO];
                [alert show];
                
                countElectric++;
            }
        }
        else if(percent<=5)
        {
            if (countElectric_Two<1)
            {
                alert = [[UIAlertView alloc] initWithTitle:nil message:@"电池电量小于5%，设备无法正常工作，请先充电" delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
                [NSTimer scheduledTimerWithTimeInterval:2.0f target:self selector:@selector(performDismissAtCES:) userInfo:nil repeats:NO];
                [alert show];
                countElectric_Two++;
            }
        }
        //设置代理传值(电量)
        [self.delegate sendElectricQualityValue:value];
    }
    if ([order containsString:@"55AA030781028C"])
    {
        //发送电流调节命令
        [anotherOptionButton setTitle:@"停止" forState:UIControlStateNormal];
//        optionButton.userInteractionEnabled=NO;
//        anotherOptionButton.userInteractionEnabled=NO;
        optionButton.tag=2;
        anotherOptionButton.tag=2;
        modelButton.tag=2;
        
        [self sendSetTimeAndFrequencyOrder];
    }
    if ([order containsString:@"55AA030882"])
    {
        //发送电流设定命令，设置电流强度
        [self sendElectricSetOrder];
    }
    if ([order containsString:@"55AA030785"])
    {
        //发送开始命令，即疗疗正常工作命令
        [self sendStartWork];
    }
}

//获取特性值
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    self.characteristicNum--;
    for (NSMutableDictionary *dic in self.arrayServices)
    {
        NSString *service = [dic valueForKey:peripheral.name];
        if ([service isEqual:characteristic.service.UUID.description])
        {
            [dic setValue:characteristic.value forKey:characteristic.UUID.description];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    NSData* data = characteristic.value;
    NSString *valueStr =[self hexadecimalString:data];
    if ([valueStr isEqualToString:@"55bb01079300ab"])
    {
        NSLog(@"接上外接电源蓝牙模块复位功能：%@",valueStr);
    }
    
    [peripheral setNotifyValue:YES forCharacteristic:characteristic];
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error)
    {
        NSLog(@"Error writing characteristic value: %@",[error localizedDescription]);
    }
}

-(void)Deciphering:(char *)chData
{
    char chKey[] = { 0x01, 0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05, 0x01,
        0x09, 0x09, 0x07, 0x03, 0x0B, 0x01, 0x05 };
    char chOUT[16];
    char chC[16];
    
    for (int i = 0; i < 8; i++) {
        chC[2 * i] = (char) (chData[i] >> 4);
        chC[2 * i + 1] = (char) (chData[i] & 0x0f);
    }
    
    for (int k = 0; k < 16; k++) {
        for (int j = 0; j < 16; j++) {
            if ((((j * chKey[k]) - chC[k]) % 16) == 0) {
                chOUT[k] = (char) j;
                j = 15;
            }
        }
    }
    
    for (int g = 0; g < 8; g++)
    {
        chOUTFinal[g] = (char) (((chOUT[2 * g] << 4) & 0xf0) + (chOUT[2 * g + 1] & 0x0f));
    }
}

//将传入的NSData类型转换成NSString并返回
- (NSString*)hexadecimalString:(NSData *)data
{
    NSString* result;
    const unsigned char* dataBuffer = (const unsigned char*)[data bytes];
    if(!dataBuffer){
        return nil;
    }
    NSUInteger dataLength = [data length];
    NSMutableString* hexString = [NSMutableString stringWithCapacity:(dataLength * 2)];
    for(int i = 0; i < dataLength; i++){
        [hexString appendString:[NSString stringWithFormat:@"%02lx", (unsigned long)dataBuffer[i]]];
    }
    result = [NSString stringWithString:hexString];
    return result;
}
//将传入的NSString类型转换成NSData并返回
- (NSData*)dataWithHexstring:(NSString *)hexstring
{
    NSMutableData* data = [NSMutableData data];
    int idx;
    for(idx = 0; idx + 2 <= hexstring.length; idx += 2){
        NSRange range = NSMakeRange(idx, 2);
        NSString* hexStr = [hexstring substringWithRange:range];
        NSScanner* scanner = [NSScanner scannerWithString:hexStr];
        unsigned int intValue;
        [scanner scanHexInt:&intValue];
        [data appendBytes:&intValue length:1];
    }
    return data;
}

//tableView需要实现的代理方法
#pragma mark - UITableViewDelegate,UITableViewDataSource
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *customView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH*4/5, SCREEN_HEIGHT/20)];
    customView.backgroundColor=[UIColor colorWithRed:0xed/255.0 green:0xee/255.0 blue:0xee/255.0 alpha:1];
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.highlightedTextColor = [UIColor whiteColor];
    headerLabel.font = [UIFont boldSystemFontOfSize:20];
    headerLabel.textAlignment=NSTextAlignmentCenter;
    headerLabel.frame =CGRectMake(0, 0, SCREEN_WIDTH*4/5, SCREEN_HEIGHT/20);
    
    headerLabel.text =  @"模式选择";

    [customView addSubview:headerLabel];
    return customView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return SCREEN_HEIGHT/20;
}

//tabeview的代理方法 （如果此方法返回值为0，则后面两个代理方法不执行）
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return modelArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *Identifier = @"Mycell";
    
    UITableViewCell *cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    
    selectButton=[[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/5, 0, 30,40)];
    if (indexPath.row == modelIndex)
    {
        [selectButton setImage:[UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
    }
    else
    {
        [selectButton setImage:[UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
    }
    selectButton.tag=indexPath.row;
    [selectButton addTarget:self action:@selector(selectModel:) forControlEvents:UIControlEventTouchUpInside];
    [modelButtonArray addObject:selectButton];
    
    if([[modelArray objectAtIndex:indexPath.row] isEqualToString:@"1"])
    {
        cell.textLabel.text=@"模式一";
    }
    else if([[modelArray objectAtIndex:indexPath.row] isEqualToString:@"2"])
    {
        cell.textLabel.text=@"模式二";
    }
    else if([[modelArray objectAtIndex:indexPath.row] isEqualToString:@"3"])
    {
        cell.textLabel.text=@"模式三";
    }
    
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
    
    [cell.contentView addSubview:selectButton];
    [cell setSelected:YES animated:YES];
    return cell;

}

-(void)selectModel:(UIButton *)sender
{
    UIButton *tmp0=[modelButtonArray objectAtIndex:0];
    UIButton *tmp1=[modelButtonArray objectAtIndex:1];
    UIButton *tmp2=[modelButtonArray objectAtIndex:2];
    modelIndex=sender.tag;
    timeIndex=1;
    time=1200;
    timeout=1200;
    _timeLimit=time;
    _elapsedTime=0;
    minutes = time/60;
    seconds = time%60;
    NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
    if (SCREEN_WIDTH==320)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:28.5];
    }
    else if (SCREEN_WIDTH==375)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:31];
    }
    else
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:33.5];
    }
    optionButton.titleLabel.text=str;
    [optionButton setTitle:str forState:UIControlStateNormal];
    if (sender.tag==0)
    {
        [tmp0 setImage: [UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
        [tmp1 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp2 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [modelButton setTitle:@"模式一" forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeViews) userInfo:nil repeats:NO];
    }
    else if (sender.tag==1)
    {
        [tmp0 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp1 setImage: [UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
        [tmp2 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [modelButton setTitle:@"模式二" forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeViews) userInfo:nil repeats:NO];
    }
    else if (sender.tag==2)
    {
        [tmp0 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp1 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp2 setImage: [UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
        [modelButton setTitle:@"模式三" forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeViews) userInfo:nil repeats:NO];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIButton *tmp0=[modelButtonArray objectAtIndex:0];
    UIButton *tmp1=[modelButtonArray objectAtIndex:1];
    UIButton *tmp2=[modelButtonArray objectAtIndex:2];
    modelIndex=indexPath.row;
    timeIndex=1;
    time=1200;
    timeout=1200;
    _timeLimit=time;
    _elapsedTime=0;
    minutes = time/60;
    seconds = time%60;
    NSString *str=[NSString stringWithFormat:@"00:%.2d:%.2d",minutes,seconds];
    if (SCREEN_WIDTH==320)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:28.5];
    }
    else if (SCREEN_WIDTH==375)
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:31];
    }
    else
    {
        optionButton.titleLabel.font=[UIFont systemFontOfSize:33.5];
    }
    optionButton.titleLabel.text=str;
    [optionButton setTitle:str forState:UIControlStateNormal];
    if (indexPath.row==0)
    {
        [tmp0 setImage: [UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
        [tmp1 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp2 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [modelButton setTitle:@"模式一" forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeViews) userInfo:nil repeats:NO];
    }
    else if (indexPath.row==1)
    {
        [tmp0 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp1 setImage: [UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
        [tmp2 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [modelButton setTitle:@"模式二" forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeViews) userInfo:nil repeats:NO];
    }
    else if (indexPath.row==2)
    {
        [tmp0 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp1 setImage: [UIImage imageNamed:@"radio_no_checked"] forState:UIControlStateNormal];
        [tmp2 setImage: [UIImage imageNamed:@"radio_is_checked"] forState:UIControlStateNormal];
        [modelButton setTitle:@"模式三" forState:UIControlStateNormal];
        [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(removeViews) userInfo:nil repeats:NO];
    }
}

//点击选中某个cell之后，remove其tableview以及门板view
-(void)removeViews
{
    [tableView removeFromSuperview];
    [view removeFromSuperview];
}

//选择刺激时间活着刺激频率之后 NSTime 调用，把弹出的view以及tableView删掉
- (void) viewDismiss: (NSTimer *)timer
{
    [tableView removeFromSuperview];
    [view removeFromSuperview];
}
//计算两个时间点之间的时间差（即计算治疗时间）
-(void)getCureTime:(NSDate *)EndDate
{
    NSCalendar *cal=[NSCalendar currentCalendar];
    unsigned int unitFlags=NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond;
    NSDateComponents *interval=[cal components:unitFlags fromDate:BegainDate toDate:EndDate options:0];
    NSInteger sec;
    if ([interval second]>=30)
    {
        sec=1;
    }
    else
    {
        sec=0;
    }
    
    CureTime=[NSString stringWithFormat:@"%ld",(long)([interval hour]*60+[interval minute]+sec)];
    if ([CureTime isEqualToString:@"0"])
    {
        CureTime=@"1";
    }
}
//alert定时消失
- (void) performDismissAtCES: (NSTimer *)timer
{
    [alert dismissWithClickedButtonIndex:0 animated:NO];//important
}

#pragma mark -
#pragma mark URL Connection Data Delegate Methods

// 刚开始接受响应时调用
-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *) response
{
    [webData setLength: 0];
}

// 每接收到一部分数据就追加到webData中
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *) data
{
    [webData appendData:data];
}

// 出现错误时
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *) error
{
    conn = nil;
    webData = nil;
}

// 完成接收数据时调用
-(void) connectionDidFinishLoading:(NSURLConnection *) connection
{
    NSString *theXML = [[NSString alloc] initWithBytes:[webData mutableBytes]
                                                length:[webData length]
                                              encoding:NSUTF8StringEncoding];
    
    // 打印出得到的XML
    NSLog(@"%@", theXML);
    // 使用NSXMLParser解析出我们想要的结果
    xmlParser = [[NSXMLParser alloc] initWithData: webData];
    [xmlParser setDelegate: self];
    [xmlParser setShouldResolveExternalEntities: YES];
    [xmlParser parse];
}


#pragma mark -
#pragma mark XML Parser Delegate Methods

// 开始解析一个元素名
-(void) parser:(NSXMLParser *) parser didStartElement:(NSString *) elementName namespaceURI:(NSString *) namespaceURI qualifiedName:(NSString *) qName attributes:(NSDictionary *) attributeDict
{
    if ([elementName isEqualToString:matchingElement])
    {
        if (!soapResults)
        {
            soapResults = [[NSMutableString alloc] init];
        }
        elementFound = YES;
    }
}

// 追加找到的元素值，一个元素值可能要分几次追加
-(void)parser:(NSXMLParser *) parser foundCharacters:(NSString *)string
{
    if (elementFound)
    {
        [soapResults appendString: string];
    }
}

// 结束解析这个元素名
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:matchingElement])
    {
        elementFound = FALSE;
        // 强制放弃解析
        [xmlParser abortParsing];
    }
}

// 解析整个文件结束后
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    if (soapResults)
    {
        soapResults = nil;
    }
}

// 出错时，例如强制结束解析
- (void) parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    if (soapResults)
    {
        soapResults = nil;
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
