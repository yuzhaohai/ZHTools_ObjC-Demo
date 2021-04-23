//
//  DPublicImageBrowser.m
//  decorateMaster
//
//  Created by sn on 2018/12/10.
//  Copyright © 2018年 cc. All rights reserved.
//

#import "DPublicImageBrowser.h"

@implementation DPublicImageBrowser

/**
 图片浏览
 
 @param imageArray 图片数组
 @param currentIndex 显示索引
 */
+(void)showPicBrowser:(NSMutableArray *)imageArray CurrentIndex:(NSInteger)currentIndex{
    NSMutableArray *photos = [NSMutableArray array];
    for (id asset in imageArray) {
        ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
        if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
            photo.asset = asset;
        }else if ([asset isKindOfClass:[ZLCamera class]]){
            ZLCamera *camera = (ZLCamera *)asset;
            photo.thumbImage = [camera thumbImage];
        }else if ([asset isKindOfClass:[UIImage class]]){
            photo.thumbImage = (UIImage *)asset;
            photo.photoImage = (UIImage *)asset;
        }else if ([asset isKindOfClass:[NSURL class]]){
            photo.photoURL = (NSURL *)asset;
        }else if ([asset isKindOfClass:[NSString class]]){
            photo.photoURL = [NSURL URLWithString:asset];
        }
        [photos addObject:photo];
    }
    
    ZLPhotoPickerBrowserViewController *browserVc = [[ZLPhotoPickerBrowserViewController alloc] init];
    browserVc.photos = photos;
//    browserVc.delegate = self;
    browserVc.currentIndex = currentIndex;
    if (@available(iOS 13.0, *)) {
        browserVc.modalPresentationStyle = UIModalPresentationFullScreen;
    } else {
        // Fallback on earlier versions
    }
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow.rootViewController presentViewController:browserVc animated:YES completion:nil];
}

/**
 另一种图片浏览
 
 @param imageArray 图片数组
 @param currentIndex 显示索引
 */
+(void)showVCPicBrowser:(NSMutableArray *)imageArray CurrentIndex:(NSInteger)currentIndex viewController:(UIViewController *)viewController{
    NSMutableArray *photos = [NSMutableArray array];
    for (id asset in imageArray) {
        ZLPhotoPickerBrowserPhoto *photo = [[ZLPhotoPickerBrowserPhoto alloc] init];
        if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
            photo.asset = asset;
        }else if ([asset isKindOfClass:[ZLCamera class]]){
            ZLCamera *camera = (ZLCamera *)asset;
            photo.thumbImage = [camera thumbImage];
        }else if ([asset isKindOfClass:[UIImage class]]){
            photo.thumbImage = (UIImage *)asset;
            photo.photoImage = (UIImage *)asset;
        }else if ([asset isKindOfClass:[NSURL class]]){
            photo.photoURL = (NSURL *)asset;
        }else if ([asset isKindOfClass:[NSString class]]){
            photo.photoURL = [NSURL URLWithString:asset];
        }
        [photos addObject:photo];
    }
    
    ZLPhotoPickerBrowserViewController *browserVc = [[ZLPhotoPickerBrowserViewController alloc] init];
    browserVc.photos = photos;
//    browserVc.delegate = self;
    browserVc.currentIndex = currentIndex;
    if (@available(iOS 13.0, *)) {
        browserVc.modalPresentationStyle = UIModalPresentationFullScreen;
    } else {
        // Fallback on earlier versions
    }
    [browserVc showPickerVc:viewController];
}

/**
 选择图片
 
 @param pickerImage 已选中图片集合
 @param num 最多选择几张
 @param callBackArray 返回事件
 @param picPhotoStatus 相册类型
 @param viewController 容器
 */
+(void)selectedZLPhotoPickerView:(NSMutableArray *)pickerImage PhotoStatus:(PickerPhotoStatus)picPhotoStatus ViewControllser:(UIViewController *)viewController picNum:(NSInteger)num callBackArray:(void(^)(NSArray<ZLPhotoAssets *> *status))callBackArray{
    //添加图片
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    // MaxCount, Default = 9
    pickerVc.maxCount = num;
    // Jump AssetsVc
    pickerVc.status = PickerViewShowStatusCameraRoll;
    // Filter: PickerPhotoStatusAllVideoAndPhotos, PickerPhotoStatusVideos, PickerPhotoStatusPhotos.
    pickerVc.photoStatus = picPhotoStatus;
    // Recoder Select Assets
    pickerVc.selectPickers = pickerImage;
    // Desc Show Photos, And Suppor Camera
    pickerVc.topShowPhotoPicker = YES;
    pickerVc.isShowCamera = picPhotoStatus == PickerPhotoStatusVideos ? NO : YES;
    // CallBack
    pickerVc.callBack = ^(NSArray<ZLPhotoAssets *> *status){
        if (callBackArray) {
            callBackArray(status);
        }
    };
    if (@available(iOS 13.0, *)) {
        pickerVc.modalPresentationStyle = UIModalPresentationFullScreen;
    } else {
        // Fallback on earlier versions
    }
    [pickerVc showPickerVc:viewController];
}
@end
