//
//  DDPageControl.h
//  DDPageControl
//
//  Created by Damien DeVille on 1/14/11.
//  Copyright 2011 Snappy Code. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIControl.h>
#import <UIKit/UIKitDefines.h>

typedef enum
{
	DDPageControlTypeOnFullOffFull		= 0,
	DDPageControlTypeOnFullOffEmpty		= 1,
	DDPageControlTypeOnEmptyOffFull		= 2,
	DDPageControlTypeOnEmptyOffEmpty	= 3,
}
DDPageControlType ;


@interface DDPageControl : UIControl 
{
	NSInteger numberOfPages ;
	NSInteger currentPage ;
}

// Replicate UIPageControl features
@property(nonatomic) NSInteger numberOfPages ;
@property(nonatomic) NSInteger currentPage ;

@property(nonatomic) BOOL hidesForSinglePage ;

@property(nonatomic) BOOL defersCurrentPageDisplay ;
- (void)updateCurrentPageDisplay ;

- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount ;

/*
	DDPageControl add-ons - all these parameters are optional
	Not using any of these parameters produce a page control identical to Apple's UIPage control
 */
- (id)initWithType:(DDPageControlType)theType ;

@property (nonatomic) DDPageControlType type ;

@property (nonatomic,retain) UIColor *onColor ;
@property (nonatomic,retain) UIColor *offColor ;

@property (nonatomic) CGFloat indicatorDiameter ;
@property (nonatomic) CGFloat indicatorSpace ;

@property (nonatomic, copy) void (^didChange)(DDPageControl *pageControl);

@end


//pageControl = [[DDPageControl alloc] init] ;
//[pageControl setCenter: CGPointMake(self.view.center.x, self.view.bounds.size.height-30.0f)] ;
//[pageControl setNumberOfPages: numberOfPages] ;
//[pageControl setCurrentPage: 0] ;
//[pageControl addTarget: self action: @selector(pageControlClicked:) forControlEvents: UIControlEventValueChanged] ;
//[pageControl setDefersCurrentPageDisplay: YES] ;
//[pageControl setType: DDPageControlTypeOnFullOffEmpty] ;
//[pageControl setOnColor: [UIColor colorWithWhite: 0.9f alpha: 1.0f]] ;
//[pageControl setOffColor: [UIColor colorWithWhite: 0.7f alpha: 1.0f]] ;
//[pageControl setIndicatorDiameter: 15.0f] ;
//[pageControl setIndicatorSpace: 15.0f] ;
//[self.view addSubview: pageControl] ;
