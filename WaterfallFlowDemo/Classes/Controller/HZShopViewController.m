//
//  HZShopViewController.m
//  WaterfallFlowDemo
//
//  Created by 鄂鸿桢 on 16/2/25.
//  Copyright © 2016年 e29hz. All rights reserved.
//

#import "HZShopViewController.h"
#import "HZShopCell.h"
#import "HZWaterfallFlowView.h"
#import "HZShop.h"

@interface HZShopViewController ()<HZWaterfallFlowViewDataSource, HZWaterfallFlowViewDelegate>

@property (nonatomic, strong) NSMutableArray *shops;
@property (nonatomic, weak) HZWaterfallFlowView *waterfallFlowView;

@end

@implementation HZShopViewController

- (NSMutableArray *)shops
{
    if (_shops == nil) {
        self.shops = [NSMutableArray array];
    }
    return _shops;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 初始化数据
    NSArray *newShops = [HZShop mj_objectArrayWithFilename:@"2.plist"];
    [self.shops addObjectsFromArray:newShops];
    
    // 1.瀑布流控件
    HZWaterfallFlowView *waterfallFlowView = [[HZWaterfallFlowView alloc] init];
    waterfallFlowView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    waterfallFlowView.frame = self.view.bounds;
    waterfallFlowView.dataSource = self;
    waterfallFlowView.delegate = self;
    [self.view addSubview:waterfallFlowView];
    self.waterfallFlowView = waterfallFlowView;
    
    // 集成刷新控件
    self.waterfallFlowView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewShops)];
    self.waterfallFlowView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreShops)];

}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id <UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {//转屏前调用
//         [self.waterfallFlowView reloadData];
     } completion:^(id<UIViewControllerTransitionCoordinatorContext> context)
     {//转屏后调用
         [self.waterfallFlowView reloadData];
     }];
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (void)loadNewShops
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 加载1.plist
        NSArray *newShops = [HZShop mj_objectArrayWithFilename:@"1.plist"];
        [self.shops insertObjects:newShops atIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, newShops.count)]];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 刷新瀑布流控件
        [self.waterfallFlowView reloadData];
        
        // 停止刷新
        [self.waterfallFlowView.mj_header endRefreshing];
    });
}

- (void)loadMoreShops
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 加载3.plist
        NSArray *newShops = [HZShop mj_objectArrayWithFilename:@"3.plist"];
        [self.shops addObjectsFromArray:newShops];
    });
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 刷新瀑布流控件
        [self.waterfallFlowView reloadData];
        
        // 停止刷新
        [self.waterfallFlowView.mj_footer endRefreshing];
    });
}

#pragma mark - 数据源方法
- (NSUInteger)numberOfCellsInWaterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView{
    return self.shops.count;
}

- (HZWaterfallFlowViewCell *)waterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView cellAtIndex:(NSUInteger)index
{
    HZShopCell *cell = [HZShopCell cellWithWaterfallFlowView:waterfallFlowView];
    
    cell.shop = self.shops[index];
    
    return cell;
    
}

- (NSUInteger)numberOfColumnsInWaterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView
{
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        // 竖屏
        return 3;
    } else {
        return 5;
    }
}

#pragma mark - 代理方法
- (CGFloat)waterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView heightAtIndex:(NSUInteger)index
{
    HZShop *shop = self.shops[index];
    //根据cell的宽度和图片的宽高比 算出cell高度
    return waterfallFlowView.cellWith *shop.h / shop.w;
}

@end
