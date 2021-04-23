//
//  CategoryViewCell.m
//  Project
//
//  Created by 于兆海 on 2021/1/23.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "CategoryViewCell.h"

@interface CategoryViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *label;

@end

@implementation CategoryViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake((self.width - 55) / 2.0, 10, 55, 57)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_backgroundColor: kColor_F5F5F5,
            zh_superView: self.contentView,
        }];
        
        self.label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.imageView.bottom + 8, self.width, 15)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_superView: self.contentView,
            zh_textColor: kColor_333333,
            zh_numberOfLines: @2,
            zh_font: @13,
        }];
        
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info {
    [super setInfo:info];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info[@"img"]]];
    self.label.text = info[kName];
}

@end
