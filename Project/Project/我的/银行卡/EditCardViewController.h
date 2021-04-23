//
//  EditCardViewController.h
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface EditCardViewController : BaseViewController

- (instancetype)initWithCard:(NSDictionary *)card;

@property (nonatomic, copy) void (^operationSuccessBlock) (void);

@end

NS_ASSUME_NONNULL_END
