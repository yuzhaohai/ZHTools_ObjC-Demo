//
//  SpecSelectView.h
//  Project
//
//  Created by 于兆海 on 2021/3/16.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SpecSelectView : UIView

- (instancetype)initWithGoodsInfo:(NSDictionary *)info;

- (void)showInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
