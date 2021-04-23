//
//  GoodsDetailViewController.m
//  Project
//
//  Created by 于兆海 on 2021/2/1.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "GoodsDetailViewController.h"
#import "ShopViewController.h"
#import "SpecSelectView.h"
#import "DDPageControl.h"
#import "PurchaseListViewController.h"
@import AVFoundation;
@import AVKit;
#import <ShareSDK/ShareSDK.h>
#import <mob_sharesdk/WXApi.h>
#import <mob_sharesdk/WXApiObject.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareSheetConfiguration.h>

@interface GoodsDetailViewController ()<WKNavigationDelegate, WKUIDelegate, WKScriptMessageHandler>

@property (copy, nonatomic) NSString *goodsID;
@property (copy, nonatomic) NSDictionary *info;

@property (copy, nonatomic) NSArray *couponArray;

@property (strong, nonatomic) ZHButton *selectedButton;

@property (strong, nonatomic) UIView *tableView;
@property (strong, nonatomic) UIView *goodsView;

@property (strong, nonatomic) WKWebView *webView;

@property (strong, nonatomic) UIView *footer;

@property (strong, nonatomic) ZHButton *collectButton;

@property (strong, nonatomic) DDPageControl *pageControl;
@property (strong, nonatomic) UICollectionView *imageCollectionView;

@property (copy, nonatomic) NSArray *imageInfoArray;

@property (strong, nonatomic) AVPlayerViewController *avPlayerViewController;

@property (strong, nonatomic) UITextView *priceView;
@property (strong, nonatomic) UILabel *label;

@property (strong, nonatomic) UILabel *nameLabel;

@property (strong, nonatomic) UILabel *numberLabel;

@property (strong, nonatomic) UILabel *saleAmountLabel;

@end

@implementation GoodsDetailViewController

- (instancetype)initWithID:(NSString *)goodsID {
    self = [super init];
    if (self) {
        self.goodsID = goodsID;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    
    [@[@"商品", @"详情"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth / 2.0, zh_StatusBar_HEIGHT, 66, zh_NavigationBar_HEIGHT)),
            zh_normalTitleColor: kColor_808080,
            zh_selectedTitleColor: kColor_Red,
            zh_superView: self.topBar,
            zh_selectedTitle: obj,
            zh_normalTitle: obj,
            zh_titleFont: @16,
            zh_tag: @(idx),
            
            zh_normalImage: [UIImage zh_imageWithColor:[UIColor whiteColor] size:CGSizeMake(36, 2)],
            
            zh_selectedImage: [UIImage zh_imageWithColor:[UIColor zh_colorWithHexString:kColor_Red] size:CGSizeMake(36, 2)],
        }];
        button.titleLabel.textAlignment = NSTextAlignmentCenter;
        button.titleRect = CGRectMake(0, 0, 66, button.height - 3);
        button.imageRect = CGRectMake(15, button.height - 3, 36, 2);
        [button addTarget:self action:@selector(tappedTopButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (idx == 0) {
            button.left = zh_ScreenWidth / 2.0 - 66;
            self.selectedButton = button;
            button.selected = YES;
        }
    }];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"wechat://"]] ) {
        [self.rightNavigationButton setImage:[UIImage imageNamed:@"分享"] forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.info) {
        [self fetchRequest];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if (self.avPlayerViewController) {
        [self.avPlayerViewController.player pause];
    }
}

- (void)fetchRequest {
    [Util POST:@"/api/Index/goods_info" showHUD:YES showResultAlert:YES parameters:@{
        @"goods_id": (self.goodsID ? : @""),
    } result:^(id responseObject) {
        if (responseObject) {
            self.info = responseObject;
            
            self.isXianShiGou = [responseObject[@"ms_end_time"] integerValue] > 10000;
            
            if (self.couponArray.count < 1 && (!self.footer.superview)) {
                
                [self fetchCouponArray];
                
            } else {
                
                [self setViewProperty];
                
            }
        }
    }];
}

- (void)fetchCouponArray {
    [Util POST:@"/api/Index/shop_coupon" showHUD:YES showResultAlert:YES parameters:@{
        @"shop_id": self.info[@"shop_id"],
    } result:^(id responseObject) {
        self.couponArray = responseObject;
        
        [self.view addSubview:self.webView];
        [self.view addSubview:self.tableView];
        [self.view addSubview:self.footer];
        
        [self setViewProperty];
    }];
}

- (void)setViewProperty {
    self.imageInfoArray = self.info[@"imgs"];
    self.nameLabel.text = self.info[kName];
    self.numberLabel.text = [NSString stringWithFormat:@"货号：%@", self.info[@"good_number"]];
    self.saleAmountLabel.text = [NSString stringWithFormat:@"月售：%@", self.info[@"sale"]];
    
    BOOL is_collect = [self.info[@"is_collect"] boolValue];
    [self.collectButton setPropertyWithDictionary:@{
        zh_normalImage: (is_collect ? @"商品收藏" : @"收藏"),
        zh_normalTitleColor: (is_collect ? @"F65E37" : kColor_333333),
    }];
    
    [self.webView loadHTMLString:self.info[@"content"] baseURL:nil];
    
    [self.imageCollectionView reloadData];
}

- (void)tappedTopButton:(ZHButton *)button {
    if (!button.selected) {
        self.selectedButton.selected = NO;
        
        button.selected = YES;
        self.selectedButton = button;
    }
    
    UIView *view = button.tag == 0 ? self.tableView : self.webView;
    [self.view bringSubviewToFront:view];
    
    if (button.tag > 0) {
        [self.avPlayerViewController.player pause];
    }
}

- (void)rightNavigationButtonAction {
    NSMutableArray *array = [NSMutableArray array];
    for (NSDictionary *info in self.info[@"imgs"]) {
        [array addObject:info[@"image"]];
    }
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:self.info[kName]
                                         images:array
                                            url:[NSURL URLWithString:@"http://guoxinmall.cn/guoxin_share/"]
                                          title:self.info[@"shop_name"]
                                           type:SSDKContentTypeAuto];

        SSUIShareSheetConfiguration *config = [[SSUIShareSheetConfiguration alloc] init];
        //设置竖屏有多少个item平台图标显示
        config.columnPortraitCount = 2;

        [ShareSDK showShareActionSheet:nil customItems:@[@(SSDKPlatformSubTypeWechatSession),@(SSDKPlatformSubTypeWechatTimeline)] shareParams:shareParams sheetConfiguration:config onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {

            switch (state) {

                case SSDKResponseStateSuccess:
                    NSLog(@"成功");//成功
                    [ZHAlertController alertTitle:@"分享成功" message:@"" cancleButtonTitle:@"确定"];
                    break;
                case SSDKResponseStateFail:
                {
                    NSLog(@"--%@",error.description);
                    //失败
                    [ZHAlertController alertTitle:@"分享失败" message:@"" cancleButtonTitle:@"确定"];
                    break;
                }
                case SSDKResponseStateCancel:
                    break;
                default:
                    break;
            }
        }];
}

- (void)tappedFooterButton:(UIButton *)button {
    [self.avPlayerViewController.player pause];
    
    NSArray *array = @[@"客服", @"店铺", @"收藏", @"加入进货单", @"前往进货单", @"立即购买"];
    
    NSInteger index = [array indexOfObject:button.titleLabel.text];
    if (index > 2 && (![AppDelegate appDelegate].userInfo)) {
        [[AppDelegate appDelegate] login];
    }
    
    switch (index) {
        case 0:{
            
            NSString *kefu = self.info[@"kefu"];
            if (kefu.length > 2) {
                [kefu zh_call];
            }
            
            break;
        }
        case 1:{
            
            ShopViewController *vc = [[ShopViewController alloc] initWithShop:@{@"shop_id": self.info[@"shop_id"], kName: (self.info[@"shop_name"] ? : @"")}];
            [self.navigationController pushViewController:vc animated:YES];
            
            break;
        }
        case 2:{
            
            if ([AppDelegate appDelegate].userInfo) {
                
                [Util POST:@"/api/User/user_collect" showHUD:YES showResultAlert:YES parameters:@{
                    @"type": @1,
                    @"other_id": self.info[@"id"],
                    @"status": ([self.info[@"is_collect"] boolValue] ? @2 : @1)
                } result:^(id responseObject) {
                    if (responseObject) {
                        [self fetchRequest];
                    }
                }];
                
            } else {
                [[AppDelegate appDelegate] login];
            }
            
            break;
        }
        case 4:{
            [[ZHTools getCurrentViewController].navigationController pushViewController:[[PurchaseListViewController alloc] initWithNoTabbar] animated:YES];
            break;
        }
        default:{
            
            if ([self.info[@"on_sale"] boolValue]) {
                SpecSelectView *view = [[SpecSelectView alloc] initWithGoodsInfo:self.info];
                [view showInView:self.view];
            }
            
            break;
        }
    }
}

#pragma mark -  getter
- (UIView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom, zh_ScreenWidth, self.footer.top - self.topBar.bottom)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_tableFooterView: self.goodsView
        }];
    }
    return _tableView;
}

- (UIView *)goodsView {
    if (!_goodsView) {
        _goodsView = [[UIView alloc] initWithFrame:CGRectMake(0, self.topBar.bottom, zh_ScreenWidth, 0)];
        _goodsView.backgroundColor = [UIColor whiteColor];
        
        [_goodsView addSubview:self.imageCollectionView];
        [_goodsView addSubview:self.pageControl];
        
        [_goodsView addSubview:self.priceView];
        [_goodsView addSubview:self.nameLabel];
        [_goodsView addSubview:self.numberLabel];
        [_goodsView addSubview:self.saleAmountLabel];
        
        CGFloat top = self.numberLabel.bottom + 8;
        if (!self.isXianShiGou && self.couponArray.count > 0) {
            
            NSMutableString *string = [NSMutableString stringWithString:@"本店铺购"];
            
            for (NSDictionary *info in self.couponArray) {
                BOOL flag = [info[@"type_two"] integerValue] == 0;
                
                [string appendFormat:@"满%.0f%@%@  ", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])];
            }
            
            ZHButton *button = [ZHButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, top, zh_ScreenWidth, 33)),
                zh_normalTitleColor: kColor_FFFFFF,
                zh_backgroundColor: @"#FF7E30",
                zh_normalTitle: string,
                zh_superView: _goodsView,
                zh_normalImage: @"more_white",
                zh_titleFont: @13,
            }];
            button.titleRect = CGRectMake(10, 0, zh_ScreenWidth - 10 - 7 - 10, 33);
            button.imageRect = CGRectMake(zh_ScreenWidth - 10 - 7, 13, 7, 7);
            
            [button zh_addTapGestureRecognizerWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                
                NSMutableString *string = [NSMutableString string];
                
                for (NSDictionary *info in self.couponArray) {
                    BOOL flag = [info[@"type_two"] integerValue] == 0;
                    
                    [string appendFormat:@"满%.0f%@%@\n", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])];
                }
                
                if (string.length > 0) {
                    
                    [ZHAlertController alertTitle:@"" message:string cancleButtonTitle:@"确定"];
                    
                }
                
            }];
            
            top = button.bottom;
        }
        
        ZHButton *button = [ZHButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, top, zh_ScreenWidth, 44)),
            zh_normalTitleColor: kColor_666666,
            zh_normalTitle: @"选择产品规格",
            zh_superView: _goodsView,
            zh_normalImage: @"more",
            zh_titleFont: @14,
            zh_borderWidth: @1,
            zh_borderColor: kColor_F5F5F5,
            zh_tag: @3
        }];
        [button addTarget:self action:@selector(tappedFooterButton:) forControlEvents:UIControlEventTouchUpInside];
        button.titleRect = CGRectMake(10, 0, 168, 44);
        button.imageRect = CGRectMake(zh_ScreenWidth - 10 - 7, 18.5, 7, 7);
        
        self.goodsView.height = button.bottom;
    }
    return _goodsView;
}

- (WKWebView *)webView {
    if (!_webView) {
        NSString *jScript = @"var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta); var imgs = document.getElementsByTagName('img');for (var i in imgs){imgs[i].style.maxWidth='100%';imgs[i].style.height='auto';}";
        
        WKUserScript *wkUScript = [[WKUserScript alloc] initWithSource:jScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
        
        WKUserContentController *wkUController = [[WKUserContentController alloc] init];
        
        [wkUController addScriptMessageHandler:self name:@"loadComplete"];
        
        [wkUController addUserScript:wkUScript];
        
        WKWebViewConfiguration *wkWebConfig = [[WKWebViewConfiguration alloc] init];
        
        wkWebConfig.userContentController = wkUController;
        
        _webView = [[WKWebView alloc] initWithFrame:self.tableView.frame configuration:wkWebConfig];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
    }
    return _webView;
}

- (UIView *)footer {
    if (!_footer) {
        CGFloat height = SafeAreaHeight + 49;
        _footer = [[UIView alloc] initWithFrame:CGRectMake(0, zh_ScreenHeight - height, zh_ScreenWidth, height)];
        
        [@[@"客服", @"店铺", @"收藏"] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            ZHButton *button = [ZHButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(idx * 49, 0, 49, 49)),
                zh_normalTitleColor: kColor_333333,
                zh_superView: _footer,
                zh_normalTitle: obj,
                zh_normalImage: obj,
                zh_titleFont: @12,
                zh_tag: @(idx),
            }];
            [button addTarget:self action:@selector(tappedFooterButton:) forControlEvents:UIControlEventTouchUpInside];
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            button.titleRect = CGRectMake(0, 7 + 19 + 4, 49, 13);
            button.imageRect = CGRectMake(15, 7, 19, 19);
            
            if (idx == 2) {
                self.collectButton = button;
            }
        }];
        
        CGFloat left = 49 * 3;
        CGFloat width = ceil((zh_ScreenWidth - left) / 2.0);
        UIButton *button = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(left, 0, width, 49)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: @"#FF7E30",
            zh_normalTitle: @"加入进货单",
            zh_superView: _footer,
            zh_titleFont: @16,
            zh_tag: @3
        }];
        [button addTarget:self action:@selector(tappedFooterButton:) forControlEvents:UIControlEventTouchUpInside];
        
        button = [UIButton viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(button.right, 0, width, 49)),
            zh_normalTitleColor: kColor_FFFFFF,
            zh_backgroundColor: kColor_Red,
            zh_normalTitle: @"前往进货单",
            zh_superView: _footer,
            zh_titleFont: @16,
            zh_tag: @4
        }];
        [button addTarget:self action:@selector(tappedFooterButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.isXianShiGou) {
            button.frame = CGRectMake(left, 0, width * 2, 49);
            [button setTitle:@"立即购买" forState:UIControlStateNormal];
        }
        
        if (![self.info[@"on_sale"] boolValue]) {
            [button setPropertyWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(left, 0, width * 2, 49)),
                zh_backgroundColor: kColor_999999,
                zh_normalTitle: @"商品失效"
            }];
        }
    }
    return _footer;
}

- (UICollectionView *)imageCollectionView {
    if (!_imageCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 1;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, zh_ScreenWidth) collectionViewLayout:layout];
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        
        [collectionView setPropertyWithDictionary:@{
            zh_showsHorizontalScrollIndicator: @0,
            zh_showsVerticalScrollIndicator: @0,
            zh_backgroundColor: kColor_FFFFFF,
            zh_pagingEnabled: @1,
            zh_scrollEnabled: @1,
            zh_dataSource: self,
            zh_delegate: self
        }];
        
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        _imageCollectionView = collectionView;
    }
    return _imageCollectionView;
}

- (DDPageControl *)pageControl {
    if (!_pageControl) {
        DDPageControl *pageControl = [[DDPageControl alloc] init];
        [pageControl setCenter:CGPointMake(self.imageCollectionView.centerX, self.imageCollectionView.bottom - 10)];
        [pageControl setNumberOfPages:2];
        [pageControl setCurrentPage:0];
        [pageControl setOnColor:[UIColor zh_colorWithHexString:kColor_Main]];
        [pageControl setOffColor:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
        pageControl.type = DDPageControlTypeOnFullOffFull;
        
        pageControl.didChange = ^(DDPageControl *pageControl) {
            
            [self.imageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:pageControl.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
            
        };
        
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (AVPlayerViewController *)avPlayerViewController {
    NSString *webVideoPath = self.info[@"video"];
    
    if (!_avPlayerViewController && webVideoPath) {
        NSURL *webVideoUrl = [NSURL URLWithString:webVideoPath];
        AVPlayer *avPlayer = [[AVPlayer alloc] initWithURL:webVideoUrl];
        AVPlayerViewController *avPlayerVC = [[AVPlayerViewController alloc] init];
        avPlayerVC.player = avPlayer;
        avPlayerVC.view.frame = self.imageCollectionView.bounds;
        [self addChildViewController:avPlayerVC];
        
        [avPlayer play];
        
        _avPlayerViewController = avPlayerVC;
    }
    return _avPlayerViewController;
}

- (UITextView *)priceView {
    if (!_priceView) {
        _priceView = [UITextView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenWidth, zh_ScreenWidth, (self.isXianShiGou ? 55 : 36))),
            zh_backgroundColor: (self.isXianShiGou ? kColor_Red : kColor_FFFFFF),
            zh_userInteractionEnabled: @0,
        }];
        
        if (self.isXianShiGou) {
            
            NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"¥" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor whiteColor]}];
            [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@", self.info[@"min_price"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:21], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
            [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n¥%@", self.info[@"max_price"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor whiteColor]}]];
            _priceView.attributedText = aString;
            
            UILabel *label = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 10 - 100, 9, 100, 12)),
                zh_textAlignment: @(NSTextAlignmentCenter),
                zh_textColor: kColor_FFFFFF,
                zh_superView: _priceView,
                zh_text: @"距离结束",
                zh_font: @12,
            }];
            
            self.label = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 10 - 100, label.bottom + 3, 100, 21)),
                zh_textAlignment: @(NSTextAlignmentCenter),
                zh_backgroundColor: kColor_FFFFFF,
                zh_textColor: kColor_Red,
                zh_superView: _priceView,
                zh_text: @"03：22：34",
                zh_font: @14,
            }];
            [self.label zh_addCornerRadius:4 withCorners:UIRectCornerAllCorners];
            
            [self resetTime:self];
            
        } else {
            
            _priceView.attributedText = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"¥%@ - ¥%@", self.info[@"min_price"], self.info[@"max_price"]] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:21], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
            
        }
        _priceView.textContainerInset = UIEdgeInsetsMake(8, 10, 0, 10);
    }
    return _priceView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, self.priceView.bottom + 10, zh_ScreenWidth - 20, 52.1 - 20)),
            zh_backgroundColor: kColor_FFFFFF,
            zh_textColor: kColor_333333,
            zh_numberOfLines: @2,
            zh_font: @14,
        }];
        
    }
    return _nameLabel;
}

- (UILabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, self.nameLabel.bottom + 10, 98, 21)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_borderColor: kColor_Red,
            zh_textColor: kColor_Red,
            zh_masksToBounds: @1,
            zh_borderWidth: @1,
            zh_font: @13
        }];
    }
    return _numberLabel;
}

- (UILabel *)saleAmountLabel {
    if (!_saleAmountLabel) {
        _saleAmountLabel = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.numberLabel.right, self.numberLabel.top, zh_ScreenWidth - 10 - self.numberLabel.right, self.numberLabel.height)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_textColor: kColor_333333,
            zh_font: @13,
        }];
    }
    return _saleAmountLabel;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    NSInteger amount = self.imageInfoArray.count > 0 ? self.imageInfoArray.count : 1;
    
    if (self.avPlayerViewController) {
        amount += 1;
    }
    
    [self.pageControl setNumberOfPages:amount];
    
    return amount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger item = indexPath.item;
    
    static NSString *Identifier = @"UICollectionViewCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    NSInteger tag = 5201314;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:tag];
    
    if (!imageView) {
        imageView = [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, collectionView.height)),
            zh_contentMode: @(UIViewContentModeScaleToFill),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: cell.contentView,
            zh_tag: @(tag)
        }];
        
        cell.backgroundColor = [UIColor whiteColor];
    }
    
    NSInteger index = item;
    if (self.avPlayerViewController) {
        if (item == 0) {
            [cell addSubview:self.avPlayerViewController.view];
        }
        
        index -= 1;
    }
    
    if (self.imageInfoArray.count > index && index >= 0) {
        
        NSDictionary *info = self.imageInfoArray[index];
        [imageView sd_setImageWithURL:[NSURL URLWithString:info[@"image"]]];
        
    } else {
        
        imageView.image = [UIImage zh_appIcon];
        
    }
        
    return cell;
}

#pragma mark didSelect
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger item = indexPath.item;
    
    if (item == 0) {
        if (self.avPlayerViewController.player.rate == 1.0) {
            
            [self.avPlayerViewController.player pause];
            
        } else {
            
            [self.avPlayerViewController.player play];
            
        }
    }
}

//定义每个Cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return collectionView.frame.size;
    
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    
    return UIEdgeInsetsZero;//分别为上、左、下、右
}

//两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
}

//两列cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeZero;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = collectionView.contentOffset.x / collectionView.width;
    self.pageControl.currentPage = index;
    
    
    [[self class] cancelPreviousPerformRequestsWithTarget:self];
    
    if (index == 0) {
        
        self.avPlayerViewController.view.hidden = NO;
        [self.avPlayerViewController.player play];
        
    } else {
        
        self.avPlayerViewController.view.hidden = YES;
        [self.avPlayerViewController.player pause];
        
        [self performSelector:@selector(changeImage) withObject:nil afterDelay:4];
        
    }
}

#pragma mark -  轮播
- (void)changeImage{
    if (self.imageInfoArray.count > 1) {
        NSInteger index = self.pageControl.currentPage + 1;
        BOOL animated = YES;
        
        if (index == self.imageInfoArray.count) {
            animated = NO;
            index = 0;
        }
        
        [self.imageCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:animated];
    }
}

- (void)resetTime:(GoodsDetailViewController *)vc {
    int leftTime = [AppDelegate appDelegate].leftTime;
    int seconds = leftTime % 60;
    int minutes = (leftTime / 60) % 60;
    int hours = leftTime / 3600;
    self.label.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        
    [self zh_performBlock:^{
        [self resetTime:self];
    } afterDelay:1];
}

#pragma mark -  WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
}

#pragma mark -  WKUIDelegate
/// 创建新的webView时调用的方法 blank
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures {
    NSLog(@"%s",__FUNCTION__);
    
    return webView;
}


/// 关闭webView时调用的方法
- (void)webViewDidClose:(WKWebView *)webView {
    NSLog(@"%s",__FUNCTION__);
}


/// 警告框
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    
    // 确定按钮
    UIAlertAction *alertAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 确认框
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    
    // 按钮
    UIAlertAction *alertActionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        // 返回用户选择的信息
        completionHandler(NO);
    }];
    UIAlertAction *alertActionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:alertActionCancel];
    [alertController addAction:alertActionOK];
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 输入框
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    
    // alert弹出框
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:prompt message:nil preferredStyle:UIAlertControllerStyleAlert];
    // 输入框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    // 确定按钮
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        // 返回用户输入的信息
        UITextField *textField = alertController.textFields.firstObject;
        completionHandler(textField.text);
    }]];
    // 显示
    [self presentViewController:alertController animated:YES completion:nil];
}

/// 能否预览用户触摸的元素
//- (BOOL)webView:(WKWebView *)webView shouldPreviewElement:(WKPreviewElementInfo *)elementInfo

/// 定制预览控制器
//- (UIViewController *)webView:(WKWebView *)webView previewingViewControllerForElement:(WKPreviewElementInfo *)elementInfo defaultActions:(NSArray<id<WKPreviewActionItem>> *)previewActions

/// 可弹出的视图控制器
//- (void)webView:(WKWebView *)webView commitPreviewingViewController:(UIViewController *)previewingViewController

#pragma mark -  WKNavigationDelegate
/// 发送请求之前,决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSLog(@"%s",__FUNCTION__);
    /**
     *typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
     WKNavigationActionPolicyCancel, // 取消
     WKNavigationActionPolicyAllow,  // 继续
     }
     */
    decisionHandler(WKNavigationActionPolicyAllow);
}

/// 发送请求之前,决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction preferences:(WKWebpagePreferences *)preferences decisionHandler:(void (^)(WKNavigationActionPolicy, WKWebpagePreferences * _Nonnull))decisionHandler  API_AVAILABLE(ios(13.0)){
    NSLog(@"%s",__FUNCTION__);
    /**
     *typedef NS_ENUM(NSInteger, WKNavigationActionPolicy) {
     WKNavigationActionPolicyCancel, // 取消
     WKNavigationActionPolicyAllow,  // 继续
     }
     */
    decisionHandler(WKNavigationActionPolicyAllow, preferences);
}

/// 收到响应后,决定是否跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    NSLog(@"%s",__FUNCTION__);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
}

/// 接收到服务器跳转请求之后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
}

/// 页面加载失败时调用
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@", error.localizedDescription);
}

/// 当内容开始返回时调用
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
}

/// 页面加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
    
    NSString *js = @"function imgAutoFit() { \
        var imgs = document.getElementsByTagName('img'); \
        for (var i = 0; i < imgs.length; ++i) {\
           var img = imgs[i];   \
           img.style.minWidth = %f;   \
        } \
     }";
     js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width - 20];
    
    [webView evaluateJavaScript:js completionHandler:nil];
    [webView evaluateJavaScript:@"imgAutoFit()" completionHandler:^(id _Nullable bbb, NSError * _Nullable error) {
        
    }];
}

/// 导航错误
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    NSLog(@"%s",__FUNCTION__);
    NSLog(@"%@", error.localizedDescription);
}

/// 身份验证
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    NSLog(@"%s",__FUNCTION__);
    // 不要证书验证
    completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
}

/// WKWebView终止
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    NSLog(@"%s",__FUNCTION__);
}

@end
