//
//  CitySelectViewController.h
//  Project
//
//  Created by 于兆海 on 2021/1/25.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface CitySelectViewController : BaseViewController

@property (nonatomic, copy) void (^didSelect) (NSDictionary *city);

@end

NS_ASSUME_NONNULL_END
