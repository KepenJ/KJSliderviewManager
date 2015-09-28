//
//  KJSliderViewManager.m
//  AppFor55BBS
//
//  Created by KepenJ on 15/9/24.
//  Copyright © 2015年 55BBS. All rights reserved.
//

#import "KJSliderViewManager.h"

#define kDefaultFont                [UIFont systemFontOfSize:18]
#define kDefaultLineColor           [UIColor redColor]
#define kTopScrollViewTag           (10000)
#define kListScrollViewTag          (10001)
#define kTitleLabeBetweenWidth      (20)
#define kTextHighlightColor         [UIColor blackColor]
#define kTextNormalColor            [UIColor grayColor]

typedef NS_ENUM(NSInteger,ScrollingStatus) {
    Left,
    Right,
    None,
};

@interface KJSliderViewManager ()<UIScrollViewDelegate>
@property (nonatomic,weak) id <KJSliderViewManagerDelegate,KJSliderViewManagerDataSource> fatherVC;
@property (nonatomic,assign) ScrollingStatus status;
@property (nonatomic,assign) NSInteger currentIndex;
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
        _isTitleHighlight = YES;
        [self updateViews];
        
    }
    return self;
}
#pragma mark -
#pragma mark -PrepareViews
- (void)updateViews {
    if ([self.fatherVC respondsToSelector:@selector(numberOfTitleViewInKJSliderViewTopScrollView:)]) {
        _numberOfTitleViews = [self.fatherVC numberOfTitleViewInKJSliderViewTopScrollView:self.topScrollView];
    }
    if ([self.fatherVC isKindOfClass:[UIViewController class]]) {
        [self kj_updateTopScrollView];
        [self kj_updateListScrollView];
        [self kj_updateHighlightOfTitleOnTopScrollView];
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
        UILabel * currentLabel;
        CGRect rect = self.lineImageView.frame;
        if (scrollView.contentOffset.x - self.lastPositionX < 0) {
            self.status = Left;
            nextLabel = [self kj_getTitleLabelFromIndex:self.currentIndex-1];
            if (nextLabel) {
                currentLabel = [self kj_getTitleLabelFromIndex:self.currentIndex];
                rect.origin.x = currentLabel.frame.origin.x - ((nextLabel.frame.size.width + kTitleLabeBetweenWidth) / self.listScrollView.frame.size.width) * fabs(scrollView.contentOffset.x - self.lastPositionX);
            }
        }
        else if (scrollView.contentOffset.x - self.lastPositionX >= 0){
            self.status = Right;
            nextLabel = [self kj_getTitleLabelFromIndex:self.currentIndex+1];
            if (nextLabel) {
                currentLabel = [self kj_getTitleLabelFromIndex:self.currentIndex];
                rect.origin.x = currentLabel.frame.origin.x + ((currentLabel.frame.size.width + kTitleLabeBetweenWidth) / self.listScrollView.frame.size.width) * fabs(scrollView.contentOffset.x - self.lastPositionX);
            }
        }
        rect.size.width = currentLabel.frame.size.width + ((nextLabel.frame.size.width - currentLabel.frame.size.width) / self.listScrollView.frame.size.width) * fabs(scrollView.contentOffset.x - self.lastPositionX);
        self.lineImageView.frame = rect;
    }
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.currentIndex = (scrollView.contentOffset.x / [[UIScreen mainScreen] bounds].size.width);
    self.lastPositionX = scrollView.contentOffset.x;
    if (!self.isTapTitleLabel && scrollView.tag == kListScrollViewTag) {
        [self kj_updateLineImageViewFrameWithCurrentLabelWithIndex:self.currentIndex];
        [self kj_updateHighlightOfTitleOnTopScrollView];
    }
}
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.isTapTitleLabel = NO;
    self.currentIndex = (scrollView.contentOffset.x / [[UIScreen mainScreen] bounds].size.width);
    self.lastPositionX = scrollView.contentOffset.x;
    if (!self.isTapTitleLabel && scrollView.tag == kListScrollViewTag) {
        [self kj_updateLineImageViewFrameWithCurrentLabelWithIndex:self.currentIndex];
        [self kj_updateHighlightOfTitleOnTopScrollView];
    }
}
#pragma mark -
#pragma mark -setMethod
- (void)setIsTitleHighlight:(BOOL)isTitleHighlight {
    _isTitleHighlight = isTitleHighlight;
    [self kj_updateHighlightOfTitleOnTopScrollView];
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
    UILabel * label = [self kj_getTitleLabelFromIndex:0];
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
                self.listScrollView.frame = CGRectMake(0, 0, self.numberOfTitleViews*vc.view.frame.size.width, vc.view.frame.size.height);
                self.listScrollView.contentSize = CGSizeMake(self.numberOfTitleViews*vc.view.frame.size.width, vc.view.frame.size.height);
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
    [self kj_updateLineImageViewFrameWithCurrentLabelWithIndex:index];
}
- (void)kj_listScrollViewScrollToIndex:(NSInteger)index {
    [self.listScrollView setContentOffset:CGPointMake(index*[[UIScreen mainScreen] bounds].size.width, self.listScrollView.contentOffset.y) animated:YES];
    self.currentVC = [self.listScrollViewArray objectAtIndex:index];
    if ([self.fatherVC respondsToSelector:@selector(kjSliderViewManager:didScrollAtIndex:)]) {
        [self.fatherVC kjSliderViewManager:self didScrollAtIndex:index];
    }
    
}
- (void)kj_updateLineImageViewFrameWithCurrentLabelWithIndex:(NSInteger)index {
    UILabel * label = [self kj_getTitleLabelFromIndex:index];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.25 animations:^{
        weakSelf.lineImageView.frame = CGRectMake(label.frame.origin.x, weakSelf.lineImageView.frame.origin.y, label.frame.size.width, 2);
    } completion:^(BOOL finished) {
        
    }];
}
- (UILabel *)kj_getTitleLabelFromIndex:(NSInteger)index {
    if ((self.topScrollViewArray && self.topScrollViewArray.count != 0)) {
        if (index < 0) {
            index = 0;
        }
        else if ((index >= self.topScrollViewArray.count)) {
            index = self.topScrollViewArray.count - 1;
        }
        return self.topScrollViewArray[index];
    }
    return nil;
}
- (void)kj_updateHighlightOfTitleOnTopScrollView {
    if (self.isTitleHighlight) {
        for (int i = 0;i < self.topScrollViewArray.count;i++) {
            UILabel * label = self.topScrollViewArray[i];
            if (label && i == self.currentIndex) {
                label.textColor = kTextHighlightColor;
            }
            else {
                label.textColor = kTextNormalColor;
            }
        }
    }
}
@end
