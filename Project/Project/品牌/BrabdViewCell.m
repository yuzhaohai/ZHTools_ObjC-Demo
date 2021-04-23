//
//  BrabdViewCell.m
//  Project
//
//  Created by 于兆海 on 2021/1/23.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BrabdViewCell.h"

@interface BrabdViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;

@end

@implementation BrabdViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5, 0, self.width - 5 * 2, 90)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: self.contentView,
        }];
        [self.imageView zh_addCornerRadius:5 withCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)];
        
        self.label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5, self.imageView.bottom, self.width - 5 * 2, 30)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_backgroundColor: kColor_999999,
            zh_superView: self.contentView,
            zh_textColor: kColor_FFFFFF,
            zh_font: @14,
        }];
        [self.label zh_addCornerRadius:5 withCorners:(UIRectCornerBottomLeft | UIRectCornerBottomRight)];
        
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info {
    [super setInfo:info];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info[@"logo"]]];
    self.label.text = info[kName];
}

@end
