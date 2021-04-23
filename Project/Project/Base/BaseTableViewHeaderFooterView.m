//
//  BaseTableViewHeaderFooterView.m
//  Project
//
//  Created by 于兆海 on 2021/1/30.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseTableViewHeaderFooterView.h"

@implementation BaseTableViewHeaderFooterView

- (void)setBgColor:(UIColor *)bgColor {
    _bgColor = [bgColor copy];
    
    self.backgroundView = [[UIImageView alloc] initWithImage:[UIImage zh_imageWithColor:bgColor]];
}

- (ZHButton *)button {
    if (!_button) {
        _button = [ZHButton viewWithDictionary:@{
            zh_superView: self
        }];
    }
    return _button;
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel viewWithDictionary:@{
            zh_superView: self
        }];
    }
    return _label;
}

@end
