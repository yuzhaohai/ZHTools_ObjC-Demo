//
//  LKWebViewController.m
//  Project
//
//  Created by 于兆海 on 2020/11/5.
//  Copyright © 2020 LaiKe. All rights reserved.
//

#import "LKWebViewController.h"

@interface LKWebViewController ()<WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIProgressView *progressView; ///< 进度条

@end

@implementation LKWebViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.showProgress = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.webView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    
    if (self.urlAddress) {
        NSURL *url = [NSURL URLWithString:[self.urlAddress stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];        
        [self.webView loadRequest:request];
    }
    
    if (self.htmlString) {
        NSString *htmlHeader = @"<header><meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'></header>";
        [self.webView loadHTMLString:[htmlHeader stringByAppendingString:self.htmlString] baseURL:nil];
    }
    
    [self.leftNavigationButton setImage:[UIImage imageNamed:@"返回"] forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
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
    
    NSLog(@"%@", navigationAction);
    
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
    
    NSLog(@"%@", navigationAction);
    
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
    
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id object, NSError * error) {
        if (!self.navigationTitleLabel.text && [object isKindOfClass:[NSString class]] && ((NSString *)object).length > 0) {
            self.navigationTitleLabel.text = object;
        }
    }];
}

/// 页面加载完成时调用
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    NSLog(@"%s",__FUNCTION__);
    
    NSString *js = @"function imgAutoFit() { \
        var imgs = document.getElementsByTagName('img'); \
        for (var i = 0; i < imgs.length; ++i) {\
           var img = imgs[i];   \
           img.style.maxWidth = %f;   \
        } \
     }";
     js = [NSString stringWithFormat:js, [UIScreen mainScreen].bounds.size.width - 20];
    
    [webView evaluateJavaScript:js completionHandler:nil];
    [webView evaluateJavaScript:@"imgAutoFit()" completionHandler:nil];
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

#pragma mark -  getter
- (WKWebView *)webView {
    if (!_webView) {
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)];
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        
        _webView.scrollView.delegate = self;
    }
    return _webView;
}

- (UIProgressView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, self.topBar.bottom, zh_ScreenWidth, 2)];
        [_progressView setProgressViewStyle:UIProgressViewStyleDefault]; //设置进度条类型
        [self.view addSubview:_progressView];
    }
    return _progressView;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    // 进度条
    if ([@"estimatedProgress" isEqualToString:keyPath]) {
        NSLog(@"%f", self.webView.estimatedProgress);
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
        // 初始和终止状态
        if (self.progressView.progress == 0) {
            self.progressView.hidden = NO;
        } else if (self.progressView.progress == 1) {
            // 1秒后隐藏
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 再次判断，防止正在加载时隐藏
                if (self.progressView.progress == 1) {
                    self.progressView.progress = 0;
                    self.progressView.hidden = YES;
                }
            });
        }
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    scrollView.contentOffset = CGPointMake(0, point.y);
}

@end
