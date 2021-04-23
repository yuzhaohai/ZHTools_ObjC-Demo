//
//  BaseTableViewCell.h
//  ChamberGame
//
//  Created by 于兆海 on 2020/10/9.
//  Copyright © 2020 CC. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *anImageView;

@property (strong, nonatomic) UILabel *label;
@property (strong, nonatomic) UILabel *aLabel;
@property (strong, nonatomic) UILabel *bLabel;

@property (strong, nonatomic) UIButton *button;
@property (strong, nonatomic) UIButton *aButton;

@property (strong, nonatomic) UITextField *textField;

@property (copy, nonatomic) NSDictionary *info;

@end

NS_ASSUME_NONNULL_END
