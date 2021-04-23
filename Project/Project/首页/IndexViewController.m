//
//  IndexViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/22.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "IndexViewController.h"
#import "DDPageControl.h"

#import "CategoryViewCell.h"
#import "MiaoShaViewCell.h"
#import "BrabdViewCell.h"
#import "GoodsViewCell.h"

#import "GoodsViewController.h"
#import "ShopViewController.h"
#import "XianShiGouViewController.h"

#import "SearchViewController.h"
#import "CitySelectViewController.h"
#import "GoodsDetailViewController.h"

@interface IndexViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) UITextField *textField;

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) DDPageControl *pageControl;
@property (strong, nonatomic) UICollectionView *imageCollectionView;

@property (copy, nonatomic) NSArray *imageInfoArray;

@property (copy, nonatomic) NSArray *categoryArray;

@property (copy, nonatomic) NSArray *array;
@property (copy, nonatomic) NSMutableArray *tempArray;
@property (assign, nonatomic) NSInteger pageSize;

@property (copy, nonatomic) NSDictionary *info;

@property (strong, nonatomic) UILabel *label;

@end

@implementation IndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.topBar setPropertyWithDictionary:@{
        zh_backgroundColor: kColor_333333,
        zh_borderWidth: @0
    }];
        
//    [self.leftNavigationButton setPropertyWithDictionary:@{
//        zh_frame: NSStringFromCGRect(CGRectMake(0, zh_StatusBar_HEIGHT, 57, zh_NavigationBar_HEIGHT)),
//        zh_normalImage: @"地址"
//    }];
    
    [self.topBar addSubview:self.textField];
    
    [self.view addSubview:self.collectionView];
        
    [self.collectionView addSubview:self.imageCollectionView];
    [self.collectionView addSubview:self.pageControl];
    
    [self.collectionView zh_addLineWithFrame:CGRectMake(0, self.imageCollectionView.bottom, zh_ScreenWidth, 5) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    
    if (![AppDelegate appDelegate].city) {
        [[AppDelegate appDelegate] locationWithHUD:NO successBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode) {
            
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (!self.info || self.needRefresh) {
        [self fetchRequest];
        
        self.needRefresh = NO;
    }
}

- (void)fetchRequest {
    [SVProgressHUD dismissWithDelay:0];
    
    NSLog(@"request start %@", [[NSDate date] zh_stringWithDateFormat:@"yyyy-MM-dd HH:mm:ss"]);
    
    [Util POST:@"/api/Index/index" showHUD:YES showResultAlert:YES parameters:@{} result:^(id responseObject) {
        if (responseObject) {
            self.info = responseObject;
            
            BOOL isFirstTime = [AppDelegate appDelegate].leftTime < 0;
            [AppDelegate appDelegate].leftTime = [self.info[@"miaosha_end_time"] intValue] - [self.info[@"now_time"] intValue];
            
            if (isFirstTime) {
                [self resetTime:self];
            }
                        
            self.imageInfoArray = responseObject[@"banner"];
            self.categoryArray = responseObject[@"category"];
            self.array = responseObject[@"goods"];
            
            [self.collectionView reloadData];
            [self.imageCollectionView reloadData];
        }
    }];
}

- (void)resetTime:(IndexViewController *)vc {
    int leftTime = [AppDelegate appDelegate].leftTime;
    int seconds = leftTime % 60;
    int minutes = (leftTime / 60) % 60;
    int hours = leftTime / 3600;
    self.label.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
    
    if ([AppDelegate appDelegate].leftTime > 0) {
        [AppDelegate appDelegate].leftTime--;
    }
        
    [self zh_performBlock:^{
        [self resetTime:self];
    } afterDelay:1];
}

- (void)leftNavigationButtonAction {
    CitySelectViewController *vc = [CitySelectViewController new];
    vc.didSelect = ^(NSDictionary * _Nonnull city) {
        
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return collectionView == self.imageCollectionView ? 1 : 4;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (collectionView == self.imageCollectionView) {
        
        NSInteger amount = self.imageInfoArray.count > 0 ? self.imageInfoArray.count : 1;
        [self.pageControl setNumberOfPages:amount];
        return amount;
        
    } else {
        
        NSString *key = @[@"category", @"miaosha", @"shop", @"goods"][section];
        NSArray *array = self.info[key];
        return array.count;
        
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger section = indexPath.section, item = indexPath.item;
    
    if (collectionView == self.imageCollectionView) {
        
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
        }
        
        if (self.imageInfoArray.count > item) {
            
            NSDictionary *info = self.imageInfoArray[item];
            [imageView sd_setImageWithURL:[NSURL URLWithString:info[@"image"]]];
            
        } else {
            
            imageView.image = [UIImage zh_appIcon];
            
        }
        
        return cell;
        
    } else {
        
        NSArray *array = @[@"CategoryViewCell", @"MiaoShaViewCell", @"BrabdViewCell", @"GoodsViewCell"];
        NSString *Identifier = array[section];
        
        BaseCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
        
        [cell setPropertyWithDictionary:@{
            zh_backgroundColor: @[kColor_FFFFFF, kColor_Red, kColor_Orange, kColor_F5F5F5][section]
        }];
        
        NSString *key = @[@"category", @"miaosha", @"shop", @"goods"][section];
        NSArray *arrayX = self.info[key];
        cell.info = arrayX[item];
        
        if ([cell isKindOfClass:[GoodsViewCell class]]) {
            GoodsViewCell *aCell = (GoodsViewCell *)cell;
            aCell.container.left = item % 2 == 0 ? 11 : 4.5;
        }
        
        return cell;
        
    }
}

#pragma mark didSelect
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger section = indexPath.section, item = indexPath.item;
    
    if (collectionView == self.imageCollectionView) {
        
        
        
    } else {
        
        NSString *key = @[@"category", @"miaosha", @"shop", @"goods"][section];
        NSArray *arrayX = self.info[key];
        NSDictionary *info = arrayX[item];
        
        BaseViewController *vc;
        
        if (section == 0) {
            
            vc = [[GoodsViewController alloc] initWithCategory:info];
            
        } else if (section == 1) {
            
            vc = [XianShiGouViewController new];
            
        } else if (section == 2) {
            
            vc = [[ShopViewController alloc] initWithShop:info];
            
        } else if (section == 3) {
            
            vc = [[GoodsDetailViewController alloc] initWithID:info[@"id"]];
            
        }
        
        if (vc) {
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }
}

//定义每个Cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (collectionView == self.imageCollectionView) {
        
        return collectionView.frame.size;
        
    } else {
        
        if (indexPath.section == 3) {
            return CGSizeMake((indexPath.row % 2 == 0 ? ceil(zh_ScreenWidth / 2.0) : floor(zh_ScreenWidth / 2.0)), 295);
        }
        
        NSArray *countArray = @[@4, @3, @3, @2];
        NSArray *heightArray = @[@(10 + 57 + 8 + 15), @150, @120, @295];
        return CGSizeMake(floor(zh_ScreenWidth / [countArray[indexPath.section] integerValue]), [heightArray[indexPath.section] integerValue]);
        
    }
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    if (collectionView == self.collectionView && section == 0) {
        return UIEdgeInsetsMake(zh_ScreenWidth / 2 + 10, 0, 0, 0);
    }
    
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
    return section == 0 ? CGSizeZero : CGSizeMake(zh_ScreenWidth, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return collectionView == self.imageCollectionView ? CGSizeZero : CGSizeMake(zh_ScreenWidth, 15);
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (collectionView == self.imageCollectionView) {
        return nil;
    }
    
    NSInteger section = indexPath.section, tag = 5201314;
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionHeader" forIndexPath:indexPath];
        
        [view setPropertyWithDictionary:@{
            zh_backgroundColor: @[kColor_FFFFFF, kColor_Red, kColor_Orange, kColor_F5F5F5][section]
        }];
        
        UILabel *label1 = (UILabel *)[view viewWithTag:tag + 1];
        UILabel *label2 = (UILabel *)[view viewWithTag:tag + 2];
        UILabel *label3 = (UILabel *)[view viewWithTag:tag + 3];
        if (!label1) {
            label1 = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(10, 0, zh_ScreenWidth - 10 * 2, 40)),
                zh_superView: view,
                zh_tag: @(tag + 1),
                zh_font: @16
            }];
            
            label3 = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(label1.right - 100, 9, 100, 22)),
                zh_textAlignment: @(NSTextAlignmentCenter),
                zh_backgroundColor: kColor_FFFFFF,
                zh_textColor: kColor_Red,
                zh_superView: view,
                zh_tag: @(tag + 3),
                zh_font: @14
            }];
            [label3 zh_addCornerRadius:4 withCorners:UIRectCornerAllCorners];
            
            label2 = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(label3.left - 100, 9, 90, 22)),
                zh_textAlignment: @(NSTextAlignmentRight),
                zh_textColor: kColor_FFFFFF,
                zh_text: @"距离结束",
                zh_superView: view,
                zh_tag: @(tag + 2),
                zh_font: @14
            }];
        }
        
        label2.hidden = label3.hidden = (section != 1);
        
        [label1 setPropertyWithDictionary:@{
            zh_text: @[@"", @"限时秒杀", @"推荐商家", @"商品推荐"][section],
            zh_textColor: (section == 3 ? kColor_000000 : kColor_FFFFFF),
        }];
                
        if (section == 1) {
            self.label = label3;
            
            int leftTime = [AppDelegate appDelegate].leftTime;
            int seconds = leftTime % 60;
            int minutes = (leftTime / 60) % 60;
            int hours = leftTime / 3600;
            self.label.text = [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        }
        
        return view;
        
        
    } else if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *view = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionFooter" forIndexPath:indexPath];
        
        [view setPropertyWithDictionary:@{
            zh_backgroundColor: (section > 1 ? kColor_F5F5F5 : kColor_FFFFFF)
        }];
        
        UIView *lineView = [view viewWithTag:tag];
        if (!lineView) {
            lineView = [UIView viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(0, 0, zh_ScreenWidth, 10)),
                zh_superView: view,
                zh_tag: @(tag)
            }];
        }
        
        [lineView setPropertyWithDictionary:@{
            zh_backgroundColor: @[kColor_FFFFFF, kColor_Red, kColor_Orange, kColor_F5F5F5][section]
        }];
        
        return view;
        
    }
    
    return nil;
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.imageCollectionView) {
        
        NSInteger index = collectionView.contentOffset.x / collectionView.width;
        self.pageControl.currentPage = index;
        
        [[self class] cancelPreviousPerformRequestsWithTarget:self];
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

#pragma mark -  UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [self.navigationController pushViewController:[SearchViewController new] animated:YES];
    
    return NO;
}

#pragma mark -  getter
- (UITextField *)textField {
    if (!_textField) {
        _textField = [UITextField viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(10, zh_StatusBar_HEIGHT + 4, zh_ScreenWidth - 10 * 2, 36)),
            zh_backgroundColor: kColor_FFFFFF,
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
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.topBar.bottom, zh_ScreenWidth, zh_ScreenHeight - self.topBar.bottom - zh_TabBar_HEIGHT) collectionViewLayout:layout];
        
        [collectionView setPropertyWithDictionary:@{
            zh_showsHorizontalScrollIndicator: @0,
            zh_showsVerticalScrollIndicator: @0,
            zh_backgroundColor: kColor_FFFFFF,
            zh_scrollEnabled: @1,
            zh_dataSource: self,
            zh_delegate: self
        }];
        
        [collectionView registerClass:[CategoryViewCell class] forCellWithReuseIdentifier:@"CategoryViewCell"];
        [collectionView registerClass:[MiaoShaViewCell class] forCellWithReuseIdentifier:@"MiaoShaViewCell"];
        [collectionView registerClass:[BrabdViewCell class] forCellWithReuseIdentifier:@"BrabdViewCell"];
        [collectionView registerClass:[GoodsViewCell class] forCellWithReuseIdentifier:@"GoodsViewCell"];
        
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"UICollectionElementKindSectionHeader"];
        
        [collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"UICollectionElementKindSectionFooter"];
        
        if (@available(iOS 11.0, *)) {
            collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        _collectionView = collectionView;
    }
    return _collectionView;
}

- (UICollectionView *)imageCollectionView {
    if (!_imageCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 1;
        
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, zh_ScreenWidth, zh_ScreenWidth / 2) collectionViewLayout:layout];
        
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
