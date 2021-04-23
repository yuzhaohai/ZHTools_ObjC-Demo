//
//  MiaoShaViewCell.m
//  Project
//
//  Created by 于兆海 on 2021/1/23.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "MiaoShaViewCell.h"

@interface MiaoShaViewCell ()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UILabel *priceLabel;
@property (strong, nonatomic) UILabel *oldPriceLabel;

@end

@implementation MiaoShaViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.imageView = [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(5, 0, self.width - 5 * 2, 120)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: self.contentView,
        }];
        
        self.priceLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.imageView.bottom, self.width, 30)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: self.contentView,
        }];
        
        self.oldPriceLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.imageView.bottom, self.width, 30)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: self.contentView,
        }];
        
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info {
    [super setInfo:info];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:info[@"image_thumb"]]];
        
    self.oldPriceLabel.frame = CGRectMake(0, self.imageView.bottom, self.width, 30);
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", info[@"del_price"]] attributes:@{NSStrikethroughStyleAttributeName : @(NSUnderlineStyleSingle), NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}];
    self.oldPriceLabel.attributedText = aString;
    [self.oldPriceLabel sizeToFit];
    self.oldPriceLabel.frame = CGRectMake(self.imageView.right - self.oldPriceLabel.width, self.imageView.bottom, self.oldPriceLabel.width, 30);
    
    aString = [[NSMutableAttributedString alloc] initWithString:@" ¥" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: [UIColor blackColor]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", info[@"price"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:21], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    self.priceLabel.attributedText = aString;
    self.priceLabel.frame = CGRectMake(5, self.imageView.bottom, self.oldPriceLabel.left - 5, 30);
}

@end
