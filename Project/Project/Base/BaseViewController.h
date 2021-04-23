//
//  BaseViewController.h
//  MiHan
//
//  Created by YuZhaohai on 2020/6/9.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZHTools_ObjC/ZHViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface BaseViewController : ZHViewController

@property (assign, nonatomic) BOOL needRefresh;

- (void)fetchRequest ;

@end

NS_ASSUME_NONNULL_END
