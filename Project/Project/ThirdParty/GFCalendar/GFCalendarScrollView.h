//
//  GFCalendarScrollView.h
//
//  Created by Mercy on 2016/11/9.
//  Copyright © 2016年 Mercy. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DidSelectDayHandler)(NSInteger year, NSInteger month, NSInteger day);

@interface GFCalendarScrollView : UIScrollView


@property (nonatomic, copy) DidSelectDayHandler didSelectDayHandler; // 日期点击回调

@property (copy, nonatomic) NSDate *selectedDate;

- (void)refreshToPreviousMonth ;

- (void)refreshToCurrentMonth; // 刷新 calendar 回到当前日期月份

- (void)refreshToNextMonth ;


@end
