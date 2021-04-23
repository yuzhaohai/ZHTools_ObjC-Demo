//
//  ZHSelectViewController.h
//  Project
//
//  Created by 于兆海 on 2020/12/9.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "BaseViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZHSelectViewController : BaseViewController

@property (assign, nonatomic) NSInteger maxCount;

@property (copy, nonatomic) NSArray *array;

- (instancetype)initWithSelectedObjects:(NSArray *)selectedObjects;

@property (copy, nonatomic, readonly) NSMutableArray *selectedObjects;

@end

NS_ASSUME_NONNULL_END
