//
//  PurchaseListViewCell.h
//  Project
//
//  Created by 于兆海 on 2021/2/1.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface PurchaseListViewCell : BaseTableViewCell

@property (nonatomic, copy) void (^amountDidChangeBlock) (NSDictionary *specsInfo, NSNumber *amount);
@property (nonatomic, copy) void (^didSelectBlock) (NSDictionary *goodsInfo, NSDictionary *specsInfo, BOOL isSpecs, BOOL selected);

#pragma mark -  PurchaseListViewController
- (void)setInfo:(NSDictionary *)info specsArray:(NSArray *)specsArray onSale:(BOOL)onSale;
- (void)setSelectionInfo:(NSDictionary *)selectionInfo;

#pragma mark -  BuyAgainViewController
- (void)setInfo:(NSDictionary *)info specsArray:(NSArray *)specsArray amountInfo:(NSDictionary *)amountInfo selectionInfo:(NSDictionary *)selectionInfo;

#pragma mark -  ConfirmOrderViewController
- (void)setGoodsInfo:(NSDictionary *)goodsInfo;

@end

NS_ASSUME_NONNULL_END
