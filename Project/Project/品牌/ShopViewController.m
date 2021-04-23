//
//  ShopViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/23.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ShopViewController.h"
#import "GoodsViewCell.h"
#import "GoodsDetailViewController.h"

@interface ShopViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) UIView *selectIndicator;

@property (copy, nonatomic) NSDictionary *shop;

@property (copy, nonatomic) NSMutableArray *buttonArray;

@property (copy, nonatomic) NSURLSessionTask *task;

@property (copy, nonatomic) NSMutableArray *history;

@property (copy, nonatomic) NSArray *couponArray;

@end

@implementation ShopViewController

- (instancetype)initWithShop:(NSDictionary *)shop {
    self = [super init];
    if (self) {
        self.shop = shop;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
        
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.topBar addSubview:self.textField];
    
    [self.view addSubview:self.collectionView];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if ([self.collectionView.mj_footer isRefreshing]) {
            return;
        }
        
        [self.tempArray removeAllObjects];
        
        [self fetchRequestWithPage:1];
    }];
    
    self.collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        if ([self.collectionView.mj_header isRefreshing]) {
            return;
        }
        
        [self fetchRequestWithPage:(self.array.count / self.pageSize + 1)];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.couponArray.count < 1) {
        [self fetchRequest];
    }
    
    if (self.array.count < 1) {
        [self.collectionView.mj_header beginRefreshing];
    }
}

#pragma mark -  网络请求
- (void)fetchRequest {
    [Util POST:@"/api/Index/shop_coupon" showHUD:NO showResultAlert:NO parameters:@{@"shop_id": self.shop[@"shop_id"] ? : self.shop[@"id"]} result:^(id responseObject) {
        self.couponArray = responseObject;
        
        [self.collectionView reloadData];
    }];
}

- (void)fetchRequestWithPage:(NSInteger)page {
    [self.textField resignFirstResponder];
        
    self.task = [Util POST:@"/api/Index/goods_list" showHUD:NO showResultAlert:YES parameters:@{
        @"sort": (@[@0, (self.selectedButton.selected ? @1 : @2), (self.selectedButton.selected ? @3 : @4)][self.selectedButton.tag]),
        @"key_word": (self.textField.text ? : @""),
        @"shop_id": self.shop[@"shop_id"] ? : self.shop[@"id"],
        @"limit": @(self.pageSize),
        @"page": @(page),
    } result:^(id responseObject) {
        
        [self endMJRefreshWithResult:[responseObject isKindOfClass:[NSArray class]] responseArray:responseObject];
        
    }];
}

#pragma mark -  self define
- (void)endMJRefreshWithResult:(BOOL)success responseArray:(NSArray *)responseArray {
    [self.collectionView.mj_header endRefreshing];
    
    if (success && (responseArray.count < self.pageSize)) {
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [self.collectionView.mj_footer endRefreshing];
    }
    
    if (success) {
        
        [self.tempArray addObjectsFromArray:responseArray];
        
        self.array = [NSArray arrayWithArray:self.tempArray];
        
        [self.collectionView reloadData];
        
    } else if (self.tempArray.count != self.array.count) {
        
        [self.tempArray removeAllObjects];
        [self.tempArray addObjectsFromArray:self.array];
        
    }
}

- (void)tappedTopButton:(UIButton *)button {
    [self.task cancel];
    
    if (button.tag > 0 && button == self.selectedButton) {
        button.selected = !button.selected;
        [self.collectionView.mj_header beginRefreshing];
        return;
    }
    
    self.selectedButton = button;
    
    NSArray *array = @[@"综合", @"价格", @"销量"];
    [array enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *button = self.buttonArray[idx];
        [button setAttributedTitle:nil forState:UIControlStateNormal];
        [button setAttributedTitle:nil forState:UIControlStateSelected];
        
        [button setPropertyWithDictionary:@{
            zh_selected: @0,
            zh_normalTitle: obj,
            zh_selectedTitle: obj,
        }];
        
    }];
        
    if (button.tag > 0) {
        
        NSString *string = [array[button.tag] stringByAppendingString:@" "];
        NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
        
        NSTextAttachment *attach = [[NSTextAttachment alloc] init];
        attach.image = [UIImage imageNamed:@"DESC"];
        attach.bounds = CGRectMake(0, 0, 8, 5);
        [aString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        [button setAttributedTitle:aString forState:UIControlStateNormal];
        
        aString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
        
        attach = [[NSTextAttachment alloc] init];
        attach.image = [UIImage imageNamed:@"ASC"];
        attach.bounds = CGRectMake(0, 0, 8, 5);
        [aString appendAttributedString:[NSAttributedString attributedStringWithAttachment:attach]];
        [button setAttributedTitle:aString forState:UIControlStateSelected];
        
    } else {
        button.selected = YES;
    }
        
    [UIView animateWithDuration:.1 animations:^{
        self.selectIndicator.centerX = button.centerX;
    }];
    
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.array.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Identifier = @"GoodsViewCell";
    
    GoodsViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    NSInteger item = indexPath.item;
    
    cell.container.left = item % 2 == 0 ? 11 : 4.5;
    
    cell.info = self.array[indexPath.item];
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    GoodsDetailViewController *vc = [[GoodsDetailViewController alloc] initWithID:self.array[indexPath.item][@"id"]];
    [self.navigationController pushViewController:vc animated:YES];
}

//定义每个Cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake((indexPath.row % 2 == 0 ? ceil(zh_ScreenWidth / 2.0) : floor(zh_ScreenWidth / 2.0)), 295);
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 5, 0);//分别为上、左、下、右
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
    return CGSizeMake(zh_ScreenWidth, 30 + 5 + (self.couponArray.count > 0 ? 60 : 30));
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionHeader" forIndexPath:indexPath];
    
    NSInteger tag = 5201314;
        
    if (!self.selectedButton) {
        UIView *nameView = [UIView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 60)),
            zh_backgroundColor: kColor_333333,
            zh_superView: view,
            zh_tag: @(tag),
        }];
        
        UILabel *label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, 0, zh_ScreenWidth - 15, 30)),
            zh_textColor: kColor_FFFFFF,
            zh_superView: nameView,
            zh_text: (self.shop[kName] ? : @""),
            zh_font: @12,
            zh_tag: @(tag + 1),
        }];
        
        label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(15, 30, 44, 20)),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_backgroundColor: kColor_Red,
            zh_textColor: kColor_FFFFFF,
            zh_superView: nameView,
            zh_text: @"优惠",
            zh_font: @11,
            zh_tag: @(tag + 2),
        }];
        
        label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(label.right + 15, label.top, zh_ScreenWidth - label.right - 15, 20)),
            zh_textColor: kColor_FFFFFF,
            zh_superView: nameView,
            zh_font: @13,
            zh_tag: @(tag + 3),
        }];
        
        NSArray *array = @[@"综合", @"价格", @"销量"];
        CGFloat width = ceil(zh_ScreenWidth / array.count);
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(idx * width, nameView.bottom, width, 30)),
                zh_backgroundColor: kColor_FFFFFF,
                zh_normalTitleColor: kColor_999999,
                zh_selectedTitleColor: kColor_Red,
                zh_normalTitle: obj,
                zh_superView: view,
                zh_titleFont: @12,
                zh_tag: @(idx)
            }];
            
            if (idx == 0) {
                button.selected = YES;
                self.selectedButton = button;
            }
            [self.buttonArray addObject:button];
            
            [button addTarget:self action:@selector(tappedTopButton:) forControlEvents:UIControlEventTouchUpInside];
        }];
        
        self.selectIndicator = [UIView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.selectedButton.centerX - 26, self.selectedButton.bottom - 2, 52, 2)),
            zh_backgroundColor: kColor_Red,
            zh_superView: view,
        }];
        [self.buttonArray addObject:self.selectIndicator];
        
        [view zh_addTapGestureRecognizerWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
            NSMutableString *string = [NSMutableString string];
            
            for (NSDictionary *info in self.couponArray) {
                BOOL flag = [info[@"type_two"] integerValue] == 0;
                
                [string appendFormat:@"满%.0f%@%@\n", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])];
            }
            
            if (string.length > 0) {
                
                [ZHAlertController alertTitle:@"" message:string cancleButtonTitle:@"确定"];
                
            }
        }];
    }
    
    BOOL hasDiscount = self.couponArray.count > 0;
    [view viewWithTag:tag].height = hasDiscount ? 60 : 30;
    
    ((UILabel *)[view viewWithTag:tag + 1]).font = [UIFont systemFontOfSize:hasDiscount ? 14 : 12];
    [view viewWithTag:tag + 2].hidden = [view viewWithTag:tag + 3].hidden = !hasDiscount;
    
    if (self.couponArray.count > 0) {
        NSMutableString *string = [NSMutableString stringWithString:@"本店铺购"];
        
        for (NSDictionary *info in self.couponArray) {
            BOOL flag = [info[@"type_two"] integerValue] == 0;
            
            [string appendFormat:@"满%.0f%@%@  ", [info[@"money_max"] doubleValue], (flag ? @"减" : @"赠"), (flag ? @([info[@"money"] integerValue]) : info[@"give_goods_name"])];
        }
        
        ((UILabel *)[view viewWithTag:tag + 3]).text = string;
    }
    
    for (UIView *v in self.buttonArray) {
        v.bottom = view.height;
    }
    
    return view;
}

#pragma mark -  UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.collectionView.mj_header beginRefreshing];
    return NO;
}

#pragma mark -  getter
- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(self.leftNavigationButton.right, zh_StatusBar_HEIGHT + 4, zh_ScreenWidth - self.leftNavigationButton.right - 15, 36)),
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

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        layout.sectionHeadersPinToVisibleBounds = YES;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 1;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.topBar.bottom + 1, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - 1) collectionViewLayout:layout];
        
        [collectionView setPropertyWithDictionary:@{
            zh_showsHorizontalScrollIndicator: @0,
            zh_showsVerticalScrollIndicator: @0,
            zh_backgroundColor: kColor_F5F5F5,
            zh_scrollEnabled: @1,
            zh_dataSource: self,
            zh_delegate: self
        }];
        
        [collectionView registerClass:[GoodsViewCell class] forCellWithReuseIdentifier:@"GoodsViewCell"];
        
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

- (NSMutableArray *)buttonArray {
    if (!_buttonArray) {
        _buttonArray = [NSMutableArray array];
    }
    return _buttonArray;
}

- (NSMutableArray *)history {
    if (!_history) {
        
        _history = [NSMutableArray array];
        
        NSArray *array = [NSUserDefaults zh_arrayForKey:kSearchHistory];
        if (array.count > 0) {
            [_history addObjectsFromArray:array];
        }
    }
    return _history;
}

@end
