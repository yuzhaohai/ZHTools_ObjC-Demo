//
//  ApplyExchangeViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/29.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ApplyExchangeViewController.h"
#import <AliyunOSSiOS/OSSService.h>
#import "OrderViewController.h"
#import "OrderViewCell.h"

@interface ApplyExchangeViewController ()<UITextFieldDelegate>

@property (copy, nonatomic) NSNumber *type;

@property (assign, nonatomic) NSInteger step;

@property (copy, nonatomic) NSMutableArray *selectedIPArray;
@property (copy, nonatomic) NSMutableDictionary *amountInfoDictionary;

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSMutableArray *viewArray;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (copy, nonatomic) NSMutableArray *imageArray;
@property (copy, nonatomic) NSMutableArray *linkArray;

@property (copy, nonatomic) NSDictionary *orderInfo;

@property (copy, nonatomic) NSString *orderID;

@property (copy, nonatomic) NSDictionary *theInfo;

@property (copy, nonatomic) NSString *reason;

@property (strong, nonatomic) ZHButton *button;

@end

@implementation ApplyExchangeViewController

- (instancetype)initWithOrder:(NSString *)orderID step:(NSInteger)step {
    self = [super init];
    if (self) {
        self.orderID = orderID;
        self.step = step;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    self.title = self.step == 2 ? @"选择退换商品" : @"申请售后";
    
    if (self.step == 1) {
                
        for (int i = 0; i < 3; i++) {
                        
            UIButton *button = [UIButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(10, self.topBar.bottom + 10 + (65 + 10) * i, zh_ScreenWidth - 10 * 2, 65)),
                zh_backgroundColor: kColor_FFFFFF,
                zh_normalTitleColor: kColor_333333,
                zh_normalTitle: (@[@"退款\n", @"退货退款\n", @"换货\n"][i]),
                zh_superView: self.view,
                zh_titleFont: @16,
                zh_tag: @(i)
            }];
            [button zh_addCornerRadius:10 withCorners:UIRectCornerAllCorners];
            [button addTarget:self action:@selector(tappedTypeButton:) forControlEvents:UIControlEventTouchUpInside];
            
        }
        
    } else {
                
        if (self.step == 2) {
            
            [self.view addSubview:self.tableView];
            
        } else {
            
            [self.view addSubview:self.collectionView];
            
            self.tableView.scrollEnabled = NO;
            self.tableView.tableFooterView = nil;
            self.tableView.frame = CGRectMake(0, 0, zh_ScreenWidth, 360 + (self.selectedIPArray.count - 1) * 95);
            [self.collectionView addSubview:self.tableView];
            
        }
        
        CGFloat height = SafeAreaHeight * .8 + 44;
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenHeight - height, zh_ScreenWidth, height)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: kColor_Red,
            zh_superView: self.view,
            zh_normalTitle: (self.step == 3 ? @"提交" : @"确定"),
            zh_titleFont: @16,
        }];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleRect = CGRectMake(0, 0, zh_ScreenWidth, 44 + SafeAreaHeight * .3);
        [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
        
        self.button = button;
        
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.orderInfo) {
        [self fetchRequest];
    }
}

- (void)fetchRequest {
    [Util POST:@"/api/refund/order_goods_list" showHUD:YES showResultAlert:YES parameters:@{
        @"order_id": self.orderID
    } result:^(id responseObject) {
        if (responseObject) {
            self.orderInfo = responseObject;
        }
    }];
}

- (void)tappedTypeButton:(UIButton *)button {
    ApplyExchangeViewController *vc = [[ApplyExchangeViewController alloc] initWithOrder:self.orderID step:2];
    vc.type = @(button.tag);
    vc.orderInfo = self.orderInfo;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tappedButton:(UIButton *)button {
    self.button.userInteractionEnabled = NO;
    
    if (self.selectedIPArray.count < 1) {
        [SVProgressHUD showErrorWithStatus:@"请选择退换商品"];
        self.button.userInteractionEnabled = YES;
        return;
    }
    
    NSMutableArray *mArray = [NSMutableArray array];
    
    NSArray *goodsArray = self.orderInfo[@"goods_list"];
    for (NSIndexPath *ip in self.selectedIPArray) {
        NSDictionary *info = goodsArray[ip.row];
        
        NSString *order_goods_id = info[@"order_goods_id"];
        NSString *amount = self.amountInfoDictionary[order_goods_id];
        
        if ([amount integerValue] == 0) {
            [SVProgressHUD showErrorWithStatus:@"退换商品数量不能为零"];
            self.button.userInteractionEnabled = YES;
            return;
        }
        
        [mArray addObject:@{
            @"order_goods_id": order_goods_id,
            @"refund_num": amount,
        }];
    }
    
    if (self.step == 2) {
                
        [Util POST:@"/api/refund/get_refund_info" showHUD:YES showResultAlert:YES parameters:@{
            @"order_id": self.orderID,
            @"refund_goods": [mArray zh_jsonStringValue]
        } result:^(id responseObject) {
            
            self.button.userInteractionEnabled = YES;
            
            if (responseObject) {
                
                ApplyExchangeViewController *vc = [[ApplyExchangeViewController alloc] initWithOrder:self.orderID step:3];
                vc.type = self.type;
                vc.orderInfo = self.orderInfo;
                vc.selectedIPArray = self.selectedIPArray;
                vc.amountInfoDictionary = self.amountInfoDictionary;
                vc.theInfo = responseObject;
                [self.navigationController pushViewController:vc animated:YES];
                
            }
        }];
                
    } else {
        
        if (!self.reason) {
            [SVProgressHUD showErrorWithStatus:@"请选择退款原因"];
            self.button.userInteractionEnabled = YES;
            return;
        }
        
        if (self.imageArray.count == 0) {
            [SVProgressHUD showErrorWithStatus:@"请选择凭证图片"];
            self.button.userInteractionEnabled = YES;
            return;
        }
        
        if (self.imageArray.count > self.linkArray.count) {
            [self uploadImage];
            return;
        }
        
        [Util POST:@"/api/refund/refund_apply" showHUD:YES showResultAlert:YES parameters:@{
            @"order_id": self.orderID,
            @"refund_type": self.type,
            @"reason": self.reason,
            @"refund_goods": [mArray zh_jsonStringValue],
            @"images": [self.linkArray componentsJoinedByString:@","]
        } result:^(id responseObject) {
            
            self.button.userInteractionEnabled = YES;
            
            if (responseObject) {
                
                for (OrderViewController *vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:[OrderViewController class]]) {
                        
                        [vc.tableView.mj_header beginRefreshing];
                        
                        [self.navigationController popToViewController:vc animated:YES];
                        return;
                    }
                }
                
            }
        }];
        
    }
}

- (void)tappedCellButton:(UIButton *)button {
    UICollectionViewCell *cell = (UICollectionViewCell *)button.superview.superview;
    
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:cell];
    NSInteger item = indexPath.item;
    
    [self.imageArray removeObjectAtIndex:item];
    
    if (self.linkArray.count > item) {
        [self.linkArray removeObjectAtIndex:item];
    }
    
    [self.collectionView reloadData];
}

- (void)uploadImage {
    if (self.imageArray.count == self.linkArray.count) {
        [self tappedButton:nil];
        return;
    }
    
    if (![SVProgressHUD isVisible]) {
        [SVProgressHUD show];
    }
    
    ZLPhotoAssets *asset = self.imageArray[self.linkArray.count];
    
    NSString *bucket = @"gx-refund-img";
    NSString *endpoint = @"https://oss-cn-beijing.aliyuncs.com";
    NSString *accessKeyid = @"LTAI4GCFgWXq9C6osxmtxQkq";
    NSString *secretKeyId = @"LxYJOUR7moly4OJNa5uKTH98EWpR1a";
    NSString *securityToken = @"";// 可空 看后台
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:accessKeyid secretKeyId:secretKeyId securityToken:securityToken];
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    
    __block NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg", [Util timeStamp], [AppDelegate appDelegate].userInfo[@"id"]];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = bucket;
    
    //objectKey为云服储存的文件名
    put.objectKey = fileName;
    
    NSData *data = UIImagePNGRepresentation(asset.originImage);
    put.uploadingData = data;
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!task.error) {
                NSLog(@"upload object success!");
                
                [self.linkArray addObject:[NSString stringWithFormat:@"https://%@.oss-cn-beijing.aliyuncs.com/%@", bucket, fileName]];
                
                [self uploadImage];
                
            } else {
                
                NSLog(@"upload object failed, error: %@" , task.error);
                
                [SVProgressHUD dismissWithDelay:0];
                [SVProgressHUD showErrorWithStatus:@"文件上传失败..."];
                
            }
            
        });
        
        return nil;
    }];
    
    // 可以等待任务完成
    [putTask waitUntilFinished];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.step == 2 ? self.orderInfo[@"goods_list"] : self.selectedIPArray;
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 95;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"OrderViewCell";
    OrderViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    __block NSArray *goodsArray = self.orderInfo[@"goods_list"];
    
    if (!cell) {
        cell = [[OrderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        cell.amountDidChange = ^(NSDictionary * _Nonnull info, NSString * _Nonnull amount) {
            
            self.amountInfoDictionary[info[@"order_goods_id"]] = amount;
            
        };
        
        cell.textField.userInteractionEnabled = self.step == 2;
    }
        
    NSInteger row = indexPath.row;
    if (self.step == 3) {
        NSIndexPath *ip = self.selectedIPArray[row];
        
        row = ip.row;
    }
        
    NSDictionary *goodsInfo = goodsArray[row];
    [cell setExchangeOrderInfo:goodsInfo amount:(self.amountInfoDictionary[goodsInfo[@"order_goods_id"]] ? : @"")];
    
    if (self.step == 2) {
        [cell setPropertyWithDictionary:@{
            zh_borderColor: ([self.selectedIPArray containsObject:indexPath] ? kColor_Red : kColor_FFFFFF),
            zh_borderWidth: @1,
        }];
    }
    
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
    if (self.step == 2) {
        if ([self.selectedIPArray containsObject:indexPath]) {
            [self.selectedIPArray removeObject:indexPath];
        } else {
            [self.selectedIPArray addObject:indexPath];
        }
        
        [tableView reloadData];
    }
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
    
    label.text = [NSString stringWithFormat:@"订单编号：%@", self.orderInfo[@"orderno"]];
    
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return (self.step == 3) ? 360 - 35 - 95 : 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    static NSString *Identifier = @"UITableViewHeaderFooterView";
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:Identifier];
    
    if (!view) {
        view = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:Identifier];
        
        view.backgroundView = [[UIImageView alloc] initWithImage:[UIImage zh_imageWithColor:[UIColor zh_colorWithHexString:kColor_F5F5F5] size:CGSizeMake(zh_ScreenWidth, 300)]];
        
        NSArray *array = @[@"请输入退货数量", @"请输入退款金额", @"请选择退款原因"];
        NSArray *keyArray = @[@"refund_num", @"refund_money", @"666"];
        
        for (int i = 0; i < 3; i++) {
            NSString *string = array[i];
            
            UITextField *textField = [UITextField viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, 5 + i * 57, zh_ScreenWidth, 56)),
                zh_textColor: i == 0 ? kColor_Red : kColor_333333,
                zh_rightViewMode: @(UITextFieldViewModeAlways),
                zh_textAlignment: @(NSTextAlignmentRight),
                zh_backgroundColor: kColor_FFFFFF,
                zh_superView: view,
                zh_font: @14,
                zh_tag: @(i),
                zh_delegate: self,
                zh_text: (i < 2 ? [NSString stringWithFormat:@"%@", self.theInfo[keyArray[i]]] : @""),
                zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:string attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_B2B2B2]}],
                
                zh_rightView: [UIImageView viewWithDictionary:@{
                    zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 25, 56)),
                    zh_image: (i == 2 ? [Util reSizeImage:@"more" toSize:CGSizeMake(25, 56)] : [UIImage zh_imageWithColor:[UIColor whiteColor] size:CGSizeMake(25, 56)])
                }]
            }];
            
            [self.viewArray addObject:textField];
            
            [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(25, 0, 168, 56)),
                zh_text: [string substringFromIndex:3],
                zh_textColor: kColor_333333,
                zh_superView: textField,
                zh_font: @14,
            }];
        }
        
        UIView *aView = [Util viewWithFrame:CGRectMake(0, 5 + 57 * 3 + 5, zh_ScreenWidth, 120) bgColor:[UIColor whiteColor] labelProperty:@{
            zh_frame: NSStringFromCGRect(CGRectMake(25, 0, zh_ScreenWidth - 25, 40)),
            zh_textColor: kColor_333333,
            zh_text: @"上传凭证图片",
            zh_font: @14,
        }];
        [view addSubview:aView];
    }
    
    return view;
}

#pragma mark -  UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 2) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"退款愿意" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"产品质量问题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text = @"产品质量问题";
            self.reason = textField.text;
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"质保期内产品损坏" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            textField.text = @"质保期内产品损坏";
            self.reason = textField.text;
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertController animated:YES completion:nil];
        
    }
    
    return NO;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return MIN(self.imageArray.count + 1, 10);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *Identifier = @"UICollectionViewCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    NSInteger tag = 5201314;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:tag];
    UIButton *button = (UIButton *)[cell.contentView viewWithTag:(tag + 1)];
    if (!imageView) {
        imageView = [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 70, 70)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_superView: cell.contentView,
            zh_borderColor: kColor_B2B2B2,
            zh_borderWidth: @1,
            zh_tag: @(tag),
        }];
        
        button = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(50, 0, 20, 20)),
            zh_superView: cell.contentView,
            zh_normalImage: @"delete",
            zh_tag: @(tag + 1),
        }];
        [button addTarget:self action:@selector(tappedCellButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (self.imageArray.count > indexPath.item) {
        
        ZLPhotoAssets *assets = self.imageArray[indexPath.item];
        
        [imageView setPropertyWithDictionary:@{
            zh_image: assets.originImage,
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
        }];
        
    } else {
        
        [imageView setPropertyWithDictionary:@{
            zh_image: @"add",
            zh_contentMode: @(UIViewContentModeCenter),
        }];
        
    }
    
    button.hidden = indexPath.item == self.imageArray.count;
    
    return cell;
    
}

#pragma mark didSelect
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == self.imageArray.count) {
        
        [DPublicImageBrowser selectedZLPhotoPickerView:self.imageArray PhotoStatus:PickerPhotoStatusPhotos ViewControllser:self picNum:10 callBackArray:^(NSArray<ZLPhotoAssets *> *status) {
            
            [self.imageArray removeAllObjects];
            
            [self.imageArray addObjectsFromArray:status];
            
            [collectionView reloadData];
            
        }];
        
    } else {
        
    }
}

//定义每个Cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(70, 70);
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake((360 + (self.selectedIPArray.count - 1) * 95), 25, 15, 25);
}

//两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10;
}

//两列cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeMake(zh_ScreenWidth, 230 + SafeAreaHeight * .8 + 44);
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionHeader" forIndexPath:indexPath];
        
        return view;
        
        
    } else if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *view = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionFooter" forIndexPath:indexPath];
        
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"退款说明" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}];
        [aString appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n\n以下情况将不提供退换货服务\n\n•任何已使用商品；\n•任何因非正常使用、保管或保养不当而导致质量问题的商品；\n•商品无任何质量问题，因个人喜好（气味，色泽、型号，外观）要求的退换货将无法受理；\n•由收货人地址、电话号码填错等原因，造成商品拒签或快递无法正常投送；\n•超过退换货时间" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_666666]}]];
        
        UIView *aView = [Util viewWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 230) bgColor:[UIColor zh_colorWithHexString:kColor_F5F5F5] labelProperty:@{
            zh_frame: NSStringFromCGRect(CGRectMake(20, 0, zh_ScreenWidth - 40, 230)),
            zh_numberOfLines: @0,
            zh_attributedText: aString,
        }];
        [view addSubview:aView];
        
        return view;
        
    }
    
    return nil;
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, SafeAreaHeight * .8 + 44)],
            zh_superView: self.view,
            zh_dataSource: self,
            zh_delegate: self,
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSMutableArray *)viewArray {
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 1;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1) collectionViewLayout:layout];
        
        [collectionView setPropertyWithDictionary:@{
            zh_showsHorizontalScrollIndicator: @0,
            zh_showsVerticalScrollIndicator: @0,
            zh_backgroundColor: kColor_FFFFFF,
            zh_scrollEnabled: @1,
            zh_dataSource: self,
            zh_delegate: self
        }];
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionElementKindSectionFooter"];
        
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (NSMutableArray *)imageArray {
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (NSMutableArray *)linkArray {
    if (!_linkArray) {
        _linkArray = [NSMutableArray array];
    }
    return _linkArray;
}

- (NSMutableArray *)selectedIPArray {
    if (!_selectedIPArray) {
        _selectedIPArray = [NSMutableArray array];
    }
    return _selectedIPArray;
}

- (NSMutableDictionary *)amountInfoDictionary {
    if (!_amountInfoDictionary) {
        _amountInfoDictionary = [NSMutableDictionary dictionary];
    }
    return _amountInfoDictionary;
}

@end
