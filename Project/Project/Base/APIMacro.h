//
//  APIMacro.h
//  Project
//
//  Created by HC101 on 2020/11/25.
//  Copyright © 2020 LaiKe. All rights reserved.
//


#ifndef APIMacro_h
#define APIMacro_h

#import "BaseTableViewController.h"
#import "UIButton+Extend.h"
#import "UIColor+Extend.h"
#import "ZLPhoto.h"                                 //选择图片
#import "ZLPhotoAssets.h"
#import "DPublicImageBrowser.h"                     //图片浏览

#pragma mark -是不是iPhone X
// 判断是否为iPhone X 系列  这样写消除了在Xcode10上的警告。
#define kDevice_Is_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})
/**
 *导航栏高度
 */
#define SafeAreaTopHeight (kDevice_Is_iPhoneX ? 88 : 64)

/**
 *tabbar高度
 */
#define SafeAreaBottomHeight (kDevice_Is_iPhoneX ? (49 + 34) : 49)

//状态栏高度
#define k_Height_StatusBar (kDevice_Is_iPhoneX? 44.0 : 20.0)
//底部高度
#define k_Height_TabBar (kDevice_Is_iPhoneX ? 34.0 : 0.0)

#define APP (AppDelegate *)[UIApplication sharedApplication].delegate
/** 弱引用 */
#define WEAKSELF __weak typeof(self) weakSelf = self;
#define STRONGSELF typeof(self) __strong strongSelf = self;
#define STRONGSELFFor(object) typeof(object) __strong strongSelf = object;

#pragma mark -屏幕宽高
#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height
#pragma mark - 宽高比例
#define AutoWidth(width) ScreenW/414.0*(width)  //宽度
#define adaptFont(R) (R)*(ScreenW)/414
#define appColor HCOLOR(0x3A2EF4)//主题蓝色
#define appBgColor HCOLOR(0xF5F5F5) //背景色
#define fontColor_Dark HCOLOR(0x333333) //大字颜色
#define fontColor_Light HCOLOR(0xB2B2B2) //小字颜色
#define LINE_COLOR [UIColor colorWithRed:0.783922 green:0.780392 blue:0.8 alpha:1]


#pragma mark -三原色
#define RGB(r, g, b) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:1]
#define RGBA(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define rgba(r, g, b, a) [UIColor colorWithRed:r / 255.0 green:g / 255.0 blue:b / 255.0 alpha:a]
#define HCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


//8.字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )

//9.数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)

//10.字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)

//11.是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

// 注册通知
#define NOTIFY_ADD(_noParamsFunc, _notifyName)  [[NSNotificationCenter defaultCenter] \
addObserver:self \
selector:@selector(_noParamsFunc) \
name:_notifyName \
object:nil]

// 发送通知
#define NOTIFY_POST(_notifyName)   [[NSNotificationCenter defaultCenter] postNotificationName:_notifyName object:nil]

// 移除通知
#define NOTIFY_REMOVE(_notifyName) [[NSNotificationCenter defaultCenter] removeObserver:self name:_notifyName object:nil]


#ifdef DEBUG
#define PPLog(...) printf("[%s] %s [第%d行]: %s\n", __TIME__ ,__PRETTY_FUNCTION__ ,__LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define PPLog(...)
#endif



//#ifdef __OBJC__
//#import "BaseTableViewController.h"
//#import "UIButton+Extend.h"
//
//#endif

















#endif /* APIMacro_h */
