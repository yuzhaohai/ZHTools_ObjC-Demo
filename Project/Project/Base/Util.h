//
//  Util.h
//  Health_iOS
//
//  Created by macdev02 on 15/8/20.
//  Copyright (c) 2015年 Rain. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Util : NSObject

+ (__kindof NSURLSessionTask *)POST:(NSString *)URL
                            showHUD:(BOOL)showHUD
                            showResultAlert:(BOOL)showResultAlert
                         parameters:(id)parameters
                            result:(void(^)(id responseObject))result;

+ (NSDictionary *)handleParameter:(NSDictionary *)parameter ;

+ (NSString *)timeStamp ;

+ (CGFloat)height4Image:(UIImage *)image width:(CGFloat)width ;

+ (UIColor *)colorAtPoint:(CGPoint)point onImage:(UIImage *)image ;

+ (CGRect)frameRelativeToScreenOfView:(UIView *)view ;

+ (UIImage *)reSizeImage:(id)image toSize:(CGSize)reSize;

+ (UIView *)viewWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor labelProperty:(NSDictionary *)labelProperty;

///正则匹配用户密码6-18位数字和字母组合
+ (BOOL)checkPassword:(NSString *) password;

@end
