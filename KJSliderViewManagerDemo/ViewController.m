//
//  ViewController.m
//  KJSliderViewManagerDemo
//
//  Created by KepenJ on 15/9/28.
//  Copyright © 2015年 55BBS. All rights reserved.
//

#import "ViewController.h"
#import "KJSliderViewManager.h"
@interface ViewController () <KJSliderViewManagerDataSource,KJSliderViewManagerDelegate>
@property (nonatomic,copy) NSArray * titleArray;
@property (nonatomic,strong) NSMutableArray * vcArray;
@property (nonatomic,strong) KJSliderViewManager * titleView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.titleArray = @[@"标题",@"我是长标题"];
    self.vcArray = [NSMutableArray array];
    for (int i = 0; i<self.titleArray.count; i++) {
        UIViewController * vc = [[UIViewController alloc] init];
        UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 50)];
        label.center = vc.view.center;
        label.text = [NSString stringWithFormat:@"我是VC_%d",i+1];
        label.textAlignment = NSTextAlignmentCenter;
        [vc.view addSubview:label];
        [self.vcArray addObject:vc];
    }
    self.titleView = [[KJSliderViewManager alloc]initWithFatherViewController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (NSInteger)numberOfTitleViewInKJSliderViewTopScrollView:(UIScrollView *)topScrollView {
    return self.titleArray.count;
}
- (NSString *)kjSliderViewManager:(KJSliderViewManager *)manager titleInTopScrollView:(UIScrollView *)scrollView atIndex:(NSInteger)index {
    return self.titleArray[index];
}
- (UIViewController *)kjSliderViewManager:(KJSliderViewManager *)manager viewControllerInListScrollView:(UIScrollView *)listScrollView aiIndex:(NSInteger)index {
    return self.vcArray[index];
}
@end
