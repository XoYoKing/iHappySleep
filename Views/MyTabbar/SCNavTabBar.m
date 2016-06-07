//
//  SCNavTabBar.m
//  iHappySleep
//
//  Created by 诺之家 on 15/9/24.
//  Copyright (c) 2015年 诺之家. All rights reserved.
//

#import "SCNavTabBar.h"
#import "myHeader.h"
#import "SCPopView.h"

@interface SCNavTabBar () <SCPopViewDelegate>
{
    UIScrollView    *_navgationTabBar;      // all items on this scroll view
    UIImageView     *_arrowButton;          // arrow button
    
    UIView          *_line;                 // underscore show which item selected
    SCPopView       *_popView;              // when item menu, will show this view
    
    UIButton *itemButton;                   //tabbar上item按钮
    NSMutableArray  *_items;                // SCNavTabBar pressed item
    NSInteger       _itemsWidth;            // items' width
    BOOL            _showArrowButton;       // is showed arrow button
    BOOL            _popItemMenu;           // is needed pop item menu
}

@end

@implementation SCNavTabBar

- (id)initWithFrame:(CGRect)frame //showArrowButton:(BOOL)show
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initConfig];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Methods

- (void)initConfig
{
    _items = [NSMutableArray array];
    
    [self viewConfig];
    [self addTapGestureRecognizer];
}

- (void)viewConfig
{
    _navgationTabBar = [[UIScrollView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, DOT_COORDINATE, SCREEN_WIDTH, NAV_TAB_BAR_HEIGHT)];
    _navgationTabBar.showsHorizontalScrollIndicator = NO;
    [self addSubview:_navgationTabBar];
    
    [self viewShowShadow:self shadowRadius:10.0f shadowOpacity:10.0f];
}

- (void)showLineWithButtonWidth:(CGFloat)width
{
     _line = [[UIView alloc] initWithFrame:CGRectMake(0, NAV_TAB_BAR_HEIGHT - 3.0f, width, 3.0f)];
    _line.backgroundColor = UIColorWithRGBA(20.0f, 80.0f, 200.0f, 0.7f);
    [_navgationTabBar addSubview:_line];
}

- (CGFloat)contentWidthAndAddNavTabBarItemsWithButtonsWidth:(NSInteger)widths
{
    CGFloat buttonX = DOT_COORDINATE;
    for (NSInteger index = 0; index < [_itemTitles count]; index++)
    {
        itemButton = [UIButton buttonWithType:UIButtonTypeCustom];
        itemButton.titleLabel.font=[UIFont systemFontOfSize:22];
        itemButton.frame = CGRectMake(buttonX, DOT_COORDINATE, widths, NAV_TAB_BAR_HEIGHT);
        if (index==0)
        {
            [itemButton setTitleColor:UIColorWithRGBA(20.0f, 80.0f, 200.0f, 0.7f) forState:UIControlStateNormal];
        }
        else
        {
            [itemButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        [itemButton setTitle:_itemTitles[index] forState:UIControlStateNormal];
        [itemButton addTarget:self action:@selector(itemPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_navgationTabBar addSubview:itemButton];
        
        [_items addObject:itemButton];
        buttonX += widths;
    }
    
    [self showLineWithButtonWidth:widths];
    return buttonX;
}

- (void)addTapGestureRecognizer
{
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(functionButtonPressed)];
    [_arrowButton addGestureRecognizer:tapGestureRecognizer];
}

- (void)itemPressed:(UIButton *)button
{
    NSInteger index = [_items indexOfObject:button];
    [_delegate itemDidSelectedWithIndex:index];
}

- (void)functionButtonPressed
{
    _popItemMenu = !_popItemMenu;
    [_delegate shouldPopNavgationItemMenu:_popItemMenu height:[self popMenuHeight]];
}

- (NSInteger)getButtonsWidth:(NSArray *)titles;
{
    NSInteger num=titles.count;
    _itemsWidth = SCREEN_WIDTH/num;
    
    return _itemsWidth;
}

- (void)viewShowShadow:(UIView *)view shadowRadius:(CGFloat)shadowRadius shadowOpacity:(CGFloat)shadowOpacity
{
    view.layer.shadowRadius = shadowRadius;
    view.layer.shadowOpacity = shadowOpacity;
}

- (CGFloat)popMenuHeight
{
    CGFloat buttonY = ITEM_HEIGHT;
    return buttonY;
}

- (void)popItemMenu:(BOOL)pop
{
    if (pop)
    {
        [self viewShowShadow:_arrowButton shadowRadius:DOT_COORDINATE shadowOpacity:DOT_COORDINATE];
        [UIView animateWithDuration:0.5f animations:^{
            _navgationTabBar.hidden = YES;
            _arrowButton.transform = CGAffineTransformMakeRotation(M_PI);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2f animations:^{
                if (!_popView)
                {
                    _popView = [[SCPopView alloc] initWithFrame:CGRectMake(DOT_COORDINATE, NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, self.frame.size.height - NAVIGATION_BAR_HEIGHT)];
                    _popView.delegate = self;
                    _popView.itemNames = _itemTitles;
                    [self addSubview:_popView];
                }
                _popView.hidden = NO;
            }];
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5f animations:^{
            _popView.hidden = !_popView.hidden;
            _arrowButton.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _navgationTabBar.hidden = !_navgationTabBar.hidden;
            [self viewShowShadow:_arrowButton shadowRadius:20.0f shadowOpacity:20.0f];
        }];
    }
}

#pragma mark -
#pragma mark - Public Methods
//自定义tabbar按钮下方线条自动滑动
- (void)setCurrentItemIndex:(NSInteger)currentItemIndex
{
    _currentItemIndex = currentItemIndex;
    for (int i=0; i<_items.count; i++)
    {
        UIButton *button = _items[i];
        if (i!=currentItemIndex)
        {
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        else
        {
            [button setTitleColor:UIColorWithRGBA(20.0f, 80.0f, 200.0f, 0.7f) forState:UIControlStateNormal];
        }
        
    }
    UIButton *button = _items[currentItemIndex];
    
    [UIView animateWithDuration:0.2f animations:^{
        _line.frame = CGRectMake(button.frame.origin.x, _line.frame.origin.y, _itemsWidth+2, _line.frame.size.height);
    }];
}

- (void)updateData
{
    _arrowButton.backgroundColor = self.backgroundColor;
    _itemsWidth=[self getButtonsWidth:_itemTitles];
    
    CGFloat contentWidth = [self contentWidthAndAddNavTabBarItemsWithButtonsWidth:_itemsWidth];
    _navgationTabBar.contentSize = CGSizeMake(contentWidth, DOT_COORDINATE);
}

- (void)refresh
{
    [self popItemMenu:_popItemMenu];
}

#pragma mark - SCFunctionView Delegate Methods
#pragma mark -
- (void)itemPressedWithIndex:(NSInteger)index
{
    [self functionButtonPressed];
    [_delegate itemDidSelectedWithIndex:index];
}

@end