//
//  DYTWaterflowLayout.m
//  瀑布流
//
//  Created by 戴永涛 on 2018/6/7.
//  Copyright © 2018年 DaiYongtao. All rights reserved.
//

#import "DYTWaterflowLayout.h"

@interface DYTWaterflowLayout()

@property (nonatomic, strong) NSMutableArray *itemAttributes; // 存放每个cell的布局属性

// 垂直瀑布流相关属性
@property (nonatomic, strong) NSMutableArray *columnsHeights; // 每一列的高度(count=多少列)
@property (nonatomic, assign) CGFloat maxHeight; // 最长列的高度(最大高度)
@property (nonatomic, assign) CGFloat minHeight; // 最短列的高度(最低高度)
@property (nonatomic, assign) NSInteger minIndex; // 最短列的下标
@property (nonatomic, assign) NSInteger maxIndex; // 最长列的下标

// 水平瀑布流相关属性
@property (nonatomic, strong) NSMutableArray *columnsWidths; // 每一行的宽度(count不确定)
@property (nonatomic, assign) NSInteger tempItemX; // 临时x : 用来计算每个cell的x值
@property (nonatomic, assign) NSInteger maxRowIndex; //最大行

@end

@implementation DYTWaterflowLayout

#pragma mark - 懒加载
- (NSMutableArray *)columnsHeights {
    if (!_columnsHeights) {
        self.columnsHeights = [NSMutableArray array];
    }
    return _columnsHeights;
}

- (NSMutableArray *)itemAttributes {
    if (!_itemAttributes) {
        self.itemAttributes = [NSMutableArray array];
    }
    return _itemAttributes;
}

#pragma mark - 初始化方法
- (instancetype)init {
    if (self = [super init]) {
        // 初始化默认值
        self.numberOfColumns = 3;
        self.columnGap = 10;
        self.rowGap = 10;
        self.insets = UIEdgeInsetsMake(10, 10, 10, 10);
    }
    return self;
}

#pragma mark - get方法
- (CGFloat)itemWidth {
   return (self.collectionView.frame.size.width - (self.numberOfColumns + 1)*self.columnGap) / self.numberOfColumns;
}

- (NSInteger)minIndex {

    NSInteger minIndex = 0;
    CGFloat minHeight = MAXFLOAT;
    for (NSInteger i = 0; i < self.numberOfColumns; i ++) {
        CGFloat currentHeight = [[self.columnsHeights objectAtIndex:i] floatValue];
        if (currentHeight < minHeight) {
            minHeight = currentHeight;
            minIndex = i;
        }
    }
    return minIndex;
}

- (NSInteger)maxIndex {

    NSInteger maxIndex = 0;
    CGFloat maxHeight = 0;
    for (NSInteger i = 0; i < self.numberOfColumns; i ++) {
        CGFloat currentHeight = [[self.columnsHeights objectAtIndex:i] floatValue];
        if (currentHeight > maxHeight) {
            maxHeight = currentHeight;
            maxIndex = i;
        }
    }
    return maxIndex;
}

#pragma mark -- 计算最长列和最短列的高度
- (CGFloat)minHeight {
    return [[self.columnsHeights objectAtIndex:self.minIndex] floatValue];
}

- (CGFloat)maxHeight {
    return [[self.columnsHeights objectAtIndex:self.maxIndex] floatValue];
}

#pragma mark -- 系统内部方法
/**
 *  重写父类布局
 */
- (void)prepareLayout {
    
    [super prepareLayout];
    // (水平瀑布流时)重置最大行
    if ((self.type == HorizontalType)) {
        self.maxRowIndex = 0;
    }
    
    if (self.type == VerticalType) {
        // 重置每一列的高度
        [self.columnsHeights removeAllObjects];
        for (NSUInteger i = 0; i < self.numberOfColumns; i++) {
            [self.columnsHeights addObject:@(self.insets.top)];
        }
    }
    
    // 计算所有cell的布局属性
    [self.itemAttributes removeAllObjects];
    NSUInteger itemCount = [self.collectionView numberOfItemsInSection:0];
    self.tempItemX = self.insets.left;
    for (NSUInteger i = 0; i < itemCount; ++i) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        if (self.type == VerticalType) {
            [self setVerticalFrame:indexPath];
        }else if ((self.type == HorizontalType)){
            [self setHorizontalFrame:indexPath];
        }
    }
}

/**
 *  水平瀑布：设置每一个attrs的frame，并加入数组中
 */
- (void)setHorizontalFrame:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    CGFloat w = [self.itemWidths[indexPath.item] floatValue];
    CGFloat width = w + self.columnGap;
    CGFloat h = (self.rowHeight == 0) ? 100 : self.rowHeight;
    
    /**
     *  如果当前的x值+当前cell的宽度 超出了 屏幕宽度，那么就要换行了。
     *  换行操作 : 最大行+1，tempItemX重置为10(self.insets.left)。
     */
    if (self.tempItemX + w > [UIScreen mainScreen].bounds.size.width) {
        self.maxRowIndex++;
        self.tempItemX = self.insets.left;
    }
    CGFloat x = self.tempItemX;
    CGFloat y = self.insets.top + self.maxRowIndex * (h + self.rowGap);
    attrs.frame = CGRectMake(x, y, w, h);
    
    /**
     * 注：1.cell的宽度和高度算起来比较简单 : 宽度由外部传进来，高度固定为rowHeight(默认为100)。
     *    2.cell的x : 通过tempItemX算好了。
     *    3.cell的y : minHeight最短列的高度，也就是最低高度，作为当前cell的起始y，当然要加上行之间的间隙。
     */
    
    NSLog(@"%@",NSStringFromCGRect(attrs.frame));
    [self.itemAttributes addObject:attrs];
    self.tempItemX += width;
}

/**
 *  垂直瀑布：设置每一个attrs的frame，并加入数组中
 */
- (void)setVerticalFrame:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // cell的frame
    CGFloat w = self.itemWidth;
    CGFloat h = [self.itemHeights[indexPath.item] floatValue];
    CGFloat x = self.insets.left + self.minIndex * (w + self.columnGap);
    CGFloat y = self.minHeight + self.rowGap;
    attrs.frame = CGRectMake(x, y, w, h);
    
    /**
     * 注：1.cell的宽度和高度算起来比较简单 : 宽度固定(itemWidth已经算好)，高度由外部传进来
     *    2.cell的x : minIndex最短列作为当前列。
     *    3.cell的y : minHeight最短列的高度，也就是最低高度，作为当前cell的起始y，当然要加上行之间的间隙。
     */
    
    // 更新数组中的最大高度
    self.columnsHeights[self.minIndex] = @(CGRectGetMaxY(attrs.frame));
    NSLog(@"%@",NSStringFromCGRect(attrs.frame));
    [self.itemAttributes addObject:attrs];
}

/**
 *  返回collectionView的尺寸
 */
- (CGSize)collectionViewContentSize {
    CGFloat height;
    if (self.type == HorizontalType) {
        CGFloat rowHeight = (self.rowHeight == 0) ? 100 : self.rowHeight;
        height = self.insets.top + (self.maxRowIndex+1) * (rowHeight + self.rowGap);
    }else {
        height = self.maxHeight;
    }
    return CGSizeMake(self.collectionView.frame.size.width, height);
}

/**
 *  所有元素（比如cell、补充控件、装饰控件）的布局属性
 */
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    return self.itemAttributes;
}

@end
