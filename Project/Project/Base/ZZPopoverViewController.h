//
//  ZZPopoverViewController.h
//  Project
//
//  Created by 于兆海 on 2021/1/9.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^ZHPopoverViewControllerTableSelectBlock)(NSIndexPath *indexPath);

@interface ZZPopoverViewController : UIViewController

@property (copy, nonatomic) NSArray *titleArray;
@property (copy, nonatomic) NSArray *imageArray;

@property (copy, nonatomic) ZHPopoverViewControllerTableSelectBlock selectBlock;

@end

NS_ASSUME_NONNULL_END
