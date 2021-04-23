//
//  CategoryViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/22.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "CategoryViewController.h"
#import "GoodsViewController.h"
#import "CategoryViewCell.h"
#import "SearchViewController.h"

@interface CategoryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UITableView *tableView;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@property (assign, nonatomic) NSInteger index;

@end

@implementation CategoryViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.array = [NSUserDefaults zh_arrayForKey:kAllCategory];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    [self.topBar addSubview:self.textField];
    
    [self.view addSubview:self.tableView];
    
    [self.view addSubview:self.collectionView];
    
    [self fetchRequest];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.array.count < 1) {
        [self fetchRequest];
    }
}

- (void)fetchRequest {
    [Util POST:@"/api/Index/goods_category_ios" showHUD:(self.array.count == 0) showResultAlert:YES parameters:@{} result:^(id responseObject) {
        if (responseObject) {
            self.array = responseObject;
            
            [NSUserDefaults zh_setValue:responseObject forKey:kAllCategory];
            
            [self.tableView reloadData];
            [self.tableView layoutIfNeeded];
            [self.collectionView reloadData];
        }
    }];
}

#pragma mark -  <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"BaseTableViewCell";
    BaseTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Identifier];
            
    if (!cell) {
        cell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
                        
        [cell.label setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth / 4.0, 48)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_textColor: kColor_333333,
            zh_numberOfLines: @2,
            zh_font: @14
        }];
        
        [cell.aLabel setPropertyWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 18, 2, 12)),
            zh_backgroundColor: kColor_Red
        }];
    }
    
    BOOL selected = indexPath.row == self.index;
    
    cell.aLabel.hidden = !selected;
    
    [cell.label setPropertyWithDictionary:@{
        zh_backgroundColor: selected ? kColor_FFFFFF : kColor_F5F5F5,
        zh_text: self.array[indexPath.row][kName],
    }];
            
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
    self.index = indexPath.row;
    [tableView reloadData];
    
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    NSDictionary *info = self.array[self.index];
    NSArray *array = info[@"child"];
    return array.count;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSDictionary *info = self.array[self.index];
    NSArray *array = info[@"child"];
    NSDictionary *cInfo = array[section];
    NSArray *cArray = cInfo[@"child"];
    return cArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section, item = indexPath.item;
    
    static NSString *Identifier = @"CategoryViewCell";
    
    BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    NSDictionary *info = self.array[self.index];
    NSArray *array = info[@"child"];
    NSDictionary *cInfo = array[section];
    NSArray *cArray = cInfo[@"child"];
    
    cell.info = cArray[item];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section, item = indexPath.item;
    
    NSDictionary *info = self.array[self.index];
    NSArray *array = info[@"child"];
    NSDictionary *cInfo = array[section];
    NSArray *cArray = cInfo[@"child"];
    
    GoodsViewController *vc = [[GoodsViewController alloc] initWithCategory:cArray[item]];
    [self.navigationController pushViewController:vc animated:YES];
}

//定义每个Cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(floor(zh_ScreenWidth / 4.0), 63 + 10 + 12 + 10);
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
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
    return CGSizeMake(zh_ScreenWidth, 32);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section, tag = 5201314;
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionHeader" forIndexPath:indexPath];
        
        UILabel *label = (UILabel *)[view viewWithTag:tag + 1];
        if (!label) {
            label = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(13.5, 0, zh_ScreenWidth - 13.5 * 2, 32)),
                zh_backgroundColor: kColor_FFFFFF,
                zh_textColor: kColor_000000,
                zh_superView: view,
                zh_tag: @(tag + 1),
                zh_font: [UIFont boldSystemFontOfSize:13]
            }];
        }
        
        NSDictionary *info = self.array[self.index];
        NSArray *array = info[@"child"];
        NSDictionary *cInfo = array[section];
        
        label.text = cInfo[kName];
        
        return view;
        
    }
    
    return nil;
}

#pragma mark -  UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.navigationController pushViewController:[SearchViewController new] animated:YES];
    
    return NO;
}

#pragma mark -  getter
- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, zh_StatusBar_HEIGHT + 4, zh_ScreenWidth - 15 * 2, 36)),
            zh_backgroundColor: kColor_F5F5F5,
            zh_textColor: kColor_808080,
            zh_font: @14,
            zh_delegate: self,
            zh_leftViewMode: @(UITextFieldViewModeAlways),
            zh_attributedPlaceholder: [[NSAttributedString alloc] initWithString:@"请输入" attributes:@{NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_C3C3C3]}],
            zh_leftView: [UIImageView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 36, 36)),
                zh_image: @"搜索"
            }]
        }];
        _textField.returnKeyType = UIReturnKeySearch;
        [_textField zh_addCornerRadius:6 withCorners:UIRectCornerAllCorners];
    }
    return _textField;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [UITableView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, self.topBar.bottom, ceil(zh_ScreenWidth / 4.0), zh_ScreenHeight - self.topBar.bottom - zh_TabBar_HEIGHT)),
            zh_separatorStyle: @(UITableViewCellSeparatorStyleNone),
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

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 1;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.tableView.right, self.topBar.bottom, zh_ScreenWidth - self.tableView.right, zh_ScreenHeight - self.topBar.bottom - zh_TabBar_HEIGHT) collectionViewLayout:layout];
        
        [collectionView setPropertyWithDictionary:@{
            zh_showsHorizontalScrollIndicator: @0,
            zh_showsVerticalScrollIndicator: @0,
            zh_backgroundColor: kColor_FFFFFF,
            zh_scrollEnabled: @1,
            zh_dataSource: self,
            zh_delegate: self
        }];
        
        [collectionView registerClass:[CategoryViewCell class] forCellWithReuseIdentifier:@"CategoryViewCell"];
        
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionElementKindSectionHeader"];
                
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (NSMutableArray *)tempArray {
    if (!_tempArray) {
        _tempArray = [NSMutableArray array];
    }
    return _tempArray;
}

- (NSInteger)pageSize {
    return 10;
}

@end
