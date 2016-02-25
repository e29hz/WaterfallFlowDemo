//
//  HZWaterfallFlowView.m
//  WaterfallFlowDemo
//
//  Created by 鄂鸿桢 on 16/2/24.
//  Copyright © 2016年 e29hz. All rights reserved.
//

#import "HZWaterfallFlowView.h"
#import "HZWaterfallFlowViewCell.h"

#define HZWaterfallFlowViewDefaultCellH 70
#define HZWaterfallFlowViewDefaultNumberOfColumns 3
#define HZWaterfallFlowViewDefaultMargin 10

@interface HZWaterfallFlowView ()
/**
 *  所有cell的frame数据
 */
@property (nonatomic, strong) NSMutableArray *cellFrames;
/**
 *  正在展示的cell
 */
@property (nonatomic, strong) NSMutableDictionary *displayingCells;
/**
 *  缓存池（用Set，存放离开屏幕的cell）
 */
@property (nonatomic, strong) NSMutableSet *reusableCells;

@end

@implementation HZWaterfallFlowView

#pragma mark - 初始化

- (NSMutableArray *)cellFrames
{
    if (_cellFrames == nil) {
        self.cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

- (NSMutableDictionary *)displayingCells
{
    if (_displayingCells == nil) {
        self.displayingCells = [NSMutableDictionary dictionary];
    }
    return _displayingCells;
}

- (NSMutableSet *)reusableCells
{
    if (_reusableCells == nil) {
        self.reusableCells = [NSMutableSet set];
    }
    return _reusableCells;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self reloadData];
}

#pragma mark - 公共接口
/**
 *  cell的宽度
 */
- (CGFloat)cellWith
{
    // 总列数
    NSInteger numberOfColumns = [self numberOfColumns];
    //间距
    CGFloat leftMargin = [self marginForType:HZWaterfallFlowViewMarginTypeLeft];
    CGFloat rightMargin = [self marginForType:HZWaterfallFlowViewMarginTypeRight];
    CGFloat columnMargin = [self marginForType:HZWaterfallFlowViewMarginTypeColumn];
    // cell的宽度
    return (self.bounds.size.width - leftMargin - rightMargin - (numberOfColumns - 1) * columnMargin) / numberOfColumns;
}

/**
 *  刷新数据
 */
- (void)reloadData
{
    
    //清空之前的所有数据
    [self.displayingCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
    // 移除正在显示的cell
    [self.displayingCells removeAllObjects];
    [self.cellFrames removeAllObjects];
    [self.reusableCells removeAllObjects];
    
    // cell总数
    NSInteger numberOfCells = [self.dataSource numberOfCellsInWaterfallFlowView:self];
    
    // 总列数
    NSInteger numberOfColumns = [self numberOfColumns];
    
    // 间距
    CGFloat topMargin = [self marginForType:HZWaterfallFlowViewMarginTypeTop];
    CGFloat bottomMargin = [self marginForType:HZWaterfallFlowViewMarginTypeBottom];
    CGFloat leftMargin = [self marginForType:HZWaterfallFlowViewMarginTypeLeft];
    CGFloat columnMargin = [self marginForType:HZWaterfallFlowViewMarginTypeColumn];
    CGFloat rowMargin = [self marginForType:HZWaterfallFlowViewMarginTypeRow];
    
    // cell的宽度
    CGFloat cellW = [self cellWith];
    
    //用一个C语言数组存放所有列的最大Y值
    CGFloat maxYOfColumns[numberOfColumns];
    for (int i = 0; i < numberOfColumns; i++) {
        maxYOfColumns[i] = 0.0;
    }
    
    //计算所有cell的frame
    
    for (int i = 0; i < numberOfCells; i++) {
        //cell处在第几列
        NSUInteger cellColumn = 0;
        //cell所处列的最大Y值
        CGFloat maxYOfCellColumn = maxYOfColumns[cellColumn];
        
        for (int j = 0; j < numberOfColumns; j++) {
            if (maxYOfColumns[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYOfColumns[j];
            }
        }
        
        // 询问代理i 位置的高度
        CGFloat cellH = [self heightAtIndex:i];
        
        CGFloat cellX = leftMargin +cellColumn *(cellW + columnMargin);
        CGFloat cellY = 0;
        if (maxYOfCellColumn == 0.0) {// 首行
            cellY = topMargin;
        } else {
            cellY = maxYOfCellColumn + rowMargin;
        }
        
        // 添加frame到数组中
        CGRect cellFrame = CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:cellFrame]];
        
        // 更新最短列的最大Y值
        maxYOfColumns[cellColumn] = CGRectGetMaxY(cellFrame);
    }
    //设置contentSize
    CGFloat contentH = maxYOfColumns[0];
    for (int j = 0; j <numberOfColumns; j++) {
        if (maxYOfColumns[j] > contentH) {
            contentH = maxYOfColumns[j];
        }
    }
    contentH += bottomMargin;
    self.contentSize = CGSizeMake(0, contentH);
}
/**
 *  当UIScrollview滚动时会调用该方法
 */
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // 向数据源要对应位置的cell
    NSUInteger numberOfCells = self.cellFrames.count;
    for (int i = 0; i < numberOfCells; i++) {
        // 去除i位置的的frame
        CGRect cellFrame = [self.cellFrames[i] CGRectValue];
        // 优先从字典中去除i位置的cell
        HZWaterfallFlowViewCell *cell = self.displayingCells[@(i)];

        // 判断i位置的frame是否在屏幕上
        if ([self isInScreen:cellFrame]) {//在屏幕上
            if (cell == nil) { //字典中没有cell, 再创建
                cell = [self.dataSource waterfallFlowView:self cellAtIndex:i];
                cell.frame = cellFrame;
                [self addSubview:cell];
                
                //存放到字典中
                self.displayingCells[@(i)] = cell;
            }
        } else { // 不在屏幕上
            if (cell) {
                // 从scrollview和字典中移除
                [cell removeFromSuperview];
                [self.displayingCells removeObjectForKey:@(i)];
                
                // 存进缓存池
                [self.reusableCells addObject:cell];
            }
        }
        
    }
}

- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
    __block HZWaterfallFlowViewCell *reusableCell = nil;
    
    [self.reusableCells enumerateObjectsUsingBlock:^(HZWaterfallFlowViewCell *cell, BOOL * _Nonnull stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell) { // 从缓存池中移除
        [self.reusableCells removeObject:reusableCell];
    }
    return reusableCell;
}

#pragma mark - 私有方法

/**
 *  判断frame是否显示在屏幕上
 */
- (BOOL)isInScreen:(CGRect)frame
{
    return (CGRectGetMaxY(frame) > self.contentOffset.y) &&
    (CGRectGetMinY(frame) < self.contentOffset.y + self.bounds.size.height);
}
/**
 *  间距
 */
- (CGFloat)marginForType:(HZWaterfallFlowViewMarginType)marginType
{
    if ([self.delegate respondsToSelector:@selector(waterfallFlowView:marginForType:)]) {
        return [self.delegate waterfallFlowView:self marginForType:marginType];
    } else {
        return HZWaterfallFlowViewDefaultMargin;
    }
}
/**
 *  总列数
 */
- (NSUInteger)numberOfColumns
{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterfallFlowView:)]) {
        return [self.dataSource numberOfColumnsInWaterfallFlowView:self];
    } else {
        return HZWaterfallFlowViewDefaultNumberOfColumns;
    }
}
/**
 *  index位置对应的高度
 */
- (CGFloat)heightAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(waterfallFlowView:heightAtIndex:)]) {
        return [self.delegate waterfallFlowView:self heightAtIndex:index];
    } else {
        return HZWaterfallFlowViewDefaultCellH;
    }
}

#pragma mark - 事件处理
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (![self.delegate respondsToSelector:@selector(waterfallFlowView:didSelectedAtIndex:)]) {
        return;
    }
    //获得触摸点
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectIndex = nil;
    
    [self.displayingCells enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, HZWaterfallFlowViewCell *cell, BOOL * _Nonnull stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            selectIndex = key;
            *stop = YES;
        }
    }];
    
    if (selectIndex) {
        [self.delegate waterfallFlowView:self didSelectedAtIndex:selectIndex.unsignedIntegerValue];
    }
}

@end
