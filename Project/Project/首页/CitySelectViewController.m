//
//  CitySelectViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/25.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "CitySelectViewController.h"
#import <AMapLocationKit/AMapLocationKit.h>

@interface CitySelectViewController ()

@property (strong, nonatomic) UICollectionView *collectionView;

@property (copy, nonatomic) NSArray *array;

@end

@implementation CitySelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"选择城市";
    
    [self.view addSubview:self.collectionView];
    
    [self.view zh_addLineWithFrame:CGRectMake(0, self.topBar.bottom, zh_ScreenWidth, 1) color:[UIColor zh_colorWithHexString:kColor_EAEAEA]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (![AppDelegate appDelegate].location) {
        [[AppDelegate appDelegate] locationWithHUD:NO successBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode) {
            [self.collectionView reloadData];
        }];
    }
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 100;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *Identifier = @"UICollectionViewCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    NSInteger tag = 5201314;
    UILabel *label = (UILabel *)[cell.contentView viewWithTag:tag];
    
    if (!label) {
        label = [UILabel viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(cell.bounds),
            zh_textAlignment: @(NSTextAlignmentCenter),
            zh_backgroundColor: kColor_FFFFFF,
            zh_superView: cell.contentView,
            zh_borderColor: kColor_808080,
            zh_textColor: kColor_000000,
            zh_borderWidth: @1,
            zh_tag: @(tag)
        }];
    }
    
    label.text = [indexPath description];
    
    return cell;
    
}

#pragma mark didSelect
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.didSelect) {
        self.didSelect(@{});
    }
    
    [self goBack];
}

//定义每个Cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(floor((zh_ScreenWidth - 15 * 2 - 24) / 2.0), 33);
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 15, SafeAreaHeight * .5, 15);
}

//两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10;
}

//两列cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 24;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(zh_ScreenWidth, 44 + 44);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

// 和UITableView类似，UICollectionView也可设置段头段尾
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger tag = 5201314;
    
    if([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        
        UICollectionReusableView *view = [self.collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionHeader" forIndexPath:indexPath];
        
        [view setPropertyWithDictionary:@{
            zh_backgroundColor: kColor_F5F5F5
        }];
        
        [view zh_addLineWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 44) color:[UIColor whiteColor]];
        
        UILabel *label1 = (UILabel *)[view viewWithTag:tag + 1];
        UILabel *label2 = (UILabel *)[view viewWithTag:tag + 2];
        if (!label1) {
            label1 = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(15, 0, zh_ScreenWidth - 15 * 2, 44)),
                zh_userInteractionEnabled: @1,
                zh_textColor: kColor_000000,
                zh_superView: view,
                zh_tag: @(tag + 1),
                zh_font: @15
            }];
            
            [label1 zh_addTapGestureRecognizerWithBlock:^(UIGestureRecognizer *gestureRecoginzer) {
                if ([AppDelegate appDelegate].location) {
                    
                }
            }];
            
            label2 = [UILabel viewWithDictionary:@{
                zh_frame: NSStringFromCGRect(CGRectMake(15, 44, label1.width, 44)),
                zh_textColor: kColor_666666,
                zh_text: @"城市列表",
                zh_superView: view,
                zh_tag: @(tag + 2),
                zh_font: @12
            }];
        }
                
        AMapLocationReGeocode *regeocode = [AppDelegate appDelegate].regeocode;
        label1.text = regeocode ? [NSString stringWithFormat:@"当前城市：%@ %@", regeocode.province, regeocode.city] : @"当前城市：尚未获取到";
        
        return view;
        
        
    } else if([kind isEqualToString:UICollectionElementKindSectionFooter]) {
        
        UICollectionReusableView *view = [_collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"UICollectionElementKindSectionFooter" forIndexPath:indexPath];
        
        [view setPropertyWithDictionary:@{
            zh_backgroundColor: kColor_F5F5F5
        }];
        
        return view;
        
    }
    
    return nil;
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
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
        
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

@end
