//
//  LKWebViewController.h
//  Project
//
//  Created by 于兆海 on 2020/11/5.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "BaseViewController.h"
@import WebKit;

NS_ASSUME_NONNULL_BEGIN

@interface LKWebViewController : BaseViewController

@property (copy, nonatomic) NSString *postURL;
@property (copy, nonatomic) NSDictionary *postParameter;
@property (copy, nonatomic) NSArray *parseKeys;

@property (assign, nonatomic) BOOL showProgress;

@property (strong, nonatomic) WKWebView *webView;

@property (copy, nonatomic) NSString *urlAddress;

@property (copy, nonatomic) NSString *htmlString;

@end

NS_ASSUME_NONNULL_END
