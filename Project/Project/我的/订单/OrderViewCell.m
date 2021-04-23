//
//  OrderViewCell.m
//  Project
//
//  Created by 于兆海 on 2021/1/28.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "OrderViewCell.h"

@interface OrderViewCell ()<UITextFieldDelegate>



@end

@implementation OrderViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.anImageView setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 12.5, 70, 70)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_backgroundColor: kColor_F5F5F5,
        }];
        [self.anImageView zh_addCornerRadius:5 withCorners:UIRectCornerAllCorners];
        
        [self.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(90, 12.5, zh_ScreenWidth - 90 - 10, 32)),
            zh_textColor: kColor_333333,
            zh_numberOfLines: @0,
            zh_font: @13,
        }];
        
        [self.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(90, self.label.bottom, self.label.width, self.anImageView.height - self.label.height)),
            zh_numberOfLines: @0,
        }];
        
        [self.bLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.label.right - 168, self.aLabel.bottom - 16, 168, 16)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_textColor: kColor_808080,
            zh_numberOfLines: @0,
            zh_font: @12,
        }];
        
    }
    return self;
}

- (void)setInfo:(NSDictionary *)info refoundType:(NSInteger)refoundType {
    self.info = info;
    
    [self.anImageView sd_setImageWithURL:[NSURL URLWithString:(info[@"image_thumb"] ? : info[@"image"])]];
    
    self.label.frame = CGRectMake(90, 12.5, zh_ScreenWidth - 90 - 10, 32);
    self.label.text = info[kName];
    [self.label sizeToFit];
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"规格参数：%@", (info[@"specs"] ? : @"")] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor blackColor]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n¥%.2f", [info[@"pay_price"] doubleValue]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    self.aLabel.attributedText = aString;
    
    self.bLabel.text = [NSString stringWithFormat:@"x%@", (info[@"amount"] ? : @0)];
    
    if (refoundType != -1) {
        self.bLabel.frame = CGRectMake(self.aLabel.right - 168, self.aLabel.top, 168, self.aLabel.height);
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@[@"退款", @"退款退货", @"换货"][refoundType] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:@"#3091FF"]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\nx%@", (info[@"refund_num"] ? : @0)] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.alignment = NSTextAlignmentRight;
        paragraphStyle.lineSpacing = 5;
        [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
        self.bLabel.attributedText = aString;
    }
}

- (void)setExchangeOrderInfo:(NSDictionary *)info amount:(nonnull NSString *)amount {
    self.info = info;
    
    [self.anImageView sd_setImageWithURL:[NSURL URLWithString:(info[@"image_thumb"] ? : info[@"image"])]];
    
    self.label.frame = CGRectMake(90, 12.5, zh_ScreenWidth - 90 - 10, 32);
    self.label.text = info[kName];
    [self.label sizeToFit];
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"规格参数：%@", (info[@"specs"] ? : @"")] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor blackColor]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n¥%.2f", [info[@"pay_price"] doubleValue]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"  x%@", (info[@"amount"] ? : @0)] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13], NSForegroundColorAttributeName: [UIColor blackColor]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    self.aLabel.attributedText = aString;
    
    if (!self.textField.delegate) {
        [self.textField setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.bLabel.left, self.bLabel.top - 10, self.bLabel.width, self.bLabel.height + 20)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_textColor: kColor_333333,
            zh_font: self.bLabel.font,
            zh_delegate: self,
            zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:@"请输入退换数量" attributes:@{NSForegroundColorAttributeName: [UIColor lightGrayColor]}]
        }];
        
        self.textField.keyboardType = UIKeyboardTypePhonePad;
    }
    self.textField.text = amount;
}

#pragma mark -  UITextFieldDelegate
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    if ([textField.text integerValue] > [self.info[@"amount"] integerValue]) {
        [SVProgressHUD showErrorWithStatus:@"数量超过购买数量"];
        return NO;
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.amountDidChange) {
        self.amountDidChange(self.info, textField.text);
    }
}

@end
