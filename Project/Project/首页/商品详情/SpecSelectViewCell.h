//
//  SpecSelectViewCell.h
//  Project
//
//  Created by 于兆海 on 2021/3/16.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseTableViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SpecSelectViewCell : BaseTableViewCell

@property (nonatomic, copy) void (^amountChangeBlock) (NSString *amount, NSDictionary *info);

@end

NS_ASSUME_NONNULL_END
