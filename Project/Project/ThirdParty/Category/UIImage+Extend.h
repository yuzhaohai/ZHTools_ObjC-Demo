//
//  UIImage+ImageRotat.h
//  Client
//
//  Created by 马永州 on 2018/10/11.
//  Copyright © 2018年 loveRain. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extend)
/**
 不缓存的图片
 
 @param filename 图片名字
 @return 返回不缓存的图片
 */
+(UIImage *)imageNotCached:(NSString *)filename;

/**
 颜色转换成UIImage类型.

 @param color 颜色
 @return 图片对象
 */
+ (UIImage *)imageWithColor:(UIColor *)color;
#pragma mark 二维码图片
/**
 二维码转图片
 
 @param string 二维码中的信息
 @return 转换后的图片
 */
+(UIImage *)imageWithQRCode:(NSString *)string;
/**
 将ciimage 转成制定尺寸图片
 
 @param image cimage
 @param size 尺寸
 @return 转换后的图片
 */
+(UIImage *)imageFormCIImage:(CIImage *)image withSize:(CGFloat) size;
#pragma mark 压缩

/**
 图片质量压缩

 @param image 原Image
 @param maxLength 最大字节
 @return 压缩后的图片
 */
+ (UIImage *)compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength;

/**
 图片尺寸压缩

 @param image 原Image
 @param maxLength 最大字节
 @return 压缩后的图片
 */
+ (UIImage *)compressImageSize:(UIImage *)image toByte:(NSUInteger)maxLength;

#pragma mark  截图
/**
 指定视图截屏

 @param view 视图
 @return 转换后的Image
 */
+ (UIImage *)screenShotView:(UIView *)view;

/**
 指定视图截屏(openGL layer渲染)

 @param view 视图
 @return 转换后的Image
 */
+ (UIImage *)openGLSnapshot:(UIView *)view;

/**
 图片旋转
 
 @param degree 度数
 @return 旋转后的图片
 */
-(UIImage *)imageRotateIndegree:(float)degree;


/**
 根据比例改变图片大小

 @param image 原图片
 @param percent 比例
 @return 改变后的图片
 */
-(UIImage*)changeSizeWithOriginalImage:(UIImage*)image percent:(float)percent;

/**
 Image裁剪圆形

 @param image 原Image
 @return 裁剪后Image
 */
-(UIImage*)circleImage:(UIImage*)image;
/**
 Image区域裁剪

 @param rect 区域
 @return 裁剪后Image
 */
-(UIImage*)getSubImage:(CGRect)rect;

/**
 等比例缩放或者放大

 @param size 缩放尺寸
 @return 缩放或者放大的图片
 */
-(UIImage*)scaleToSize:(CGSize)size;

/**
 Image进行方向处理

 @param aImage 原Image
 @param theorient 方向
 @return 处理后的Image
 */
-(UIImage *)rotateImage:(UIImage *)aImage with:(UIImageOrientation)theorient;

/**
 纠正图片方向

 @param aImage 原Image
 @return 方向
 */
-(UIImage *)fixOrientation:(UIImage *)aImage;




@end
