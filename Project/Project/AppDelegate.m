//
//  AppDelegate.m
//  Project
//
//  Created by YuZhaohai on 2020/6/15.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "AppDelegate.h"

#import <IQKeyboardManager.h>
#import "LoginViewController.h"
#import "TabBarViewController.h"

#import <ShareSDK/ShareSDK.h>
#import <mob_sharesdk/WXApi.h>
#import <mob_sharesdk/WXApiObject.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareSheetConfiguration.h>

#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>

#import <AlipaySDK/AlipaySDK.h>


@interface AppDelegate ()<WXApiDelegate>{
    NSDictionary *_userInfo;
    NSDictionary *_city;
}

@property (nonatomic ,strong)AMapLocationManager *locationManager;

@property (strong, nonatomic) ZHNavigationController *navigationController;

@property (strong, nonatomic) TabBarViewController *tabBarViewController;

@end

@implementation AppDelegate

+ (AppDelegate*)appDelegate {
    return (AppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.leftTime = -1;
    
    [AMapServices sharedServices].apiKey = kAMapApiKey;
    
    [self handleIQKeyboardManager];

    [[UIPasteboard generalPasteboard] setString:@""];

    [SVProgressHUD setMinimumDismissTimeInterval:1.0];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    
    self.window = [[UIWindow alloc] initWithFrame:zh_ScreenBounds];
    [self.window makeKeyAndVisible];
    
    UIViewController *vc = [[UIViewController alloc] init];
    vc.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage zh_launchImage]];
    self.window.rootViewController = vc;
    
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {

        //更新到4.3.3或者以上版本，微信初始化需要使用以下初始化
        [platformsRegister setupWeChatWithAppId:@"wxbb290d121d8d9d7b" appSecret:@"6e93d1f765a32987b158581883497d39" universalLink:@"https://glv58.share2dlink.com/"];
        
    }];
    
    [WXApi registerApp:@"wxbb290d121d8d9d7b" universalLink:@"https://glv58.share2dlink.com/"];
    
//    [self checkIfInReview];
    
    self.window.rootViewController = self.navigationController;
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    
    if ([WXApi handleOpenURL:url delegate:self]) {
        
        return YES;
        
    } else if (([url.host isEqualToString:@"safepay"])) {
        
        //跳转支付宝钱包进行支付，处理支付结果
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
            NSLog(@"appdelegate - %@", resultDic);
            [[NSNotificationCenter defaultCenter] postNotificationName:kAliPayCallBack object:resultDic];
        }];
        
    }
    return  YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler {
    return [WXApi handleOpenUniversalLink:userActivity delegate:self];
}

#pragma mark -  横竖屏
- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
  return UIInterfaceOrientationMaskAllButUpsideDown;
}

#pragma mark -  WXApiDelegate
/*! @brief 收到一个来自微信的请求，第三方应用程序处理完后调用sendResp向微信发送结果
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req {
    
}



/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp *)resp {
    //支付
    if ([resp isKindOfClass:[PayResp class]]) {
        PayResp * response = (PayResp *)resp;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kWXAuthorizationPay object:self userInfo:@{@"code":@(response.errCode)}];
    }
    
    //登录
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        SendAuthResp *aresp = (SendAuthResp *)resp;
        if (aresp.errCode== 0) {
            NSLog(@"code %@",aresp.code);
//            [[NSNotificationCenter defaultCenter] postNotificationName:@"WXAuthorizationLoginSuccess" object:self userInfo:@{@"code":aresp.code}];
        }
    }
    
    //分享
    if([resp isKindOfClass:[SendMessageToWXResp class]]){
        
        SendMessageToWXResp *sendResp = (SendMessageToWXResp *)resp;
        NSString *str = [NSString stringWithFormat:@"%d",sendResp.errCode];
        NSLog(@"微信分享回调%@",str);
        
        /*
         WXSuccess           = 0,   成功
        WXErrCodeCommon     = -1,   普通错误类型
        WXErrCodeUserCancel = -2,   用户点击取消并返回
        WXErrCodeSentFail   = -3,   发送失败
        WXErrCodeAuthDeny   = -4,   授权失败
        WXErrCodeUnsupport  = -5,   微信不支持
         */
    }
}

#pragma mark -  IQKeyboardManager
- (void)handleIQKeyboardManager {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];

    manager.enable = YES;

    manager.shouldResignOnTouchOutside = YES;

    manager.shouldToolbarUsesTextFieldTintColor = YES;
}

#pragma mark -  setter
- (void)setUserInfo:(NSDictionary *)userInfo {
    self.needRefresh = YES;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        
        NSMutableDictionary *info = [userInfo mutableCopy];
        info[@"token"] = info[@"token"] ? : _userInfo[@"token"];
                
        [userDefaults setObject:info forKey:kUserInfo];
        [userDefaults synchronize];
        
        _userInfo = info;
        
        if (self.window.rootViewController != self.navigationController) {
            self.window.rootViewController = self.navigationController;
        }
                
    } else {
        
        [userDefaults removeObjectForKey:kUserInfo];
        [userDefaults synchronize];
        
        _userInfo = nil;
                
        [self.navigationController popToRootViewControllerAnimated:NO];
        
        self.tabBarViewController.selectedIndex = 0;
        
    }
}

#pragma mark -  login
- (void)login {
    [self.navigationController pushViewController:[LoginViewController new] animated:YES];
}

#pragma mark -  检查是否在审核
- (void)checkIfInReview {
//    [Util POST:@"/api/index/avoid" showHUD:NO showResultAlert:NO parameters:@{} result:^(id responseObject) {
//        if (responseObject) {
//            self.flag = [responseObject[@"value"] boolValue];
//        }
//
//        if (self.userInfo) {
//
//            [self checkToken];
//
//        } else {
//
//            [self login];
//
//        }
//    }];
}

#pragma mark -  校验token
- (void)checkToken {
    
//    [Util POST:@"/api/user/myinfo" showHUD:NO showResultAlert:NO parameters:@{} result:^(id responseObject) {
//
//        if (responseObject) {
//
//            NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:responseObject];
//            info[@"token"] = self.userInfo[@"token"];
//
//            self.userInfo = info;
//
//        } else {
//
//            self.userInfo = nil;
//            [SVProgressHUD showErrorWithStatus:@"登录失效，请重新登录"];
//
//        }
//
//    }];
    
}

- (void)locationWithHUD:(BOOL)hud successBlock:(void (^)(CLLocation *, AMapLocationReGeocode *))block {
    if([CLLocationManager locationServicesEnabled] && [CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied) {
        
        if (!self.locationManager) {
            self.locationManager = [[AMapLocationManager alloc] init];
            //最精确的,相差几米,但是时间10s
            [self.locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
            self.locationManager.locationTimeout = 2;
            self.locationManager.reGeocodeTimeout = 2;
        }
                
        if (hud) {
            [SVProgressHUD show];
        }
        
        [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            
            [SVProgressHUD dismissWithDelay:0];
                    
            if (regeocode) {
                //formattedAddress:山东省临沂市兰山区府右路靠近临沂市科技馆;
                //country:中国;province:山东省; city:临沂市; district:兰山区; citycode:0539; adcode:371302; street:府右路; number:4号;
                //POIName:临沂市科技馆; AOIName:临沂市科技馆;
                
                self.regeocode = regeocode;
                self.location = location;
                
                if (block) {
                    block(location, regeocode);
                }
                
            } else {
                
                [SVProgressHUD showErrorWithStatus:@"定位失败!"];
                                
            }
            
        }];
        
    } else {
        
        [ZHAlertController alertTitle:@"提示" message:@"需要开启定位服务,请到设置->隐私,打开定位服务" cancleButtonTitle:@"确定"];
        
    }
}

- (void)setCity:(NSDictionary *)city {
    _city = city;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:city forKey:kCity];
    [userDefaults synchronize];
}

#pragma mark -  getters
- (ZHNavigationController *)navigationController {
    if (!_navigationController) {
        _navigationController = [[ZHNavigationController alloc] initWithRootViewController:self.tabBarViewController];
    }
    return _navigationController;
}

- (TabBarViewController *)tabBarViewController {
    if (!_tabBarViewController) {
        _tabBarViewController = [TabBarViewController new];
    }
    return _tabBarViewController;
}

- (NSDictionary *)userInfo {
    if (!_userInfo) {
        _userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kUserInfo];
    }
    return _userInfo;
}

- (NSDictionary *)city {
    if (!_city) {
        _city = [[NSUserDefaults standardUserDefaults] objectForKey:kCity];
    }
    return _city;
}

@end
