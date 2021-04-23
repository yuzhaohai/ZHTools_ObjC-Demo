//
//  UIButton+Extend.h
//  Client
//
//  Created by 马永州 contact QQ:917123258 on 2018/11/3.
//  Copyright © 2018年 loveRain. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^TouchedBlock)(NSInteger tag);

@interface UIButton(Extend)

/**
    添加 addTarget

 @param touchHandler 点击block
 */
- (void)addActionHandler:(TouchedBlock)touchHandler;

/**
   扩展点击区域
 */
@property(nonatomic)UIEdgeInsets touchExtendInset;

/*!
 * 设置按钮正常状态下的图片
 */
- (void)setNormalImageName:(NSString *)imageName;
- (void)setNormalImage:(UIImage *)image;
- (void)setNormalImageWithColor:(UIColor *)color;

/*!
 * 设置按钮Hightlighted状态下的图片
 */
- (void)setHightlightedImageName:(NSString *)imageName;
- (void)setHightlightedImage:(UIImage *)image;
- (void)setHightlightedImageWithColor:(UIColor *)color;

/*!
 * 设置按钮Selected状态下的图片
 */
- (void)setSelectedImageName:(NSString *)imageName;
- (void)setSelectedImage:(UIImage *)image;
- (void)setSelectedImageWithColor:(UIColor *)color;

/*!
 * 设置按钮状态下的图片
 */
- (void)setNormal:(UIColor *)color hightlighted:(UIColor *)hgColor;
- (void)setNormal:(UIColor *)color selected:(UIColor *)selColor;
- (void)setNormal:(UIColor *)color hightlighted:(UIColor *)hgColor selected:(UIColor *)selColor;

/**
    图片上下
 */
- (void)setHorizontalAlignment;

-(void)setTimestamp:(NSInteger)timestamp form:(NSString *)form withTimerStop:(void (^)(void))handle;

#pragma mark -  <#mark#>
@property (copy, nonatomic) NSString *rawName;
@property (copy, nonatomic) NSArray *selectOptionArray;

@end

