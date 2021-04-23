//
//  EditAddressViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/26.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "EditAddressViewController.h"

@interface EditAddressViewController ()<UITextFieldDelegate, UITextViewDelegate>

@property (copy, nonatomic) NSDictionary *address;

@property (copy, nonatomic) NSMutableArray *viewArray;
@property (copy, nonatomic) NSArray *keyArray;

@property (strong, nonatomic) ZHAlertController *addressPickerController;

@property (copy, nonatomic) NSString *province;
@property (copy, nonatomic) NSString *city;
@property (copy, nonatomic) NSString *district;
@property (copy, nonatomic) NSString *districtID;

@property (copy, nonatomic) NSArray *addressArray;

@end

@implementation EditAddressViewController

- (instancetype)initWithAddress:(NSDictionary *)address {
    self = [super init];
    if (self) {
        self.address = address;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = (self.address ? @"编辑收货地址" : @"新增收货地址");
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    NSArray *array = @[@"收货人", @"手机号", @"所在地区", @"详细地址： 如道路，门牌号，小区，楼道号", @"设为默认地址"];
    NSArray *aArray = @[@"请输入收货人", @"请输入手机号", @"请选择所在地区"];
    
    for (int i = 0; i < array.count; i++) {
        
        NSString *value = self.address ? self.address[self.keyArray[i]] : @"";
        
        if (i < 3) {
            
            UITextField *tf = [UITextField viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 10 + 57 * i, zh_ScreenWidth, 56)),
                zh_backgroundColor: kColor_FFFFFF,
                zh_textAlignment: @(NSTextAlignmentRight),
                zh_rightViewMode: @(UITextFieldViewModeAlways),
                zh_leftViewMode: @(UITextFieldViewModeAlways),
                zh_textColor: kColor_333333,
                zh_superView: self.view,
                zh_font: @14,
                zh_text: value,
                zh_leftView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 56)],
                zh_rightView: [[UIView alloc] initWithFrame:CGRectMake(0, 0, 20, 56)],
                zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:aArray[i] attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_999999]}],
            }];
            
            [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(15, 0, 88 - 20, 56)),
                zh_textColor: kColor_333333,
                zh_text: array[i],
                zh_superView: tf,
                zh_font: @14,
            }];
            
            [self.viewArray addObject:tf];
            
            if (i == 2 && value.length > 0) {
                tf.text = [NSString stringWithFormat:@"%@%@%@\n", self.address[@"province"], self.address[@"city"], self.address[@"district"]];
                
                self.districtID = self.address[@"district_id"];
            }
            
        } else if (i == 3) {
            
            UITextView *textView = [UITextView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom + 10 + 57 * 3, zh_ScreenWidth, 120)),
                zh_backgroundColor: kColor_FFFFFF,
                zh_textColor: kColor_333333,
                zh_superView: self.view,
                zh_delegate: self,
                zh_text: value,
                zh_font: @14,
            }];
            textView.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
            
            UITextView *tv = [UITextView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(textView.bounds),
                zh_backgroundColor: [UIColor clearColor],
                zh_userInteractionEnabled: @0,
                zh_textColor: kColor_999999,
                zh_hidden: @(value.length > 0),
                zh_superView: textView,
                zh_text: array[i],
                zh_tag: @520,
                zh_font: @14,
            }];
            tv.textContainerInset = UIEdgeInsetsMake(10, 10, 10, 10);
            
            [self.viewArray addObject:textView];
            
        } else {
            
            CGFloat top = ((UIView *)[self.viewArray lastObject]).bottom + 10;
            [self.view zh_addLineWithFrame:CGRectMake(0, top, zh_ScreenWidth, 56) color:[UIColor whiteColor]];
            
            [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(20, top, 168, 56)),
                zh_textColor: kColor_333333,
                zh_superView: self.view,
                zh_text: @"设为默认地址",
                zh_font: @14,
            }];
            
            UISwitch *aSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 88, 30)];
            aSwitch.frame = CGRectMake(zh_ScreenWidth - 20 - aSwitch.width, top + (56 - aSwitch.height) / 2.0, aSwitch.width, aSwitch.height);
            aSwitch.on = [value boolValue];
            [self.view addSubview:aSwitch];
            
            [self.viewArray addObject:aSwitch];
            
        }
    }
    
    UITextField *textField = (UITextField *)self.viewArray[2];
    textField.delegate = self;
    
    [UIImageView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 20, 56)),
        zh_contentMode: @(UIViewContentModeCenter),
        zh_superView: textField.rightView,
        zh_image: @"more"
    }];
    
    CGFloat height = SafeAreaHeight * .5 + 49;
    ZHButton *button = [ZHButton viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, zh_ScreenHeight - height, zh_ScreenWidth, height)),
        zh_normalTitle: @"保存",
        zh_backgroundColor: kColor_Red,
        zh_normalTitleColor: kColor_FFFFFF,
        zh_titleFont: @16,
        zh_superView: self.view,
    }];
    button.titleRect = CGRectMake(0, 0, button.width, 49);
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)selectArea {
    
    if (self.addressArray.count < 1) {
        [Util POST:@"/api/Index/area_ios" showHUD:YES showResultAlert:YES parameters:@{} result:^(id responseObject) {
            if (responseObject) {
                self.addressArray = responseObject;
                [self selectArea];
            }
        }];
        return;
    }
    
    if (!self.addressPickerController) {
                
        NSArray *array = self.addressArray;
        
        ZHAlertController *alertVC = [ZHAlertController alertUIPickerViewWithTitle:@"选择地区" style:UIAlertControllerStyleAlert];
        
        __block NSMutableArray *selectedIndexArray = [NSMutableArray arrayWithObjects:@0, @0, @0, nil];
        
        alertVC.numberOfComponents = ^NSInteger{
            return 3;
        };
        
        alertVC.numberOfRowsInComponent = ^NSInteger(NSInteger component) {
            if (component == 0) {
                return array.count;
            } else if (component == 1) {
                NSDictionary *province = array[[selectedIndexArray[0] integerValue]];
                NSArray *cities = province[@"child"];
                return cities.count;
            }
            
            NSDictionary *province = array[[selectedIndexArray[0] integerValue]];
            NSArray *cityArray = province[@"child"];
            
            NSInteger idx = [selectedIndexArray[1] integerValue];
            NSDictionary *city = cityArray[idx];
            
            NSArray *districtArray = city[@"child"];
            
            return districtArray.count;
        };
        
        alertVC.rowHeightForComponent = ^CGFloat(NSInteger component) {
            return 35.0;
        };
        
        alertVC.attributedTitleForRowOfComponent = ^NSAttributedString * _Nonnull(NSInteger row, NSInteger component) {
            NSString *string;
            if (component == 0) {
                
                NSDictionary *province = array[row];
                string = province[@"name"];
                
            } else if (component == 1) {
                
                NSDictionary *province = array[[selectedIndexArray[0] integerValue]];
                NSArray *cityArray = province[@"child"];
                
                NSDictionary *city = cityArray[row];
                string = city[@"name"];
                
            } else {
                
                NSDictionary *province = array[[selectedIndexArray[0] integerValue]];
                NSArray *cityArray = province[@"child"];
                
                NSInteger idx = [selectedIndexArray[1] integerValue];
                NSDictionary *city = cityArray[idx];
                
                NSArray *districtArray = city[@"child"];
                NSDictionary *district = districtArray[row];
                string = district[@"name"];
                
            }
            
            return [[NSAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]}];
        };
        
        alertVC.didSelectRowOfComponent = ^(NSInteger row, NSInteger component, UIPickerView * _Nonnull pickerView) {
            if (component == 0) {
                selectedIndexArray[0] = @(row);
                selectedIndexArray[1] = @(0);
                selectedIndexArray[2] = @(0);
            } else if (component == 1) {
                selectedIndexArray[1] = @(row);
                selectedIndexArray[2] = @(0);
            } else {
                selectedIndexArray[2] = @(row);
            }
            
            [pickerView reloadAllComponents];
            [pickerView selectRow:[selectedIndexArray[1] integerValue] inComponent:1 animated:YES];
            [pickerView selectRow:[selectedIndexArray[2] integerValue] inComponent:2 animated:YES];
        };
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alertVC addAction:cancelAction];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            
            NSDictionary *province = array[[selectedIndexArray[0] integerValue]];
            NSArray *cityArray = province[@"child"];
            
            NSInteger idx = [selectedIndexArray[1] integerValue];
            NSDictionary *city = cityArray[idx];
            
            NSArray *districtArray = city[@"child"];
            NSDictionary *district = districtArray[[selectedIndexArray[2] integerValue]];
            
            ((UITextField *)self.viewArray[2]).text = [NSString stringWithFormat:@"%@%@%@", province[kName], city[kName], district[kName]];
            
            self.province = province[kName];
            self.city = city[kName];
            self.district = district[kName];
            self.districtID = district[@"id"];
            
        }];
        [alertVC addAction:okAction];
                       
        self.addressPickerController = alertVC;
    }
    
    [self presentViewController:self.addressPickerController animated:YES completion:^{
        
    }];
    
}

- (void)tappedButton:(UIButton *)button {
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    NSArray *messages = @[@"请输入收货人", @"请输入手机号", @"请选择所在地区", @"请输入详细地址", @"is_default"];
    
    for (UITextField *tf in self.viewArray) {
        NSInteger index = [self.viewArray indexOfObject:tf];
        
        if ([tf isKindOfClass:[UISwitch class]]) {
            parameter[self.keyArray[index]] = @(((UISwitch *)tf).isOn);
        } else {
            
            if (tf.text.length < 1) {
                [SVProgressHUD showErrorWithStatus:messages[index]];
                return;
            }
            
            parameter[self.keyArray[index]] = tf.text;
        }
    }
        
    parameter[@"province"] = self.province;
    parameter[@"city"] = self.city;
    parameter[@"district"] = self.district;
    parameter[@"district_id"] = self.districtID;
    
    if (self.address[@"address_id"]) {
        parameter[@"address_id"] = self.address[@"address_id"];
        
        if (!self.province) {
            parameter[@"province"] = self.address[@"province"];
            parameter[@"city"] = self.address[@"city"];
            parameter[@"district"] = self.address[@"district"];
        }
    }
    
    [Util POST:(self.address ? @"/api/User/address_edit" : @"/api/User/address_add") showHUD:YES showResultAlert:YES parameters:parameter result:^(id responseObject) {
        if (responseObject) {
            if (self.operationSuccess) {
                self.operationSuccess();
            }
            
            [self goBack];
        }
    }];
}

#pragma mark -  UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self selectArea];
    
    return NO;;
}

#pragma mark -  UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView {
    [textView viewWithTag:520].hidden = (textView.text.length > 0);
}

- (NSMutableArray *)viewArray {
    if (!_viewArray) {
        _viewArray = [NSMutableArray array];
    }
    return _viewArray;
}

- (NSArray *)keyArray {
    if (!_keyArray) {
        _keyArray = @[@"person", @"phone", @"province", @"addr", @"is_default"];
    }
    return _keyArray;
}

@end
