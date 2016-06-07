//
//  BindViewController.m
//  iHappySleep
//
//  Created by 诺之家 on 15/10/27.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "BindViewController.h"
#import "myHeader.h"
#import "DataBaseOpration.h"
#import "BluetoothInfo.h"
#import "CESTreatViewController.h"

@interface BindViewController ()

@end

@implementation BindViewController
{
    NSArray *recipes;
    NSInteger num;
    
    UILabel *nameLabel;
    UILabel *UUIDLabel;
    
    DataBaseOpration *dbOpration;
}
@synthesize centralMgr,arrayBLE;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationController.navigationBar.translucent=YES;
    
    //1.创建CBCentralManager
    self.centralMgr=[[CBCentralManager alloc] initWithDelegate:self queue:nil];
    self.arrayBLE=[[NSMutableArray alloc] init];
    
    if (SCREEN_HEIGHT==480)
    {
        self.alertLabel.font=[UIFont systemFontOfSize:12];
    }
    else if (SCREEN_HEIGHT==667)
    {
        self.alertLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==736)
    {
        self.alertLabel.font=[UIFont systemFontOfSize:22.5];
    }
    
    self.alertLabel.text=@"请确认刺激仪蓝牙可见而电流充足，并在手机附近";
    self.alertLabel.numberOfLines=0;
    
    [_scanButton setBackgroundColor:[UIColor colorWithRed:0x25/255.0 green:0x7e/255.0 blue:0xd6/255.0 alpha:1]];
    [self.scanButton setTitle:@"重新搜索" forState:UIControlStateNormal];
    if (SCREEN_HEIGHT==667)
    {
        _scanButton.titleLabel.font=[UIFont systemFontOfSize:20];
    }
    else if (SCREEN_WIDTH==736)
    {
        _scanButton.titleLabel.font=[UIFont systemFontOfSize:22.5];
    }
    
    _scanResultTableView.delegate=self;
    _scanResultTableView.dataSource=self;

    UIImageView *device=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_device"]];
    UIImageView *phone=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_phone"]];
    UIImageView *bind=[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"picture_bind"]];
    if (SCREEN_HEIGHT==480)
    {
        device.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/30+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        phone.frame=CGRectMake(SCREEN_WIDTH*12/20, SCREEN_HEIGHT/30+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        bind.frame=CGRectMake(SCREEN_WIDTH*9/20, SCREEN_HEIGHT/9+65, SCREEN_WIDTH*2/20, SCREEN_WIDTH*3/20);
    }
    else
    {
        device.frame=CGRectMake(SCREEN_WIDTH/20, SCREEN_HEIGHT/10+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        phone.frame=CGRectMake(SCREEN_WIDTH*12/20, SCREEN_HEIGHT/10+65, SCREEN_WIDTH*7/20, SCREEN_WIDTH*7/20);
        bind.frame=CGRectMake(SCREEN_WIDTH*9/20, SCREEN_HEIGHT/6+65, SCREEN_WIDTH*2/20, SCREEN_WIDTH*3/20);
    }
    
    [self.view addSubview:device];
    [self.view addSubview:phone];
    [self.view addSubview:bind];
    
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(scanClick:) userInfo:nil repeats:NO];
}

//2.点击按钮 寻找CBPeripheral(扫描外设)
- (IBAction)scanClick:(id)sender
{
    [arrayBLE removeAllObjects];
    if (self.centralMgr.state==CBCentralManagerStatePoweredOn)
    {
        [self.centralMgr scanForPeripheralsWithServices:nil options:nil];
    }
    [self.scanResultTableView reloadData];
}

#pragma mark -CBCentralManagerDelegate方法(required)
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
            break;
        case CBCentralManagerStatePoweredOn:
            NSLog(@">>>CBCentralManagerStatePoweredOn");
            break;
            
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    BLEInfo *discoveredBLEInfo=[[BLEInfo alloc] init];
    discoveredBLEInfo.discoveredPeripheral=peripheral;
    discoveredBLEInfo.rssi=RSSI;
    
    [self saveBLE:discoveredBLEInfo];
}

#pragma mark -更新tableview的数据源
-(BOOL)saveBLE:(BLEInfo *)discoveredBLEInfo
{
    for (BLEInfo *info in self.arrayBLE)
    {
        if ([info.discoveredPeripheral.identifier.UUIDString isEqualToString:discoveredBLEInfo.discoveredPeripheral.identifier.UUIDString])
        {
            return NO;
        }
    }
    if ([discoveredBLEInfo.discoveredPeripheral.name isEqualToString:@"NZJ-iHappySleep"] || [discoveredBLEInfo.discoveredPeripheral.name containsString:@"Sleep4U"])
    {
        [self.arrayBLE addObject:discoveredBLEInfo];
    }
    [self.scanResultTableView reloadData];
    return YES;
}

#pragma mark -tableview的方法
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return arrayBLE.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *Identifier = @"BLEcell";
    
    UITableViewCell *BLEcell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    if (BLEcell==nil)
    {
        BLEcell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blecell"];
    }
    
    BLEInfo *discoveredBLEInfo=[BLEInfo new];
    discoveredBLEInfo=[arrayBLE objectAtIndex:indexPath.row];
    
//    nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/30, 0, SCREEN_WIDTH/2, 40)];
    nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/30, 0, SCREEN_WIDTH/2, 40)];
    nameLabel.font=[UIFont systemFontOfSize:16];
//    UUIDLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 40)];
    UUIDLabel=[[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2+SCREEN_WIDTH/30, 0, SCREEN_WIDTH/2-SCREEN_WIDTH/15, 40)];
    UUIDLabel.font=[UIFont systemFontOfSize:16];
    UUIDLabel.textAlignment=NSTextAlignmentRight;
    
    NSString* uuid = [NSString stringWithFormat:@"%@",[discoveredBLEInfo.discoveredPeripheral identifier]];
    uuid = [uuid substringFromIndex:[uuid length] - 13];
    
    nameLabel.text=discoveredBLEInfo.discoveredPeripheral.name;
    UUIDLabel.text=uuid;
    
    [BLEcell.contentView addSubview:nameLabel];
    [BLEcell.contentView addSubview:UUIDLabel];
    
    return BLEcell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BLEInfo *bleInfo=[arrayBLE objectAtIndex:indexPath.row];
    //1.将选择的外设存储到数据库并关闭数据库
    dbOpration=[[DataBaseOpration alloc] init];
    BluetoothInfo *bluetoothInfo=[[BluetoothInfo alloc] init];
    bluetoothInfo.saveId=@"1";
    bluetoothInfo.peripheralIdentify=bleInfo.discoveredPeripheral.identifier.UUIDString;
    [dbOpration insertPeripheralInfo:bluetoothInfo];
    //2.采用通知传值
    NSDictionary *dic=[NSDictionary dictionaryWithObjectsAndKeys:self.centralMgr,@"CBCentralManager",bleInfo,@"BLEInfo", nil];
    NSNotification *notification=[NSNotification notificationWithName:@"Note" object:nil userInfo:dic];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
    //[self.navigationController popViewControllerAnimated:YES];
    
    NSArray *arr=self.navigationController.viewControllers;
    
    if ([_bindFlag isEqualToString:@"1"])
    {
        if (arr.count==4)
        {
            [self.navigationController popToViewController:[arr objectAtIndex:2] animated:YES];
        }
        else if(arr.count==3)
        {
            [self.navigationController popToViewController:[arr objectAtIndex:1] animated:YES];
        }
        else
        {
            [self.navigationController popToViewController:[arr objectAtIndex:0] animated:YES];
        }
    }
    else if ([_bindFlag isEqualToString:@"2"])
    {
        if (arr.count==5)
        {
            [self.navigationController popToViewController:[arr objectAtIndex:2] animated:YES];
        }
        else if(arr.count==4)
        {
            [self.navigationController popToViewController:[arr objectAtIndex:1] animated:YES];
        }
        else
        {
            [self.navigationController popToViewController:[arr objectAtIndex:0] animated:YES];
        }
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
