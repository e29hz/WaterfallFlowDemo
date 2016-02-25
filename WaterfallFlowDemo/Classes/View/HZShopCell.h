//
//  HZShopCell.h
//  WaterfallFlowDemo
//
//  Created by 鄂鸿桢 on 16/2/25.
//  Copyright © 2016年 e29hz. All rights reserved.
//

#import "HZWaterfallFlowViewCell.h"

@class HZWaterfallFlowView, HZShop;

@interface HZShopCell : HZWaterfallFlowViewCell
+ (instancetype)cellWithWaterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView;

@property (nonatomic, strong) HZShop *shop;
@end
