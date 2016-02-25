//
//  HZShopCell.m
//  WaterfallFlowDemo
//
//  Created by 鄂鸿桢 on 16/2/25.
//  Copyright © 2016年 e29hz. All rights reserved.
//

#import "HZShopCell.h"
#import "HZWaterfallFlowView.h"
#import "HZShop.h"
#import "UIImageView+WebCache.h"

@interface HZShopCell()
@property (weak, nonatomic) UIImageView *imageView;
@property (weak, nonatomic) UILabel *priceLabel;
@end

@implementation HZShopCell

+ (instancetype)cellWithWaterfallFlowView:(HZWaterfallFlowView *)waterfallFlowView
{
    static NSString *ID = @"shop";
    HZShopCell *cell = [waterfallFlowView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[HZShopCell alloc] init];
        cell.identifier = ID;
    }
    return cell;
    
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        self.imageView = imageView;
        
        UILabel *priceLabel = [[UILabel alloc] init];
        priceLabel.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
        priceLabel.textAlignment = NSTextAlignmentCenter;
        priceLabel.textColor = [UIColor whiteColor];
        [self addSubview:priceLabel];
        self.priceLabel = priceLabel;
    }
    return self;
}


- (void)setShop:(HZShop *)shop
{
    _shop = shop;
    
    self.priceLabel.text = shop.price;
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:shop.img] placeholderImage:[UIImage imageNamed:@"loading"]];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.imageView.frame = self.bounds;
    
    CGFloat priceX = 0;
    CGFloat priceH = 25;
    CGFloat priceY = self.bounds.size.height - priceH;
    CGFloat priceW = self.bounds.size.width;
    self.priceLabel.frame = CGRectMake(priceX, priceY, priceW, priceH);
}

@end
