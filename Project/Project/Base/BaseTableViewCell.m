//
//  BaseTableViewCell.m
//  ChamberGame
//
//  Created by 于兆海 on 2020/10/9.
//  Copyright © 2020 CC. All rights reserved.
//

#import "BaseTableViewCell.h"
#import <ZHTools_ObjC/ZHTools_ObjC.h>

@implementation BaseTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setPropertyWithDictionary:@{
            zh_backgroundColor: @"ffffff",
            zh_selectionStyle: @(UITableViewCellSelectionStyleNone)
        }];
    }
    return self;
}

- (UIImageView *)anImageView {
    if (!_anImageView) {
        _anImageView = [UIImageView viewWithDictionary:@{
            zh_superView: self.contentView
        }];
    }
    return _anImageView;
}

- (UILabel *)label {
    if (!_label) {
        _label = [UILabel viewWithDictionary:@{
            zh_superView: self.contentView
        }];
    }
    return _label;
}

- (UILabel *)aLabel {
    if (!_aLabel) {
        _aLabel = [UILabel viewWithDictionary:@{
            zh_superView: self.contentView
        }];
    }
    return _aLabel;
}

- (UILabel *)bLabel {
    if (!_bLabel) {
        _bLabel = [UILabel viewWithDictionary:@{
            zh_superView: self.contentView
        }];
    }
    return _bLabel;
}

- (UIButton *)button {
    if (!_button) {
        _button = [UIButton viewWithDictionary:@{
            zh_superView: self.contentView
        }];
    }
    return _button;
}

- (UIButton *)aButton {
    if (!_aButton) {
        _aButton = [UIButton viewWithDictionary:@{
            zh_superView: self.contentView
        }];
    }
    return _aButton;
}

- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField viewWithDictionary:@{
            zh_superView: self.contentView
        }];
    }
    return _textField;
}

@end
