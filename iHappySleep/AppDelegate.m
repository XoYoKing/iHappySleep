//
//  AppDelegate.m
//  iHappySleep
//
//  Created by 诺之家 on 15/9/24.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "ViewController.h"
#import "DataBaseOpration.h"
#import "BluetoothInfo.h"
#import "PatientInfo.h"

@interface AppDelegate ()

@end

@implementation AppDelegate
{
    PatientInfo       *patientInfo;
    BluetoothInfo *bluetoothInfo;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    
    [NSThread sleepForTimeInterval:1];
    
    DataBaseOpration *dataBaseOpration=[[DataBaseOpration alloc] init];
    NSArray* bluetoothInfoArray=[dataBaseOpration getBluetoothDataFromDataBase];
    NSArray* patientInfoArray=[dataBaseOpration getPatientDataFromDataBase];
    if (bluetoothInfoArray.count>0)
    {
        bluetoothInfo=[bluetoothInfoArray objectAtIndex:0];
    }
    [dataBaseOpration closeDataBase];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *userName=[userDefault objectForKey:@"PatientID"];
    
    UIStoryboard *mainStoryboard=[UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    if (userName.length==0 || userName==nil)
    {
        //1.设置登录界面为根视图控制器
        LoginViewController *rootView = (LoginViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"LoginView"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:rootView];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
        //2.从数据库读取蓝牙外设传递给登陆界面（数据库操作完之后关闭数据库）
        rootView.bluetoothInfo=bluetoothInfo;
        rootView.PatientInfoArray=patientInfoArray;
    }
    else
    {
        //1.设置ViewController为根视图控制器
        ViewController *rootView = (ViewController *)[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"FirstMain"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:rootView];
        self.window.rootViewController = nav;
        [self.window makeKeyAndVisible];
        
        //2.从数据库读取数据传到主界面（读取NSUserDefaults中的该PatientID用户信息表信息、治疗数据、评估数据以及蓝牙外设，读完数据之后关闭数据库）
        for (PatientInfo *tmp in patientInfoArray)
        {
            if ([tmp.PatientID isEqualToString:userName])
            {
                patientInfo=tmp;
            }
        }
        rootView.patientInfo=patientInfo;
        rootView.bluetoothInfo=bluetoothInfo;
    }
    
    //注册切换用户通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeUser) name:@"ChangeUser" object:nil];
    
    return YES;
    
}

-(void)changeUser
{
    bluetoothInfo=nil;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
