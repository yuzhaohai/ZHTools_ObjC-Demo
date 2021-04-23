//
//  UIColor+Extend.h
//  Project
//
//  Created by HC101 on 2020/11/27.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 渐变方式

 - GradientChangeDirectionLevel:              水平渐变
 - GradientChangeDirectionVertical:           竖直渐变
 - GradientChangeDirectionUpwardDiagonalLine: 向下对角线渐变
 - GradientChangeDirectionDownDiagonalLine:   向上对角线渐变
 */
typedef NS_ENUM(NSInteger, GradientChangeDirection) {
    GradientChangeDirectionLevel,
    GradientChangeDirectionVertical,
    GradientChangeDirectionUpwardDiagonalLine,
    GradientChangeDirectionDownDiagonalLine,
};

@interface UIColor (Extend)

/**
 创建渐变颜色

 @param size       渐变的size
 @param direction  渐变方式
 @param startcolor 开始颜色
 @param endColor   结束颜色

 @return 创建的渐变颜色
 */
+ (instancetype)colorGradientChangeWithSize:(CGSize)size
                                     direction:(GradientChangeDirection)direction
                                    startColor:(UIColor *)startcolor
                                      endColor:(UIColor *)endColor;


// 其他曲线渐变暂不考虑

@end




NS_ASSUME_NONNULL_END
