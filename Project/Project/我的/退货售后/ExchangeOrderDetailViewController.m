//
//  ExchangeOrderDetailViewController.m
//  Project
//
//  Created by 于兆海 on 2021/1/29.
//  Copyright © 2021 LaiKe. All rights reserved.
//

#import "ExchangeOrderDetailViewController.h"
#import "OrderViewCell.h"


@interface ExchangeOrderDetailViewController ()

@property (strong, nonatomic) UICollectionView *collectionView;

@end

@implementation ExchangeOrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"退货详情";
    
    [self.view addSubview:self.collectionView];
    
    UIView *aView = [Util viewWithFrame:CGRectMake(0, 0, zh_ScreenWidth, 60) bgColor:[UIColor zh_colorWithHexString:kColor_Red] labelProperty:@{
        zh_frame: NSStringFromCGRect(CGRectMake(22.5, 0, zh_ScreenWidth - 45, 60)),
        zh_textColor: kColor_FFFFFF,
        zh_text: @"申请取消",
        zh_font: @16,
    }];
    [self.collectionView addSubview:aView];
    
    [self.collectionView zh_addLineWithFrame:CGRectMake(0, aView.bottom, zh_ScreenWidth, 5) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    
    OrderViewCell *cell = [[OrderViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kColor_FFFFFF];
    cell.frame = CGRectMake(0, 65, zh_ScreenWidth, 95);
    cell.info = @{};
    [self.collectionView addSubview:cell];
    
    [self.collectionView zh_addLineWithFrame:CGRectMake(0, cell.bottom, zh_ScreenWidth, 5) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    
    NSMutableAttributedString *aString = [[NSMutableAttributedString alloc] initWithString:@"订单信息" attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_Red]}];
    [aString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n订单编号:\t%@\n退货数量:\t%@\n退款金额:\t%@\n退款原因:\t%@\n申请时间:\t%@\n取消时间:\t%@\n取消原因:\t%@\n", @"15545845646", @"x2", @"¥27", @"产品质量问题", @"2019-03-13  10:22:22", @"2019-03-13  10:22:22", @"用户取消/平台驳回"] attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14], NSForegroundColorAttributeName: [UIColor zh_colorWithHexString:kColor_333333]}]];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 5;
    [aString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [aString.string length])];
    
    UITextView *textView = [UITextView viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(0, cell.bottom + 5, zh_ScreenWidth, 360 - cell.bottom - 5)),
        zh_backgroundColor: kColor_FFFFFF,
        zh_superView: self.collectionView,
        zh_attributedText: aString,
        zh_scrollEnabled: @0,
        zh_editable: @0,
    }];
    textView.textContainerInset = UIEdgeInsetsMake(10, 15, 10, 15);
    
    [self.collectionView zh_addLineWithFrame:CGRectMake(0, textView.bottom, zh_ScreenWidth, 5) color:[UIColor zh_colorWithHexString:kColor_F5F5F5]];
    
    [UILabel viewWithDictionary:@{
        zh_frame: NSStringFromCGRect(CGRectMake(25, textView.bottom + 5, zh_ScreenWidth - 50, 35)),
        zh_superView: self.collectionView,
        zh_textColor: kColor_333333,
        zh_text: @"凭证图片",
        zh_font: @14,
    }];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *Identifier = @"UICollectionViewCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:Identifier forIndexPath:indexPath];
    
    NSInteger tag = 5201314;
    UIImageView *imageView = (UIImageView *)[cell.contentView viewWithTag:tag];

    if (!imageView) {
        imageView = [UIImageView viewWithDictionary:@{
            zh_frame: NSStringFromCGRect(CGRectMake(0, 0, 70, 70)),
            zh_contentMode: @(UIViewContentModeScaleAspectFit),
            zh_superView: cell.contentView,
            zh_borderColor: kColor_B2B2B2,
            zh_borderWidth: @1,
            zh_tag: @(tag),
        }];
    }
    
    NSString *string = @[@"bx", @"fs", @"jg", @"rsq", @"xyj"][[ZHTools randomNumberFrom:0 to:4]];
        imageView.image = [UIImage imageNamed:string];
//    imageView.image = [UIImage zh_appIcon];
    
    return cell;
    
}

#pragma mark didSelect
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
}

//定义每个Cell的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(70, 70);
}

//定义每个Section的四边间距
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(400, 25, 15, 25);
}

//两行cell之间的间距（上下行cell的间距）
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10;
}

//两列cell之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return 10;
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
            zh_backgroundColor: kColor_FFFFFF,
            zh_scrollEnabled: @1,
            zh_dataSource: self,
            zh_delegate: self
        }];
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"UICollectionViewCell"];
                
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
