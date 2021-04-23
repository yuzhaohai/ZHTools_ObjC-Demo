//
//  DPublicImageBrowser.h
//  decorateMaster
//
//  Created by sn on 2018/12/10.
//  Copyright © 2018年 cc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DPublicImageBrowser : NSObject
/**
 图片浏览

 @param imageArray 图片数组
 @param currentIndex 显示索引
 */
+(void)showPicBrowser:(NSMutableArray *)imageArray CurrentIndex:(NSInteger)currentIndex;
/**
 另一种图片浏览
 
 @param imageArray 图片数组
 @param currentIndex 显示索引
 */
+(void)showVCPicBrowser:(NSMutableArray *)imageArray CurrentIndex:(NSInteger)currentIndex viewController:(UIViewController *)viewController;
/**
 选择图片
 
 @param pickerImage 已选中图片集合
 @param num 最多选择几张
 @param callBackArray 返回事件
 @param picPhotoStatus 相册类型
 @param viewController 容器
 */
+(void)selectedZLPhotoPickerView:(NSMutableArray *)pickerImage PhotoStatus:(PickerPhotoStatus)picPhotoStatus ViewControllser:(UIViewController *)viewController picNum:(NSInteger)num callBackArray:(void(^)(NSArray<ZLPhotoAssets *> *status))callBackArray;
@end
