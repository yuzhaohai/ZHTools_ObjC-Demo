//
//  MyInformationViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "MyInformationViewController.h"
#import "ChangePWDViewController.h"

#import <AliyunOSSiOS/OSSService.h>

@interface MyInformationViewController ()

@property (strong, nonatomic) UITableView *tableView;

@property (copy, nonatomic) NSArray *array;

@end

@implementation MyInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"我的资料";
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.view addSubview:self.tableView];
    
    CGFloat height = SafeAreaHeight * .8 + 44;
    ZHButton *button = [ZHButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenHeight - height, zh_ScreenWidth, height)),
        zh_normalTitleColor: kColor_FFFFFF,
        zh_backgroundColor: kColor_C3C3C3,
        zh_superView: self.view,
        zh_normalTitle: @"退出",
        zh_titleFont: @16,
    }];
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    button.titleRect = CGRectMake(0, 0, zh_ScreenWidth, 44 + SafeAreaHeight * .3);
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)fetchRequest {
    [Util POST:@"/api/User/index" showHUD:YES showResultAlert:YES parameters:@{} result:^(id responseObject) {
        if (responseObject) {
            [AppDelegate appDelegate].userInfo = responseObject;
            
            [self.tableView reloadData];
        }
    }];
}

- (void)tappedButton:(UIButton *)button {
    [AppDelegate appDelegate].userInfo = nil;
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.array.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *array = self.array[section];
    return array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 0 ? 90 : 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
    
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, 0, 168, cell.height)),
            zh_textColor: kColor_000000,
            zh_font: @14
        }];
        
        [cell.button setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(zh_ScreenWidth - 24, 0, 24, cell.height)),
            zh_userInteractionEnabled: @0,
            zh_normalImage: @"more",
        }];
        
        [cell.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(cell.label.right, 0, cell.button.left - cell.label.right, cell.height)),
            zh_textAlignment: @(NSTextAlignmentRight),
            zh_textColor: kColor_808080,
            zh_font: @14,
        }];
        
        [cell.anImageView setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(cell.button.left - 88, 12, 66, 66)),
            zh_contentMode: @(UIViewContentModeScaleAspectFill),
            zh_image: [UIImage zh_appIcon]
        }];
        [cell.anImageView zh_addCornerRadius:33 withCorners:UIRectCornerAllCorners];
    }
    
    NSInteger section = indexPath.section, row = indexPath.row;
    
    NSDictionary *user = [AppDelegate appDelegate].userInfo;
    
    if (section == 0) {
        [cell.anImageView sd_setImageWithURL:[NSURL URLWithString:user[@"head"]]];
    }
    
    NSArray *array = self.array[section];
    NSString *string = array[row];
    
    cell.label.text = string;
    cell.label.height = cell.button.height = section == 0 ? 90 : 44;
    
    cell.aLabel.text = @[(user[kName] ? : @""), @"修改密码"][row];
    cell.aLabel.hidden = section == 0;
    
    cell.anImageView.hidden = section != 0;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section, row = indexPath.row;
    
    if (section == 0) {
        
        [DPublicImageBrowser selectedZLPhotoPickerView:nil PhotoStatus:PickerPhotoStatusPhotos ViewControllser:self picNum:1 callBackArray:^(NSArray<ZLPhotoAssets *> *status) {
            
            [self uploadImage:status[0]];
            
        }];
        
    } else if (row == 0) {
        
        UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"修改用户名" message:nil preferredStyle:UIAlertControllerStyleAlert];
        
        // 添加输入框 (注意:在UIAlertControllerStyleActionSheet样式下是不能添加下面这行代码的)
        [alertVc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入用户名";
        }];
        
        [alertVc addAction:[UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                        
            UITextField *tf = [[alertVc textFields] objectAtIndex:0];
            
            if (tf.text.length < 1) {
                [SVProgressHUD showErrorWithStatus:tf.placeholder];
            } else {
                
                [Util POST:@"/api/User/edit_username" showHUD:YES showResultAlert:YES parameters:@{
                    kName: tf.text
                } result:^(id responseObject) {
                    if (responseObject) {
                        [self fetchRequest];
                    }
                }];
                
            }
            
        }]];
        
        [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        
        [self presentViewController:alertVc animated:YES completion:nil];
        
    } else {
        
        [self.navigationController pushViewController:[ChangePWDViewController new] animated:YES];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [[UIView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 10)];
}

- (void)uploadImage:(ZLPhotoAssets*)assets{
    NSString *bucket = @"gx-head";
    NSString *endpoint = @"https://oss-cn-beijing.aliyuncs.com";
    NSString *accessKeyid = @"LTAI4GCFgWXq9C6osxmtxQkq";
    NSString *secretKeyId = @"LxYJOUR7moly4OJNa5uKTH98EWpR1a";
    NSString *securityToken = @"";// 可空 看后台
    
    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:accessKeyid secretKeyId:secretKeyId securityToken:securityToken];
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    
    __block NSString *fileName = [NSString stringWithFormat:@"%@_%@.jpg", [Util timeStamp], [AppDelegate appDelegate].userInfo[@"id"]];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    put.bucketName = bucket;
    
    //objectKey为云服储存的文件名
    put.objectKey = fileName;
    
    NSData *data = UIImagePNGRepresentation(assets.originImage);
    put.uploadingData = data;
    
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (!task.error) {
                NSLog(@"upload object success!");
                
                [Util POST:@"/api/User/edit_head" showHUD:YES showResultAlert:YES parameters:@{
                    @"head": [NSString stringWithFormat:@"https://%@.oss-cn-beijing.aliyuncs.com/%@", bucket, fileName]
                } result:^(id responseObject) {
                    if (responseObject) {
                        
                    }
                }];
                
            } else {
                
                NSLog(@"upload object failed, error: %@" , task.error);
                
                [SVProgressHUD dismissWithDelay:0];
                [SVProgressHUD showErrorWithStatus:@"文件上传失败..."];
                
            }
            
        });
        
        return nil;
    }];
    
    // 可以等待任务完成
    [putTask waitUntilFinished];
}

#pragma mark -  getter
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1)),
            zh_separatorColor: kColor_EAEAEA,
            zh_backgroundColor: kColor_F5F5F5,
            zh_tableFooterView: [UIView new],
            zh_superView: self.view,
            zh_dataSource: self,
            zh_delegate: self,
        }];
        
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return _tableView;
}

- (NSArray *)array {
    if (!_array) {
        _array = @[@[@"头像"], @[@"用户名", @"账号安全"]];
    }
    return _array;
}

@end
