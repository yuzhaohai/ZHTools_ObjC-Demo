//
//  ZH_ImagePageControl.m
//  ZH_Tools
//
//  Created by born2try-8 on 16/8/3.
//  Copyright © 2016年 born2try. All rights reserved.
//

#import "ZH_ImagePageControl.h"

@interface ZH_ImagePageControl (){
    NSMutableArray *_imageViews;
}

- (void)updateDots;

@end

@implementation ZH_ImagePageControl

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _imageNormal = [UIImage imageNamed:@"heart_gray"];
        _imageHighlighted = [UIImage imageNamed:@"heart_red"];
        
        _imageViews = [NSMutableArray array];
    }
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self updateDots];
}

- (void)updateDots{
    NSInteger index = 0;
    for (UIView *view in self.subviews) {
        view.frame = CGRectMake(view.left, 0, 10, 10);
        
        UIImage *image = self.currentPage == index ? _imageHighlighted : _imageNormal;
        image = [image sd_resizedImageWithSize:view.size scaleMode:SDImageScaleModeAspectFit];
        view.backgroundColor = [UIColor colorWithPatternImage:image];
        
        index++;
    }
}

-(void) setCurrentPage:(NSInteger)page{
    if (self.currentPage != page) {
        [super setCurrentPage:page];
        [self updateDots];
    }
}

@end
