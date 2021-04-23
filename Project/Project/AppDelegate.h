//
//  AppDelegate.h
//  Project
//
//  Created by YuZhaohai on 2020/6/15.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CLLocation;
@class AMapLocationReGeocode;
@class TabBarViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (assign, nonatomic) BOOL needRefresh;

@property (strong, nonatomic) UIWindow *window;

@property (copy, nonatomic) NSDictionary *userInfo;

@property (assign, nonatomic) BOOL allowRotation;

@property (copy, nonatomic) NSDictionary *city;

@property (assign, nonatomic) int leftTime;

+ (AppDelegate *)appDelegate;

- (void)login ;

@property (assign, nonatomic) BOOL flag;

@property (copy, nonatomic) CLLocation *location;
@property (copy, nonatomic) AMapLocationReGeocode *regeocode;
- (void)locationWithHUD:(BOOL)hud successBlock:(void (^)(CLLocation *location, AMapLocationReGeocode *regeocode))block;

@end

