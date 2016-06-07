//
//  BLEInfo.h
//  蓝牙4.0
//
//  Created by 诺之家 on 15/9/18.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BLEInfo : NSObject

@property (nonatomic,strong) CBPeripheral *discoveredPeripheral;
@property (nonatomic,strong) NSNumber *rssi;

@end
