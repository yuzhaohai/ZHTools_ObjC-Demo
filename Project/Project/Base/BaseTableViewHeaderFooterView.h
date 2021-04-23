//
//  BaseTableViewHeaderFooterView.h
//  Project
//
//  Created by 于兆海 on 2021/1/30.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableViewHeaderFooterView : UITableViewHeaderFooterView

@property (strong, nonatomic) ZHButton *button;

@property (copy, nonatomic) UIColor *bgColor;

@property (strong, nonatomic) UILabel *label;

@end

NS_ASSUME_NONNULL_END
