//
//  PurchaseListViewCell.m
//  Project
//
//  Created by 于兆海 on 2021/2/1.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "PurchaseListViewCell.h"
#import "ZZPopoverViewController.h"

@interface PurchaseListViewCell ()

@property (copy, nonatomic) NSMutableArray *viewArray;

@property (copy, nonatomic) NSArray *specsArray;

@property (assign, nonatomic) BOOL is4BuyAgainViewController;


@end

@implementation PurchaseListViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self.button setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(20, 35.5, 19, 19)),
            zh_selectedImage: @"ico_chosen",
            zh_normalImage: @"ico_chose"
        }];
        [self.button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.anImageView setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.button.right + 10, 10, 70, 70)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_backgroundColor: kColor_F5F5F5
        }];
        [self.anImageView zh_addCornerRadius:5 withCorners:UIRectCornerAllCorners];
        
        [self.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.anImageView.right + 10, 10, zh_ScreenWidth - self.anImageView.right - 10 - 10, 70)),
            zh_textColor: kColor_333333,
            zh_numberOfLines: @0,
            zh_font: @16,
        }];
                        
    }
    return self;
}

- (void)tappedButton:(UIButton *)button {
    button.selected = !button.selected;
    
    if (self.didSelectBlock) {
        self.didSelectBlock(self.info, @{}, NO, button.selected);
    }
}

- (void)tappedSubbutton:(UIButton *)button {
    button.selected = !button.selected;
    
    NSInteger index = [self.viewArray indexOfObject:button.superview];
    
    NSDictionary *specsInfo = self.specsArray[index];
    
    if (self.didSelectBlock) {
        self.didSelectBlock(self.info, specsInfo, YES, button.selected);
    }
}

- (void)tappedAmountButton:(UIButton *)button {
    NSInteger index = [self.viewArray indexOfObject:button.superview];
    
    NSDictionary *specsInfo = self.specsArray[index];
        
    BOOL isAdd = [@"+" isEqualToString:button.titleLabel.text];
    
    NSInteger batch_min = [specsInfo[@"batch_min"] integerValue];
    
    UITextField *textField = [button.superview viewWithTag:(5201314 + 2)];
    NSInteger amount = [textField.text integerValue];
    
    amount = isAdd ? amount + batch_min : amount - batch_min;
    
    amount = MAX(0, amount);
    
    if (self.is4BuyAgainViewController) {
        
        if (self.amountDidChangeBlock) {
            self.amountDidChangeBlock(specsInfo, @(amount));
        }
        
    } else {
        
        [Util POST:@"/api/Cart/cart_amount" showHUD:YES showResultAlert:YES parameters:@{
            @"amount": @(amount),
            @"cart_id": specsInfo[@"id"]
        } result:^(id responseObject) {
            if (responseObject) {
                if (self.amountDidChangeBlock) {
                    self.amountDidChangeBlock(specsInfo, @(amount));
                }
            }
        }];
        
    }
}

#pragma mark -  getter
- (NSMutableArray *)viewArray {
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}

#pragma mark -  PurchaseListViewController
- (void)setInfo:(NSDictionary *)info specsArray:(NSArray *)specsArray onSale:(BOOL)onSale {
    self.info = info;
    self.specsArray = specsArray;
    
    self.button.hidden = !onSale;
    self.label.text = info[kName];
    [self.anImageView sd_setImageWithURL:[NSURL URLWithString:info[@"image"]]];
    
    NSInteger tag = 5201314;
    
    for (int i = 0; i < specsArray.count; i++) {
        
        UIView *view;
        if (self.viewArray.count > i) {
            
            view = self.viewArray[i];
            
        } else {
            
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 90 + (65 * i), zh_ScreenWidth, 55)];
            [self.contentView addSubview:view];
            
            UIButton *button = [UIButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(20, 18, 19, 19)),
                zh_selectedImage: @"ico_chosen",
                zh_normalImage: @"ico_chose",
                zh_superView: view,
                zh_tag: @(tag)
            }];
            [button addTarget:self action:@selector(tappedSubbutton:) forControlEvents:UIControlEventTouchUpInside];
            
            UITextView *textView = [UITextView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(button.right + 10, 0, zh_ScreenWidth - button.right - 10 - 20, 55)),
                zh_backgroundColor: kColor_F5F5F5,
                zh_userInteractionEnabled: @0,
                zh_superView: view,
                zh_font: @12,
                zh_tag: @(tag + 1)
            }];
            textView.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
            [textView zh_addCornerRadius:5 withCorners:UIRectCornerAllCorners];
            
            UIButton *addButton = [UIButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(textView.right - 25 - 10, 15, 25, 25)),
                zh_borderColor: kColor_EAEAEA,
                zh_normalTitleColor: kColor_666666,
                zh_titleFont: @14,
                zh_normalTitle: @"+",
                zh_borderWidth: @1,
                zh_superView: view,
            }];
            [addButton addTarget:self action:@selector(tappedAmountButton:) forControlEvents:UIControlEventTouchUpInside];
            
            UITextField *textField = [UITextField viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(addButton.left - 36, 15, 36, 25)),
                zh_textAlignment: @(NSTextAlignmentCenter),
                zh_textColor: kColor_333333,
                zh_userInteractionEnabled: @0,
                zh_font: @13,
                zh_text: @"0",
                zh_superView: view,
                zh_tag: @(tag + 2)
            }];
            
            UIButton *minusButton = [UIButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(textField.left - 25, 15, 25, 25)),
                zh_borderColor: kColor_EAEAEA,
                zh_normalTitleColor: kColor_666666,
                zh_titleFont: @14,
                zh_normalTitle: @"-",
                zh_borderWidth: @1,
                zh_superView: view
            }];
            [minusButton addTarget:self action:@selector(tappedAmountButton:) forControlEvents:UIControlEventTouchUpInside];
                        
            [textField zh_addLineWithFrame:CGRectMake(0, 0, textField.width, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
            [textField zh_addLineWithFrame:CGRectMake(0, textField.height - 1, textField.width, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
            
            [self.viewArray addObject:view];
        }
        
        NSDictionary *specsInfo = specsArray[i];
        
        [view viewWithTag:tag].hidden = !onSale;
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:specsInfo[@"specs_name"] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n¥%@", specsInfo[@"price"]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"/%@  库存：%@", specsInfo[@"company"], specsInfo[@"kucun"]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;
        [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
        ((UITextField *)[view viewWithTag:(tag + 1)]).attributedText = aString;
        
        ((UITextField *)[view viewWithTag:(tag + 2)]).text = [NSString stringWithFormat:@"%@", (specsInfo[@"amount"] ? : specsInfo[@"batch_min"])];
    }
    
    for (UIView *view in self.viewArray) {
        view.hidden = [self.viewArray indexOfObject:view] >= specsArray.count;
    }
}

- (void)setSelectionInfo:(NSDictionary *)selectionInfo {
    __block NSArray *array = selectionInfo[[self.info[@"goods_id"] stringValue]];
    
    self.button.selected = (array.count == self.specsArray.count);
    
    [self.viewArray enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx < self.specsArray.count) {
            NSDictionary *specsInfo = self.specsArray[idx];
            
            NSInteger tag = 5201314;
            ((UIButton *)[obj viewWithTag:tag]).selected = ([array containsObject:specsInfo[@"id"]]);
        }
        
    }];
}

#pragma mark -  BuyAgainViewController
- (void)setInfo:(NSDictionary *)info specsArray:(NSArray *)specsArray amountInfo:(NSDictionary *)amountInfo selectionInfo:(NSDictionary *)selectionInfo {
    [self setInfo:info specsArray:specsArray onSale:YES];
    
    self.is4BuyAgainViewController = YES;
    
    __block NSArray *array = selectionInfo[info[@"id"]];
    
    self.button.selected = (array.count == specsArray.count);
    
    [self.viewArray enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *specsInfo = specsArray[idx];
        
        NSInteger tag = 5201314;
        
        ((UIButton *)[obj viewWithTag:tag]).selected = ([array containsObject:specsInfo[@"goods_specs_id"]]);
        
        UITextField *textField = [obj viewWithTag:(tag + 2)];
        textField.text = [NSString stringWithFormat:@"%@", amountInfo[specsInfo[@"goods_specs_id"]]];
        
    }];
}

#pragma mark -  ConfirmOrderViewController
- (void)setGoodsInfo:(NSDictionary *)goodsInfo {
    self.info = goodsInfo;
    
    self.anImageView.left = 20;
    self.label.frame = CGRectMake(self.anImageView.right + 10, 10, zh_ScreenWidth - self.anImageView.right - 10, 70);
    
    self.button.hidden = YES;
    self.label.text = goodsInfo[kName];
    [self.anImageView sd_setImageWithURL:[NSURL URLWithString:goodsInfo[@"image"]]];
    
    NSInteger tag = 5201314;
    NSArray *specsArray = goodsInfo[@"goods_specs"];
    
    for (int i = 0; i < specsArray.count; i++) {
        
        UIView *view;
        if (self.viewArray.count > i) {
            
            view = self.viewArray[i];
            
        } else {
            
            view = [[UIView alloc] initWithFrame:CGRectMake(0, 90 + (65 * i), zh_ScreenWidth, 55)];
            [self.contentView addSubview:view];
                        
            UITextView *textView = [UITextView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(20, 0, zh_ScreenWidth - 20 * 2, 55)),
                zh_backgroundColor: kColor_F5F5F5,
                zh_userInteractionEnabled: @0,
                zh_superView: view,
                zh_font: @12,
                zh_tag: @(tag + 1)
            }];
            textView.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
            [textView zh_addCornerRadius:5 withCorners:UIRectCornerAllCorners];
                        
            [UITextField viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(textView.right - 10 - 36, 15, 36, 25)),
                zh_textAlignment: @(NSTextAlignmentRight),
                zh_textColor: kColor_333333,
                zh_userInteractionEnabled: @0,
                zh_font: @13,
                zh_text: @"0",
                zh_superView: view,
                zh_tag: @(tag + 2)
            }];
                        
            [self.viewArray addObject:view];
        }
        
        NSDictionary *specsInfo = specsArray[i];
                
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:specsInfo[@"specs_name"] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n¥%@", specsInfo[@"price"]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"/%@  库存：%@", specsInfo[@"company"], specsInfo[@"kucun"]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}]];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;
        [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
        ((UITextField *)[view viewWithTag:(tag + 1)]).attributedText = aString;
        
        ((UITextField *)[view viewWithTag:(tag + 2)]).text = [NSString stringWithFormat:@"x%@", (specsInfo[@"amount"] ? : specsInfo[@"batch_min"])];
    }
    
    for (UIView *view in self.viewArray) {
        view.hidden = [self.viewArray indexOfObject:view] >= specsArray.count;
    }
}

@end
