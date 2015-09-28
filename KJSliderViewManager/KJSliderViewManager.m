//
//  KJSliderViewManager.m
//  AppFor55BBS
//
//  Created by KepenJ on 15/9/24.
//  Copyright © 2015年 55BBS. All rights reserved.
//

#import "KJSliderViewManager.h"

#define kDefaultFont        [UIFont systemFontOfSize:18]
#define kDefaultLineColor   [UIColor redColor]
#define kTopScrollViewTag       (10000)
#define kListScrollViewTag      (10001)
#define kTitleLabeBetweenWidth  (20)

typedef NS_ENUM(NSInteger,ScrollingStatus) {
    Left,
    Right,
    None,
};

@interface KJSliderViewManager ()<UIScrollViewDelegate>
@property (nonatomic,weak) id <KJSliderViewManagerDelegate,KJSliderViewManagerDataSource> fatherVC;
@property (nonatomic,assign) ScrollingStatus status;
@property (nonatomic,assign) int currentIndex;
@property (nonatomic,strong) UIScrollView * topScrollView;
@property (nonatomic,strong) UIScrollView * listScrollView;
@property (nonatomic,strong) UIImageView * lineImageView;
@property (nonatomic,strong) NSMutableArray * topScrollViewArray;
@property (nonatomic,strong) NSMutableArray * listScrollViewArray;
@property (nonatomic,strong) UIViewController * currentVC;
@property (nonatomic,strong) UIFont * titleFont;
@property (nonatomic,strong) UIColor * lineColor;
@property (nonatomic,assign) NSInteger numberOfTitleViews;
@property (nonatomic,assign) BOOL isTapTitleLabel;
@property (nonatomic,assign) CGFloat lastPositionX;
@end

@implementation KJSliderViewManager
#pragma mark -
#pragma mark -Init
- (instancetype)initWithFatherViewController:(UIViewController<KJSliderViewManagerDelegate,KJSliderViewManagerDataSource>  *)fatherVC {
    self = [super init];
    if (self) {
        _topScrollViewArray = [NSMutableArray array];
        _listScrollViewArray = [NSMutableArray array];
        _titleFont = kDefaultFont;
        _lineColor = kDefaultLineColor;
        _fatherVC = fatherVC;
        _isTapTitleLabel = NO;
        _lastPositionX = 0.0;
        _status = None;
        _currentIndex = 0;
        [self prepareViews];
    }
    return self;
}
#pragma mark -
#pragma mark -PrepareViews
- (void)prepareViews {
    if ([self.fatherVC respondsToSelector:@selector(numberOfTitleViewInKJSliderViewTopScrollView:)]) {
        _numberOfTitleViews = [self.fatherVC numberOfTitleViewInKJSliderViewTopScrollView:self.topScrollView];
    }
    if ([self.fatherVC isKindOfClass:[UIViewController class]]) {
        [self kj_updateTopScrollView];
        [self kj_updateListScrollView];
        UIViewController * vc = (UIViewController *)self.fatherVC;
        vc.navigationItem.titleView = self.topScrollView;
        vc.view = self.listScrollView;
    }
}

#pragma mark -
#pragma mark -GetMethod
- (UIScrollView *)topScrollView {
    if (!_topScrollView) {
        _topScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _topScrollView.tag = kTopScrollViewTag;
        _topScrollView.bounces = NO;
        _topScrollView.delegate = self;
        _topScrollView.backgroundColor = [UIColor clearColor];
        _topScrollView.showsHorizontalScrollIndicator = NO;
        _topScrollView.showsVerticalScrollIndicator = NO;
        _topScrollView.bounces = NO;
    }
    return _topScrollView;
}
- (UIScrollView *)listScrollView {
    if (!_listScrollView) {
        _listScrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
        _listScrollView.delegate = self;
        _listScrollView.tag = kListScrollViewTag;
        _listScrollView.backgroundColor = [UIColor clearColor];
        _listScrollView.pagingEnabled = YES;
        _listScrollView.showsHorizontalScrollIndicator = NO;
        _listScrollView.showsVerticalScrollIndicator = NO;
        _listScrollView.bounces = NO;

    }
    return _listScrollView;
}
- (UIImageView *)lineImageView {
    if (!_lineImageView) {
        _lineImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _lineImageView.backgroundColor = self.lineColor;
    }
    return _lineImageView;
}
- (UIViewController *)currentViewController {
    return self.currentVC;
}
#pragma mark -
#pragma mark -ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    if (!self.isTapTitleLabel && scrollView.tag == kListScrollViewTag) {
        UILabel * nextLabel;
        if (scrollView.contentOffset.x - self.lastPositionX < 0) {
            self.status = Left;
            nextLabel = [self kj_getTitleLabelFromIndex:self.currentIndex-1];
        }
        else if (scrollView.contentOffset.x - self.lastPositionX > 0){
            self.status = Right;
            nextLabel = [self kj_getTitleLabelFromIndex:self.currentIndex+1];
            
        }
        if (nextLabel) {
            UILabel * currentLabel = [self kj_getCurrentTitleLabel];
            CGRect rect = self.lineImageView.frame;

            if (nextLabel.frame.size.width >= currentLabel.frame.size.width) {
                rect.origin.x = ((currentLabel.frame.size.width + kTitleLabeBetweenWidth) / self.listScrollView.frame.size.width) * scrollView.contentOffset.x;
                rect.size.width = currentLabel.frame.size.width + ((nextLabel.frame.size.width - currentLabel.frame.size.width) / self.listScrollView.frame.size.width) * fabs(scrollView.contentOffset.x - self.lastPositionX);

            }
            else if (nextLabel.frame.size.width < currentLabel.frame.size.width){
                rect.origin.x = ((nextLabel.frame.size.width + kTitleLabeBetweenWidth) / self.listScrollView.frame.size.width) * scrollView.contentOffset.x;
                rect.size.width = currentLabel.frame.size.width + ((nextLabel.frame.size.width - currentLabel.frame.size.width) / self.listScrollView.frame.size.width) * fabs(scrollView.contentOffset.x - self.lastPositionX);

            }
            self.lineImageView.frame = rect;
        }
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = (int)(scrollView.contentOffset.x / [[UIScreen mainScreen] bounds].size.width);
    self.lastPositionX = scrollView.contentOffset.x;
    if (scrollView.tag == kListScrollViewTag) {
        UILabel * label = [self kj_getCurrentTitleLabel];
        if (label) {
            [self kj_updateLineImageViewFrameWithCurrentLabelFrame:label.frame];
        }
    }
}
#pragma mark -
#pragma mark -PrivteMethod
- (void)kj_updateTopScrollView {
    if (self.topScrollViewArray && self.topScrollViewArray.count != 0) {
        [self.topScrollViewArray removeAllObjects];
    }
    CGFloat titlePositionX = 0;
    for (int i = 0; i < self.numberOfTitleViews; i++) {
        if ([self.fatherVC respondsToSelector:@selector(kjSliderViewManager:titleInTopScrollView:atIndex:)]) {
            NSString * titleString = [self.fatherVC kjSliderViewManager:self titleInTopScrollView:self.topScrollView atIndex:i];
            if (titleString) {
                CGSize size = [titleString sizeWithAttributes:@{NSFontAttributeName:self.titleFont}];
                UILabel * titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(titlePositionX, 0, size.width, size.height)];
                titleLabel.userInteractionEnabled = YES;
                titleLabel.text = titleString;
                titleLabel.font = self.titleFont;
                titleLabel.textAlignment = NSTextAlignmentCenter;
                titleLabel.tag = i;
                UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(kj_tapTheTitleLabel:)];
                [titleLabel addGestureRecognizer:tap];
                [self.topScrollView addSubview:titleLabel];
                [self.topScrollViewArray addObject:titleLabel];
                titlePositionX += size.width+((i != self.numberOfTitleViews-1)?kTitleLabeBetweenWidth:0);
                self.topScrollView.frame = CGRectMake(0, 0, titlePositionX, size.height+10);
                self.topScrollView.contentSize = CGSizeMake(titlePositionX, size.height+10);
            }
            else {
                NSAssert(0, @"title string is nil！");
                return;
            }
        }
    }
    UILabel * label = [self.topScrollViewArray objectAtIndex:0];
    if (label) {
        self.lineImageView.frame = CGRectMake(0, self.topScrollView.frame.size.height-2, label.frame.size.width, 2);
        [self.topScrollView addSubview:self.lineImageView];
    }
}
- (void)kj_updateListScrollView {
    if (self.listScrollViewArray && self.listScrollViewArray.count != 0) {
        [self.listScrollViewArray removeAllObjects];
    }
    for (int i = 0; i < self.numberOfTitleViews; i++) {
        if ([self.fatherVC respondsToSelector:@selector(kjSliderViewManager:viewControllerInListScrollView:aiIndex:)]) {
            id objc = [self.fatherVC kjSliderViewManager:self viewControllerInListScrollView:self.listScrollView aiIndex:i];
            if ([objc isKindOfClass:[UIViewController class]]) {
                UIViewController * vc = (UIViewController *)objc;
                CGRect rect = vc.view.frame;
                rect.origin.x = i*vc.view.frame.size.width;
                vc.view.frame = rect;
                self.listScrollView.frame = CGRectMake(0, 0, self.numberOfTitleViews*vc.view.frame.size.width, vc.view.frame.size.height-64);
                self.listScrollView.contentSize = CGSizeMake(self.numberOfTitleViews*vc.view.frame.size.width, vc.view.frame.size.height-64);
                [self.listScrollViewArray addObject:vc];
                [self.listScrollView addSubview:vc.view];
            }
            else {
                NSAssert(0, @"objc is not a kind of view controller.");
            }
        }
    }
}
- (void)kj_tapTheTitleLabel:(UITapGestureRecognizer *)tap {
    self.isTapTitleLabel = YES;
    [self kj_topScrollViewScrollToIndex:[tap.view tag]];
    [self kj_listScrollViewScrollToIndex:[tap.view tag]];
}
- (void)kj_topScrollViewScrollToIndex:(NSInteger)index {
    UILabel * label = [self.topScrollViewArray objectAtIndex:index];
    if (label) {
        [self kj_updateLineImageViewFrameWithCurrentLabelFrame:label.frame];
    }
}
- (void)kj_listScrollViewScrollToIndex:(NSInteger)index {
    [self.listScrollView setContentOffset:CGPointMake(index*[[UIScreen mainScreen] bounds].size.width, self.listScrollView.contentOffset.y) animated:YES];
    self.currentVC = [self.listScrollViewArray objectAtIndex:index];
    if ([self.fatherVC respondsToSelector:@selector(kjSliderViewManager:didScrollAtIndex:)]) {
        [self.fatherVC kjSliderViewManager:self didScrollAtIndex:index];
    }

}
- (void)kj_updateLineImageViewFrameWithCurrentLabelFrame:(CGRect)labelFrame {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.lineImageView.frame = CGRectMake(labelFrame.origin.x, weakSelf.lineImageView.frame.origin.y, labelFrame.size.width, 2);
    } completion:^(BOOL finished) {
        weakSelf.isTapTitleLabel = NO;
    }];
}
- (UILabel *)kj_getCurrentTitleLabel {
    if (self.topScrollViewArray && self.topScrollViewArray.count != 0) {
        return self.topScrollViewArray[self.currentIndex];
    }
    return nil;
}
- (UILabel *)kj_getTitleLabelFromIndex:(NSInteger)index {
    if ((self.topScrollViewArray && self.topScrollViewArray.count != 0) && (index < self.topScrollViewArray.count || index > 0) ) {
        return self.topScrollViewArray[index];
    }
    return nil;
}
@end
