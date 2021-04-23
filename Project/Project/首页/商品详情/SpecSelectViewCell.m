//
//  SpecSelectViewCell.m
//  Project
//
//  Created by 于兆海 on 2021/3/16.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "SpecSelectViewCell.h"

@interface SpecSelectViewCell ()

@property (strong, nonatomic) UIButton *addButton;
@property (strong, nonatomic) UIButton *minusButton;

@end

@implementation SpecSelectViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 0, zh_ScreenWidth - 10 * 2, 55)),
            zh_numberOfLines: @2,
            zh_font: @12,
        }];
        
        self.addButton = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.label.right - 25, 15, 25, 25)),
            zh_borderColor: kColor_EAEAEA,
            zh_normalTitleColor: kColor_666666,
            zh_titleFont: @14,
            zh_normalTitle: @"+",
            zh_borderWidth: @1,
            zh_superView: self.contentView
        }];
        [self.addButton addTarget:self action:@selector(tappedAmountButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.textField setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.addButton.left - 36, 15, 36, 25)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_textColor: kColor_333333,
            zh_userInteractionEnabled: @0,
            zh_font: @13,
            zh_text: @"0"
        }];
        
        self.minusButton = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.textField.left - 25, 15, 25, 25)),
            zh_borderColor: kColor_EAEAEA,
            zh_normalTitleColor: kColor_666666,
            zh_titleFont: @14,
            zh_normalTitle: @"-",
            zh_borderWidth: @1,
            zh_superView: self.contentView,
        }];
        [self.minusButton addTarget:self action:@selector(tappedAmountButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 0, self.minusButton.right - 10 * 2, 55)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_textColor: kColor_808080,
            zh_font: @12,
        }];
        
        [self.textField zh_addLineWithFrame:CGRectMake(0, 0, self.textField.width, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
        [self.textField zh_addLineWithFrame:CGRectMake(0, self.textField.height - 1, self.textField.width, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
    }
    return self;
}

- (void)tappedAmountButton:(UIButton *)button {
    BOOL isAdd = button == self.addButton;
    
    NSInteger batch_min = [self.info[@"batch_min"] integerValue];
    
    NSInteger amount = [self.textField.text integerValue];
    amount = isAdd ? amount + batch_min : amount - batch_min;
    
    amount = MAX(0, amount);
    
    self.textField.text = [@(amount) stringValue];
    
    if (self.amountChangeBlock) {
        self.amountChangeBlock(self.textField.text, self.info);
    }
}

- (void)setInfo:(NSDictionary *)info {
    [super setInfo:info];
    
    self.aLabel.frame = CGRectMake(10, 0, self.minusButton.left - 10 * 2, 55);
    self.aLabel.text = [NSString stringWithFormat:@"库存：%@", info[@"kucun"]];
    [self.aLabel sizeToFit];
    self.aLabel.frame = CGRectMake(self.minusButton.left - 10 - self.aLabel.width, 0, self.aLabel.width, 55);
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:info[@"specs_name"] attributes:@{NSForegroundColorAttributeName: [UIColor blackColor]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n￥%@", info[@"price"]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}]];
    self.label.attributedText = aString;
    self.label.frame = CGRectMake(10, 0, self.aLabel.left - 15, 55);
}

@end
