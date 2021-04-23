//
//  GoodsViewCell.m
//  Project
//
//  Created by 于兆海 on 2021/1/23.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "GoodsViewCell.h"

@interface GoodsViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *numberLabel;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *saleAmountLabel;
@property (strong, nonatomic) UILabel *discountLabel;

@end

@implementation GoodsViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.container = [UIView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(11, 2.5, self.width - 11 - 4.5, 290)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: self.contentView
        }];
        
        self.imageView = [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, self.container.width, 172)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_superView: self.container,
        }];
        
        self.numberLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5.5, self.imageView.bottom + 5.5, self.container.width - 11, 22)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_superView: self.container,
            zh_borderColor: kColor_Red,
            zh_textColor: kColor_Red,
            zh_borderWidth: @1,
            zh_font: @13
        }];
        
        self.nameLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5.5, self.numberLabel.bottom, self.container.width - 11, 24 + 10)),
            zh_superView: self.container,
            zh_textColor: kColor_333333,
            zh_numberOfLines: @2,
            zh_font: @11
        }];
        
        self.priceLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5.5, self.nameLabel.bottom, self.container.width - 11, 15 + 14)),
            zh_superView: self.container,
            zh_textColor: kColor_Red,
            zh_font: @15
        }];
        
        self.saleAmountLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5.5, self.nameLabel.bottom, self.container.width - 11, 15 + 14)),
            zh_superView: self.container,
            zh_textColor: kColor_808080,
            zh_font: @15
        }];
        
        self.discountLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5.5, self.priceLabel.bottom, 42, 19)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_backgroundColor: kColor_Red,
            zh_superView: self.container,
            zh_textColor: kColor_FFFFFF,
            zh_text: @"满减",
            zh_font: @11
        }];
        
        [self.container zh_addCornerRadius:10 withCorners:UIRectCornerAllCorners];
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info {
    [super setInfo:info];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info[@"image"]]];
    
    self.numberLabel.text = [NSString stringWithFormat:@"货号：%@", info[@"good_number"]];
    
    self.nameLabel.text = info[kName];
    
    self.priceLabel.text = [NSString stringWithFormat:@"¥%@", info[@"price"]];
    
    self.saleAmountLabel.frame = self.priceLabel.frame;
    self.saleAmountLabel.text = [NSString stringWithFormat:@"销量:%@", info[@"sale"]];
    [self.saleAmountLabel sizeToFit];
    self.saleAmountLabel.frame = CGRectMake(self.priceLabel.right - self.saleAmountLabel.width, self.priceLabel.top, self.saleAmountLabel.width, self.priceLabel.height);
        
    NSString *string = info[@"huodong"];
    self.discountLabel.frame = CGRectMake(5.5, self.priceLabel.bottom, zh_ScreenWidth, 19);
    self.discountLabel.text = string;
    [self.discountLabel sizeToFit];
    self.discountLabel.frame = CGRectMake(5.5, self.priceLabel.bottom, self.discountLabel.width + 20, 19);
    self.discountLabel.hidden = string.length == 0;
}

@end
