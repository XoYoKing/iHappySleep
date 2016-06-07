//
//  SCPopView.m
//  iHappySleep
//
//  Created by 诺之家 on 15/9/24.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "SCPopView.h"
#import "myHeader.h"

@implementation SCPopView

#pragma mark - Private Methods
#pragma mark -
- (CGFloat)getButtonsWidthWithTitles:(NSArray *)titles;
{
    NSInteger num =titles.count;
    CGFloat widths=(CGFloat)SCREEN_WIDTH/num;
    
    return widths;
}

- (void)updateSubViewsWithItemWidths:(CGFloat)itemWidths;
{
    CGFloat buttonX = DOT_COORDINATE;
    CGFloat buttonY = DOT_COORDINATE;
    for (NSInteger index = 0; index < [_itemNames count]; index++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.frame = CGRectMake(buttonX, buttonY, itemWidths, ITEM_HEIGHT);
        [button setTitle:_itemNames[index] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        buttonX += itemWidths;
        
        @try {
            if ((buttonX + itemWidths) >= SCREEN_WIDTH)
            {
                buttonX = DOT_COORDINATE;
                buttonY += ITEM_HEIGHT;
            }
        }
        @catch (NSException *exception) {
            
        }
        @finally {
            
        }
    }
}

- (void)itemPressed:(UIButton *)button
{
    [_delegate itemPressedWithIndex:button.tag];
}

#pragma mark - Public Methods
#pragma marl -
- (void)setItemNames:(NSArray *)itemNames
{
    _itemNames = itemNames;
    
    CGFloat itemWidths = [self getButtonsWidthWithTitles:itemNames];
    [self updateSubViewsWithItemWidths:itemWidths];
}

@end