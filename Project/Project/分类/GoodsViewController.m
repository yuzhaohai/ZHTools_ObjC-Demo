//
//  GoodsViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/23.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "GoodsViewController.h"
#import "SearchViewController.h"
#import "GoodsDetailViewController.h"
#import "GoodsViewCell.h"

@interface GoodsViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UICollectionView *collectionView;

@property (copy, nonatomic) NSMutableArray *buttonArray;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@property (copy, nonatomic) NSDictionary *category;

@property (strong, nonatomic) UIButton *selectedButton;
@property (strong, nonatomic) UIView *selectIndicator;

@property (copy, nonatomic) NSURLSessionTask *task;

@end

@implementation GoodsViewController

- (instancetype)initWithCategory:(NSDictionary *)category {
    self = [super init];
    if (self) {
        self.category = category;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.category[kName];
    
    self.view.backgroundColor = [UIColor zh_colorWithHexString:kColor_F5F5F5];
    
    [self.view addSubview:self.collectionView];
    
    [self.rightNavigationButton setImage:[UIImage imageNamed:@"搜索"] forState:UIControlStateNormal];
    
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
    
    if (self.array.count < 1) {
        [self.collectionView.mj_header beginRefreshing];
    }
}

- (void)rightNavigationButtonAction {
    [self.navigationController pushViewController:[[SearchViewController alloc] initWithCategory:self.category] animated:YES];
}

- (void)tappedTopButton:(UIButton *)button {
    
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

#pragma mark -  网络请求
- (void)fetchRequestWithPage:(NSInteger)page {
    self.task = [Util POST:@"/api/Index/goods_list" showHUD:NO showResultAlert:YES parameters:@{
        @"sort": (@[@0, (self.selectedButton.selected ? @1 : @2), (self.selectedButton.selected ? @3 : @4)][self.selectedButton.tag]),
        @"category": self.category[@"category_id"] ? : self.category[@"id"],
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
    NSDictionary *info = self.array[indexPath.item];
    GoodsDetailViewController *vc = [[GoodsDetailViewController alloc] initWithID:info[@"id"]];
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
    return CGSizeMake(zh_ScreenWidth, 30 + 5);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionHeader" forIndexPath:indexPath];
        
    if (!self.selectedButton) {
        
        NSArray *array = @[@"综合", @"价格", @"销量"];
        CGFloat width = ceil(zh_ScreenWidth / array.count);
        [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIButton *button = [UIButton viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(idx * width, 0, width, 30)),
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
        
    }
    
    return view;
}

#pragma mark -  getter
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

@end
