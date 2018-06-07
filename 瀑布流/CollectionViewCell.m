//
//  CollectionViewCell.m
//  瀑布流
//
//  Created by 戴永涛 on 2018/6/6.
//  Copyright © 2018年 DaiYongtao. All rights reserved.
//

#import "CollectionViewCell.h"

@implementation CollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = self.bounds;
        [self addSubview:_imageView];
    }
    return self;
}

@end
