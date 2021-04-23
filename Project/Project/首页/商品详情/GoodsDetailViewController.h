//
//  GoodsDetailViewController.h
//  Project
//
//  Created by 于兆海 on 2021/2/1.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GoodsDetailViewController : BaseViewController

- (instancetype)initWithID:(NSString *)goodsID;

@property (assign, nonatomic) BOOL isXianShiGou;

@end

NS_ASSUME_NONNULL_END
