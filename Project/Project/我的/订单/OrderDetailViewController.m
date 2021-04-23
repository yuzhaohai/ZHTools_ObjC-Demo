//
//  OrderDetailViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/30.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "OrderViewCell.h"

@interface OrderDetailViewController ()

@property (copy, nonatomic) NSDictionary *info;

@property (strong, nonatomic) ZHButton *statusButton;

@property (strong, nonatomic) UILabel *addressLabel;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) NSDictionary *detailInfo;

@end

@implementation OrderDetailViewController

- (instancetype)initWithInfo:(NSDictionary *)info {
    self = [super init];
    if (self) {
        self.info = info;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"订单详情";
    
    [self.view addSubview:self.tableView];
    
    [self.tableView.tableHeaderView addSubview:self.statusButton];
    [self.tableView.tableHeaderView addSubview:self.addressLabel];
        
    UIView *view = self.tableView.tableFooterView;
    [view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 40) color:[UIColor whiteColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.detailInfo) {
        [self fetchRequest];
    }
}

- (void)fetchRequest {
    [Util POST:@"/api/Order/detail" showHUD:YES showResultAlert:YES parameters:@{
        @"order_id": self.info[@"order_id"]
    } result:^(id responseObject) {
        if (responseObject) {
            self.detailInfo = responseObject;
                        
            [self.tableView reloadData];
        }
    }];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *goods_list = self.info[@"goods_list"];
    return goods_list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"OrderViewCell";
    OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[OrderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    
    NSInteger row = indexPath.row;
    
    NSArray *goods_list = self.info[@"goods_list"];
    
    [cell setInfo:goods_list[row] refoundType:-1];
        
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 35;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    static NSString *Identifier = @"UITableViewHeaderFooterView";
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:Identifier];
    
    NSInteger tag = 5201314;
    UILabel *label = (UILabel *)[view viewWithTag:tag];
    
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:Identifier];
        
        view.backgroundView = [[UIImageView alloc] initWithImage:[UIImage zh_imageWithColor:[UIColor zh_colorWithHexString:kColor_F5F5F5] size:CGSizeMake(zh_ScreenWidth, 35)]];

        [view zh_addLineWithFrame:CGRectMake(0, 5, zh_ScreenWidth, 29) color:[UIColor whiteColor]];
        
        label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 5, zh_ScreenWidth - 10, 29)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_textColor: kColor_000000,
            zh_superView: view,
            zh_tag: @(tag),
            zh_font: @14
        }];
    }
    
    label.text = [NSString stringWithFormat:@"商家：%@", self.info[@"shop_name"]];
    
    return view;
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_dataSource: self,
            zh_delegate: self,
            zh_tableFooterView: [UIView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 40 + 5 + 88 + 5 + 260 + SafeAreaHeight)),
            }],
            zh_tableHeaderView: [UIView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 60 + 80)),
                zh_backgroundColor: kColor_FFFFFF
            }]
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (ZHButton *)statusButton {
    if (!_statusButton) {
        _statusButton = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 60)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: kColor_Red,
            zh_titleFont: @16,
        }];
        
        _statusButton.titleRect = CGRectMake(20, 0, zh_ScreenWidth - 20, 60);
    }
    return _statusButton;
}

- (UILabel *)addressLabel {
    if (!_addressLabel) {
        _addressLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 60, zh_ScreenWidth - 10 * 2, 80)),
            zh_userInteractionEnabled: @1,
            zh_textColor: kColor_333333,
            zh_numberOfLines: @0,
            zh_font: @13
        }];
    }
    return _addressLabel;
}

#pragma mark -  setter
- (void)setDetailInfo:(NSDictionary *)detailInfo {
    _detailInfo = [detailInfo copy];
    
    [self.statusButton setTitle:detailInfo[@"status_desc"] forState:UIControlStateNormal];
    self.addressLabel.text = [NSString stringWithFormat:@"%@ %@\n\n%@%@%@%@", detailInfo[@"person"], detailInfo[@"phone"], detailInfo[@"province"], detailInfo[@"city"], detailInfo[@"district"], detailInfo[@"addr"]];
    
    UIView *view = self.tableView.tableFooterView;
    
    NSInteger tag = 5201314;
    UILabel *label = [view viewWithTag:tag];
    UILabel *label1 = [view viewWithTag:tag + 1];
    UITextView *textView2 = [view viewWithTag:tag + 2];
    UITextView *textView3 = [view viewWithTag:tag + 3];
    UITextView *textView4 = [view viewWithTag:tag + 4];
    
    
    if (!label) {
        label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 0, zh_ScreenWidth - 20, 40)),
            zh_text: @"总额：¥100.00   满减-¥9.00",
            zh_textColor: kColor_808080,
            zh_superView: view,
            zh_font: @14,
            zh_tag: @(tag)
        }];
        
        label1 = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, 0, zh_ScreenWidth - 20, 40)),
            zh_backgroundColor: [UIColor clearColor],
            zh_superView: view,
            zh_font: @14,
            zh_tag: @(tag + 1)
        }];
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@种 %@件商品  合计：\n红包优惠：\n实付金额：", @(1), @(1)]];
        NSMutableParagraphStyle *aParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        aParagraphStyle.lineSpacing = 10;
        [aString addAttribute:NSParagraphStyleAttributeName value:aParagraphStyle range:NSMakeRange(0, [aString.string length])];
        textView2.attributedText = aString;
        
        UITextView *textView = [UITextView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 40 + 5, zh_ScreenWidth, 88)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_userInteractionEnabled: @0,
            zh_textColor: kColor_333333,
            zh_superView: view,
            zh_font: @14,
            zh_attributedText: aString,
            zh_tag: @(tag + 2)
        }];
        textView.textContainerInset = UIEdgeInsetsMake(12.5, 10, 12.5, 10);
        textView2 = textView;
        
        aString = [[NSMutableAttributedString alloc] initWithString:@"¥97.00\n¥0\n" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"¥97.00" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}]];
        
        NSMutableParagraphStyle *bParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        bParagraphStyle.lineSpacing = 10;
        bParagraphStyle.alignment = NSTextAlignmentRight;
        [aString addAttribute:NSParagraphStyleAttributeName value:bParagraphStyle range:NSMakeRange(0, [aString.string length])];
        
        textView = [UITextView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(textView.frame),
            zh_backgroundColor: [UIColor clearColor],
            zh_userInteractionEnabled: @0,
            zh_superView: view,
            zh_font: @14,
            zh_attributedText: aString,
            zh_tag: @(tag + 3)
        }];
        textView.textContainerInset = UIEdgeInsetsMake(12.5, 10, 12.5, 10);
        textView3 = textView;
        
        aString = [[NSMutableAttributedString alloc] initWithString:@"订单信息" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n订单编号:\t%@\n支付方式:\t%@\n物流公司:\t%@\n快递单号:\t%@\n下单时间:\t%@\n支付时间:\t%@\n发货时间:\t%@\n完成时间:\t%@", detailInfo[@"orderno"], (@[@"余额支付", @"支付宝", @"微信", @"微信"][[detailInfo[@"pay_type"] integerValue]]), (detailInfo[@"express_company"] ? : @""), (detailInfo[@"expressno"] ? : @""), detailInfo[@"create_time"], (detailInfo[@"pay_time"] ? : @""), (detailInfo[@"send_time"] ? : @""), (detailInfo[@"finish_time"] ? : @"")] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}]];
        NSMutableParagraphStyle *cParagraphStyle = [[NSMutableParagraphStyle alloc] init];
        cParagraphStyle.lineSpacing = 10;
        [aString addAttribute:NSParagraphStyleAttributeName value:cParagraphStyle range:NSMakeRange(0, [aString.string length])];
        
        textView = [UITextView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, textView.bottom + 5, zh_ScreenWidth, 260)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_attributedText: aString,
            zh_scrollEnabled: @0,
            zh_superView: view,
            zh_editable: @0,
            zh_tag: @(tag + 4)
        }];
        textView.textContainerInset = UIEdgeInsetsMake(12.5, 10, 12.5, 10);
        textView4 = textView;
    }
    
    NSString *give_goods_name = detailInfo[@"give_goods_name"], *coupon = detailInfo[@"coupon"];
    if (give_goods_name.length > 0) {
        label.text = [NSString stringWithFormat:@"总额：¥%.2f   赠%@", [detailInfo[@"total"] doubleValue], give_goods_name];
    } else if ([coupon doubleValue] > 0) {
        label.text = [NSString stringWithFormat:@"总额：¥%.2f   减%@", [detailInfo[@"total"] doubleValue], coupon];
    } else {
        label.text = [NSString stringWithFormat:@"总额：¥%.2f", [detailInfo[@"total"] doubleValue]];
    }
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"小计：" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f", ([detailInfo[@"total"] doubleValue] - [coupon doubleValue])] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment = NSTextAlignmentRight;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    label1.attributedText = aString;
    
    NSInteger amount = .0;
    NSArray *goods_list = detailInfo[@"goods_list"];
    for (NSDictionary *theInfo in goods_list) {
        amount += [theInfo[@"amount"] integerValue];
    }
    aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@种 %@件商品  合计：\n红包优惠：\n实付金额：", @(goods_list.count), @(amount)]];
    NSMutableParagraphStyle *aParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    aParagraphStyle.lineSpacing = 10;
    [aString addAttribute:NSParagraphStyleAttributeName value:aParagraphStyle range:NSMakeRange(0, [aString.string length])];
    textView2.attributedText = aString;
    
    aString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f\n¥%.2f\n", ([detailInfo[@"total"] doubleValue] - [coupon doubleValue]), [detailInfo[@"money_red"] doubleValue]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_808080]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%.2f", [detailInfo[@"pay_true"] doubleValue]] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}]];
    
    NSMutableParagraphStyle *bParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    bParagraphStyle.lineSpacing = 10;
    bParagraphStyle.alignment = NSTextAlignmentRight;
    [aString addAttribute:NSParagraphStyleAttributeName value:bParagraphStyle range:NSMakeRange(0, [aString.string length])];
    textView3.attributedText = aString;
    
    aString = [[NSMutableAttributedString alloc] initWithString:@"订单信息" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n订单编号:\t%@\n支付方式:\t%@\n物流公司:\t%@\n快递单号:\t%@\n下单时间:\t%@\n支付时间:\t%@\n发货时间:\t%@\n完成时间:\t%@", detailInfo[@"orderno"], (@[@"余额支付", @"支付宝", @"微信", @"微信"][[detailInfo[@"pay_type"] integerValue]]), (detailInfo[@"express_company"] ? : @""), (detailInfo[@"expressno"] ? : @""), detailInfo[@"create_time"], (detailInfo[@"pay_time"] ? : @""), (detailInfo[@"send_time"] ? : @""), (detailInfo[@"finish_time"] ? : @"")] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}]];
    NSMutableParagraphStyle *cParagraphStyle = [[NSMutableParagraphStyle alloc] init];
    cParagraphStyle.lineSpacing = 10;
    [aString addAttribute:NSParagraphStyleAttributeName value:cParagraphStyle range:NSMakeRange(0, [aString.string length])];
    textView4.attributedText = aString;
}

@end
