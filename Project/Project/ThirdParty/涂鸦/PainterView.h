//
//  PainterView.h
//  painter
//  https://github.com/BaiKunlun/efficient-painter-in-iOS
//  Created by 白昆仑 on 2017/5/16.
//  Copyright © 2017年 bkl. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PainterContent;

@interface PainterView : UIView

- (instancetype)initWithFrame:(CGRect)frame;

@property (nonatomic, strong, readonly) UIImage *snapImage;
@property (nonatomic, strong) UIColor *paintColor;
@property (nonatomic, assign) CGFloat paintWidth;

- (void)clear;

- (PainterContent *)getPainterContent;

@end
