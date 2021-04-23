//
//  EditAddressViewController.h
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditAddressViewController : BaseViewController

@property (nonatomic, copy) void (^operationSuccess) (void);

- (instancetype)initWithAddress:(NSDictionary *)address;

@end

NS_ASSUME_NONNULL_END
