//
//  UIButton+Extend.m
//  Client
//
//  Created by 马永州 contact QQ:917123258 on 2018/11/3.
//  Copyright © 2018年 loveRain. All rights reserved.
//

#import "UIButton+Extend.h"
#import <objc/runtime.h>
#import "UIImage+Extend.h"

#define kImageWithName(image)               [UIImage imageNamed:image]

void Swizzle(Class c, SEL orig, SEL new) {
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod))){
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    } else {
        method_exchangeImplementations(origMethod, newMethod);
    }
}

static const void *UIButtonBlockKey = &UIButtonBlockKey;


@implementation UIButton(Extend)

-(void)addActionHandler:(TouchedBlock)touchHandler{
    objc_setAssociatedObject(self, UIButtonBlockKey, touchHandler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [self addTarget:self action:@selector(actionTouched:) forControlEvents:UIControlEventTouchUpInside];
}
-(void)actionTouched:(UIButton *)btn{
    TouchedBlock block = objc_getAssociatedObject(self, UIButtonBlockKey);
    if (block) {
        block(btn.tag);
    }
}

+ (void)load {
    Swizzle(self, @selector(pointInside:withEvent:), @selector(myPointInside:withEvent:));
}

- (BOOL)myPointInside:(CGPoint)point withEvent:(UIEvent *)event {
    if (UIEdgeInsetsEqualToEdgeInsets(self.touchExtendInset, UIEdgeInsetsZero) || self.hidden ||
        ([self isKindOfClass:UIControl.class] && !((UIControl *)self).enabled)) {
        return [self myPointInside:point withEvent:event]; // original implementation
    }
    CGRect hitFrame = UIEdgeInsetsInsetRect(self.bounds, self.touchExtendInset);
    hitFrame.size.width = MAX(hitFrame.size.width, 0); // don't allow negative sizes
    hitFrame.size.height = MAX(hitFrame.size.height, 0);
    return CGRectContainsPoint(hitFrame, point);
}

static char touchExtendInsetKey;
- (void)setTouchExtendInset:(UIEdgeInsets)touchExtendInset {
    objc_setAssociatedObject(self, &touchExtendInsetKey, [NSValue valueWithUIEdgeInsets:touchExtendInset],
                             OBJC_ASSOCIATION_RETAIN);
}

- (UIEdgeInsets)touchExtendInset {
    return [objc_getAssociatedObject(self, &touchExtendInsetKey) UIEdgeInsetsValue];
}

/*!
 * 设置按钮正常状态下的图片
 */
- (void)setNormalImageName:(NSString *)imageName {
    [self setImage:kImageWithName(imageName) forState:UIControlStateNormal];
}

- (void)setNormalImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setNormalImageWithColor:(UIColor *)color {
    [self setImage:[UIImage imageWithColor:color] forState:UIControlStateNormal];
}

/*!
 * 设置按钮Hightlighted状态下的图片
 */
- (void)setHightlightedImageName:(NSString *)imageName {
    [self setImage:kImageWithName(imageName) forState:UIControlStateHighlighted];
}

- (void)setHightlightedImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateHighlighted];
}

- (void)setHightlightedImageWithColor:(UIColor *)color {
    [self setImage:[UIImage imageWithColor:color] forState:UIControlStateHighlighted];
}

/*!
 * 设置按钮Selected状态下的图片
 */
- (void)setSelectedImageName:(NSString *)imageName {
    [self setImage:kImageWithName(imageName) forState:UIControlStateSelected];
}

- (void)setSelectedImage:(UIImage *)image {
    [self setImage:image forState:UIControlStateSelected];
}

- (void)setSelectedImageWithColor:(UIColor *)color {
    [self setImage:[UIImage imageWithColor:color] forState:UIControlStateSelected];
}

- (void)setNormal:(UIColor *)color hightlighted:(UIColor *)hgColor {
    [self setNormalImageWithColor:color];
    [self setHightlightedImageWithColor:hgColor];
}

- (void)setNormal:(UIColor *)color selected:(UIColor *)selColor {
    [self setNormalImageWithColor:color];
    [self setSelectedImageWithColor:selColor];
}

- (void)setNormal:(UIColor *)color hightlighted:(UIColor *)hgColor selected:(UIColor *)selColor {
    [self setNormal:color hightlighted:hgColor];
    [self setSelectedImageWithColor:selColor];
}

+ (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}
- (void)setHorizontalAlignment
{
    CGSize maxSize = CGSizeMake(1000, 30);
    CGSize fitSize = [self.titleLabel sizeThatFits:maxSize];
    CGFloat w_titleLabel = fitSize.width;
    CGFloat h_titleLabel = fitSize.height;
    CGFloat h_image = self.imageView.image.size.height;
    CGFloat w_image = self.imageView.image.size.width;
    self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0 ,-w_image, -h_titleLabel,0.0)];
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0 ,0.0,h_image, -w_titleLabel)];
}


-(void)setTimestamp:(NSInteger)timestamp form:(NSString *)form withTimerStop:(void (^)(void))handle{
    
    __block NSInteger timeOut = timestamp;
    dispatch_queue_t queue=dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,0, 0, queue);
    //每秒执行一次
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL,0), 1.0 * NSEC_PER_SEC,0);
    dispatch_source_set_event_handler(_timer, ^{
        //倒计时结束，关闭
        if (timeOut == 0) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                handle();
            });
        } else {
            NSInteger ms = timeOut;
            NSInteger ss = 1;
            NSInteger mi = ss * 60;
            NSInteger hh = mi * 60;
            NSInteger dd = hh * 24;
            
            NSInteger day = ms / dd;// 天
            NSInteger hour = (ms - day * dd) / hh;// 时
            NSInteger minute = (ms - day * dd - hour * hh) / mi;// 分
            NSInteger second = (ms - day * dd - hour * hh - minute * mi) / ss;// 秒
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString * title = [NSString stringWithFormat:form,hour,minute,second];
                [self setTitle:title forState:UIControlStateNormal];
            });
            timeOut--;
            
        }
        
    });
    dispatch_resume(_timer);
}

#pragma mark -  rawName
static char key_rawName;

- (void)setRawName:(NSString *)name {
    objc_setAssociatedObject(self, &key_rawName, name, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)rawName {
    return objc_getAssociatedObject(self, &key_rawName);
}

#pragma mark -  selectOptionArray
static char key_selectOptionArray;

- (void)setSelectOptionArray:(NSArray *)selectOptionArray {
    objc_setAssociatedObject(self, &key_selectOptionArray, selectOptionArray, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSArray *)selectOptionArray {
    return objc_getAssociatedObject(self, &key_selectOptionArray);
}

@end
