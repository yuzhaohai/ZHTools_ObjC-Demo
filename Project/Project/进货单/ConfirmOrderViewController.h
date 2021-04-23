//
//  ConfirmOrderViewController.h
//  Project
//
//  Created by 于兆海 on 2021/3/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ConfirmOrderViewController : BaseViewController

@property (nonatomic, copy) void (^operationSuccessBlock) (void);

- (instancetype)initWithArray:(NSArray *)array;

@property (strong, nonatomic) UILabel *label;

@property (assign, nonatomic) BOOL isMiaoSha;

@end

NS_ASSUME_NONNULL_END
