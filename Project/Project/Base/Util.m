//
//  Util.m
//  Health_iOS
//
//  Created by macdev02 on 15/8/20.
//  Copyright (c) 2015年 Rain. All rights reserved.
//

#import "Util.h"

@implementation Util

#pragma mark -  net work
+ (__kindof NSURLSessionTask *)POST:(NSString *)URL showHUD:(BOOL)showHUD showResultAlert:(BOOL)showResultAlert parameters:(id)parameters result:(void (^)(id))result {
    
    if (showHUD) {
        [SVProgressHUD show];
    }
    
    return [PPNetworkHelper POST:[kHost stringByAppendingString:URL] parameters:[Util handleParameter:parameters] success:^(id responseObject) {
        
        if (showHUD) {
            [SVProgressHUD dismissWithDelay:0];
        }
        
        NSLog(@"%@", URL);
        
        NSDictionary *dict = [responseObject zh_removeNULL];
        NSString *message = [dict isKindOfClass:[NSDictionary class]] ? dict[@"msg"] : @"网络请求失败";
        
        id theObject = [Util responseObject:dict];
        
        if (showResultAlert && message.length > 1) {
            if (theObject) {
                [SVProgressHUD showSuccessWithStatus:message];
            } else {
                [SVProgressHUD showErrorWithStatus:message];
            }
        }
        
        if (result) {
            result(theObject);
        }
        
    } failure:^(NSError *error) {
        
        if (showHUD) {
            [SVProgressHUD dismissWithDelay:0];
        }
        
        if (showResultAlert) {
            [SVProgressHUD showErrorWithStatus:@"网络请求失败"];
        }
        
        if (result) {
            result(nil);
        }
        
    }];
}

+ (id)responseObject:(id)responseObject {
    NSDictionary *response;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        
        responseObject = [responseObject zh_removeNULL];
        NSNumber *code = responseObject[@"code"];
        
        if ([code integerValue] == 200) {
            
            response = responseObject[@"data"] ? : @{};
            
        } else if ([code integerValue] == 10000) {
            
            [AppDelegate appDelegate].userInfo = nil;
            
        }
        
    }
    
    return response;
}

+ (NSDictionary *)handleParameter:(NSDictionary *)parameter {
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameter];
    
    NSDictionary *userInfo = [AppDelegate appDelegate].userInfo;
    if (userInfo) {
        dict[@"token"] = dict[@"token"] ? : userInfo[@"token"];
        dict[@"user_id"] = dict[@"user_id"] ? : userInfo[@"id"];
    }
    
    return dict;
}

+ (NSString *)timeStamp {
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];//获取当前时间0秒后的时间
    NSTimeInterval time = [date timeIntervalSince1970] * 1000;// *1000 是精确到毫秒，不乘就是精确到秒
    NSString *timeString = [NSString stringWithFormat:@"%.0f", time];
    return timeString;
}

+ (CGFloat)height4Image:(UIImage *)image width:(CGFloat)width {
    return ceil(image.size.height * width / image.size.width);
}

+ (UIColor *)colorAtPoint:(CGPoint)point onImage:(UIImage *)image {
    
    CGFloat imageWidth = image.size.width;
    
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, imageWidth, image.size.height), point)) {
        return nil;
    }
    
    NSInteger pointX = trunc(point.x);
    
    NSInteger pointY = trunc(point.y);
    
    CGImageRef cgImage = image.CGImage;
    
    NSUInteger width = imageWidth;
    
    NSUInteger height = imageWidth;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    int bytesPerPixel = 4;
    
    int bytesPerRow = bytesPerPixel * 1;
    
    NSUInteger bitsPerComponent = 8;
    
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGRect)frameRelativeToScreenOfView:(UIView *)view {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height - 20;
    
    CGFloat x = .0;
    CGFloat y = .0;
    while (view.frame.size.width != 320 || view.frame.size.height != screenHeight) {
        x += view.frame.origin.x;
        y += view.frame.origin.y;
        view = view.superview;
        if ([view isKindOfClass:[UIScrollView class]]) {
            x -= ((UIScrollView *) view).contentOffset.x;
            y -= ((UIScrollView *) view).contentOffset.y;
        }
    }
    return CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
}

+ (UIImage *)reSizeImage:(id)anImage toSize:(CGSize)reSize {
    UIImage *image;
    if ([anImage isKindOfClass:[UIImage class]]) {
        image = anImage;
    } else if ([anImage isKindOfClass:[NSString class]]) {
        image = [UIImage imageNamed:anImage];
    } else {
        return nil;
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, reSize.width, reSize.height)];
    imageView.contentMode = UIViewContentModeCenter;
    imageView.image = image;
    
    return [UIImage zh_captureView:imageView];
}

+ (UIView *)viewWithFrame:(CGRect)frame bgColor:(UIColor *)bgColor labelProperty:(NSDictionary *)labelProperty {
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = bgColor;
    
    UILabel *label = [UILabel viewWithDictionary:labelProperty];
    [view addSubview:label];
    
    return view;
}

///正则匹配用户密码6-18位数字和字母组合
+ (BOOL)checkPassword:(NSString *) password {
    NSString *passWordRegex = @"^((?![0-9]+$)(?![a-zA-Z]+$)(?![~!@#$^&|*-_+=.?,]+$))[0-9A-Za-z~!@#$^&|*-_+=.?,]{6,20}$";   // 数字，字符或符号至少两种
        NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passWordRegex];
        
        if ([regextestcm evaluateWithObject:password] == YES) {
            return YES;
        } else {
            return NO;
        }
}

@end
