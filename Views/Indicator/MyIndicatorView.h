//
//  MyIndicatorView.h
//  iHappySleep
//
//  Created by 诺之家 on 15/12/18.
//  Copyright © 2015年 诺之家. All rights reserved.
//

#import <UIKit/UIKit.h>

#define sheme_black
#define HUD_STATUS_FONT			[UIFont boldSystemFontOfSize:16]

#ifdef sheme_black
#define HUD_STATUS_COLOR		[UIColor whiteColor]
#define HUD_SPINNER_COLOR		[UIColor whiteColor]
#define HUD_BACKGROUND_COLOR	[UIColor colorWithWhite:0.3 alpha:0.2]
#endif

@interface MyIndicatorView : UIView

+ (MyIndicatorView *)shared;

+ (void)dismiss;
+ (void)show:(NSString *)status;

@property (atomic, strong) UIWindow *window;
@property (atomic, strong) UIToolbar *hud;
@property (atomic, strong) UIActivityIndicatorView *spinner;
@property (atomic, strong) UILabel *label;

@end
