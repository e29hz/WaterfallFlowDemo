//
//  HZWaterfallFlowView.h
//  WaterfallFlowDemo
//
//  Created by 鄂鸿桢 on 16/2/24.
//  Copyright © 2016年 e29hz. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    
    HZWaterfallFlowViewMarginTypeTop,
    HZWaterfallFlowViewMarginTypeBottom,
    HZWaterfallFlowViewMarginTypeLeft,
    HZWaterfallFlowViewMarginTypeRight,
    HZWaterfallFlowViewMarginTypeRow,// 每行
    HZWaterfallFlowViewMarginTypeColumn,// 每列
    
}HZWaterfallFlowViewMarginType;

@class HZWaterfallFlowView, HZWaterfallFlowViewCell;

/**
 *  数据源方法
 */
@protocol HZWaterfallFlowViewDataSource <NSObject>

@required
/**
 *  共有多少数据
 */
- (NSUInteger)numberOfCellsInWaterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView;

/**
 *  返回index位置, 对应的cell
 */
- (HZWaterfallFlowViewCell *)waterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView cellAtIndex:(NSUInteger)index;

@optional

/**
 *  一共有多少列(默认为3列)
 */
- (NSUInteger)numberOfColumnsInWaterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView;
@end

/**
 *  代理方法
 */
@protocol HZWaterfallFlowViewDelegate <UIScrollViewDelegate>

@optional
/**
 *  index位置cell对应的高度
 */
- (CGFloat)waterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView heightAtIndex:(NSUInteger)index;
/**
 *  选中了index位置的cell
 */
- (void)waterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView didSelectedAtIndex:(NSUInteger)index;
/**
 *  cell之间的间距
 */
- (CGFloat)waterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView marginForType:(HZWaterfallFlowViewMarginType)marginType;

@end

@interface HZWaterfallFlowView : UIScrollView
/**
 *  数据源
 */
@property (nonatomic, weak) id<HZWaterfallFlowViewDataSource> dataSource;

/**
 *  代理
 */
@property (nonatomic, weak) id<HZWaterfallFlowViewDelegate> delegate;
/**
 *  刷新数据
 */
- (void)reloadData;
/**
 *  cell的宽度
 */
- (CGFloat)cellWith;

/**
 *  根据标识去缓存池查找可循环利用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;
@end
