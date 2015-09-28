//
//  KJSliderViewManager.h
//  AppFor55BBS
//
//  Created by KepenJ on 15/9/24.
//  Copyright © 2015年 55BBS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol KJSliderViewManagerDelegate;
@protocol KJSliderViewManagerDataSource;
@interface KJSliderViewManager : NSObject
@property (nonatomic,assign) BOOL isTitleHighlight;        //default is YES
- (instancetype)initWithFatherViewController:(UIViewController<KJSliderViewManagerDelegate,KJSliderViewManagerDataSource>  *)fatherVC;
- (UIViewController *)currentViewController;
@end


@protocol KJSliderViewManagerDelegate <NSObject>
@optional
- (void)kjSliderViewManager:(KJSliderViewManager *)manager didScrollAtIndex:(NSInteger)index;
@end

@protocol KJSliderViewManagerDataSource <NSObject>
- (NSInteger)numberOfTitleViewInKJSliderViewTopScrollView:(UIScrollView *)topScrollView;
- (NSString *)kjSliderViewManager:(KJSliderViewManager *)manager titleInTopScrollView:(UIScrollView *)scrollView atIndex:(NSInteger)index;
- (UIViewController *)kjSliderViewManager:(KJSliderViewManager *)manager viewControllerInListScrollView:(UIScrollView *)listScrollView aiIndex:(NSInteger)index;
@end