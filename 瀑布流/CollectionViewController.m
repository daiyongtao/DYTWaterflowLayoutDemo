//
//  CollectionViewController.m
//  瀑布流
//
//  Created by 戴永涛 on 2018/6/6.
//  Copyright © 2018年 DaiYongtao. All rights reserved.
//

#import "CollectionViewController.h"
#import <SDWebImage/SDWebImageManager.h>
#import <MJRefresh/MJRefresh.h>
#import "CollectionViewCell.h"
#import "DYTWaterflowLayout.h"

@interface CollectionViewController ()
@property (nonatomic, strong) NSArray *imageUrls;
@property (nonatomic, strong) NSMutableArray *allImageUrls;
@property (nonatomic, strong) DYTWaterflowLayout *waterflowLayout;

@property (nonatomic, strong) NSMutableArray *widths;
@property (nonatomic, strong) NSMutableArray *heights;
@property (nonatomic, strong) NSMutableArray *picImageArr;

@end

@implementation CollectionViewController

static NSString * const reuseIdentifier = @"CollectionViewCell";

- (NSMutableArray *)picImageArr {
    
    if (!_picImageArr) {
        _picImageArr = [[NSMutableArray alloc] init];
    }
    return _picImageArr;
}

- (NSMutableArray *)heights {
    
    if (!_heights) {
        _heights = [[NSMutableArray alloc] init];
    }
    return _heights;
}

- (NSMutableArray *)widths {
    
    if (!_widths) {
        _widths = [[NSMutableArray alloc] init];
    }
    return _widths;
}

- (NSMutableArray *)allImageUrls {
    
    if (!_allImageUrls) {
        _allImageUrls = [[NSMutableArray alloc] init];
    }
    return _allImageUrls;
}

- (NSArray *)imageUrls {
    
    if (!_imageUrls) {
        _imageUrls = @[@"http://img3.duitang.com/uploads/item/201606/17/20160617222142_URteu.jpeg",
                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b10000_10000&sec=1528268921&di=9f9da0ba836304a18b6a1be5197ef009&src=http://www.people.com.cn/mediafile/pic/20170515/36/11848510404611533524.jpg",
                           @"http://img4.duitang.com/uploads/item/201502/02/20150202231253_AcknA.jpeg",
                           @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528351524065&di=070562cc3d6d1cd27f00b4e8a5b57826&imgtype=0&src=http%3A%2F%2Fi9.download.fd.pchome.net%2Ft_600x1024%2Fg1%2FM00%2F12%2F12%2FoYYBAFaPFvaIc2-nAAs53WedGpIAAC1aQIFZ1sACzn1901.jpg",
                           @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=514140065,1239689383&fm=27&gp=0.jpg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528380079937&di=0d68bbab118f3f5183ffa981881d5c8c&imgtype=0&src=http%3A%2F%2Fimg3.duitang.com%2Fuploads%2Fitem%2F201606%2F18%2F20160618180303_veKZL.jpeg",
                       @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1528351524063&di=3a980952f5d6fb9edd3d84814302b553&imgtype=0&src=http%3A%2F%2Fb.zol-img.com.cn%2Fsjbizhi%2Fimages%2F4%2F320x510%2F136841455226.jpg"];
    }
    return _imageUrls;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    // 设置布局
    DYTWaterflowLayout *layout = [[DYTWaterflowLayout alloc]init];
    layout.type = _type;
    // 设置相关属性(不设置的话也行，都有相关默认配置)
    layout.numberOfColumns = 3;
    layout.columnGap = 10;
    layout.rowGap = 10;
    layout.insets = UIEdgeInsetsMake(10, 10, 10, 10);
    layout.rowHeight = 100;
    self.collectionView.collectionViewLayout = self.waterflowLayout = layout;
    
    // 集成刷新控件
    MJWeakSelf
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf loadData];
        [weakSelf.collectionView.mj_header endRefreshing];
    }];
    [self.collectionView.mj_header beginRefreshing];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [weakSelf loadMoreData];
        [weakSelf.collectionView.mj_footer endRefreshing];
    }];
}

// 加载新数据(下拉刷新)
- (void)loadData {
    // 重置所有图片urls数组
    [self.allImageUrls removeAllObjects];
    [self.allImageUrls addObjectsFromArray:self.imageUrls];
    [self refresh:YES];
}

// 加载更多数据(上拉刷新)
- (void)loadMoreData {
    [self.allImageUrls addObjectsFromArray:self.imageUrls];
    [self refresh:NO];
}

- (void)refresh:(BOOL)isloadNewData {
    MJWeakSelf
    if (isloadNewData) {
        [weakSelf.picImageArr removeAllObjects];
        
        if (self.type == VerticalType) {
            [weakSelf.heights removeAllObjects];
        }else if (self.type == HorizontalType) {
            [weakSelf.widths removeAllObjects];
        }
    }
    for (int i = 0; i < self.allImageUrls.count; i++) {
        NSString *pidUrl = self.allImageUrls[i];
        [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:pidUrl] options:SDWebImageRefreshCached progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
            
        } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
            
            if (weakSelf.type == VerticalType) {
                if (weakSelf.heights.count == weakSelf.allImageUrls.count) {
                    return;
                }
            }else if (weakSelf.type == HorizontalType) {
                if (weakSelf.widths.count == weakSelf.allImageUrls.count) {
                    return;
                }
            }
            
            if(image){
                if (weakSelf.picImageArr.count < weakSelf.allImageUrls.count) {
                    [weakSelf.picImageArr addObject:image];
                }
                
                if (weakSelf.type == HorizontalType) {
                    if (weakSelf.widths.count < weakSelf.allImageUrls.count) {
                        
                        // 根据图片原始比例 计算 当前图片的宽度(高度固定)
                        CGFloat scale = image.size.width / image.size.height;
                        CGFloat height = weakSelf.waterflowLayout.rowHeight;
                        CGFloat width = height * scale;
                        NSNumber *widthNum = [NSNumber numberWithFloat:width];
                        [weakSelf.widths addObject:widthNum];
                    }
                    if (weakSelf.widths.count == weakSelf.allImageUrls.count) {
                        // 赋值所有cell的宽度数组itemWidths
                        weakSelf.waterflowLayout.itemWidths = weakSelf.widths;
                        [weakSelf.collectionView reloadData];
                    }
                }else if (weakSelf.type == VerticalType) {
                    if (weakSelf.heights.count < weakSelf.allImageUrls.count) {
                        
                        // 根据图片原始比例 计算 当前图片的高度(宽度固定)
                        CGFloat scale = image.size.height / image.size.width;
                        CGFloat width = weakSelf.waterflowLayout.itemWidth;
                        CGFloat height = width * scale;
                        NSNumber *heightNum = [NSNumber numberWithFloat:height];
                        [weakSelf.heights addObject:heightNum];
                    }
                    if (weakSelf.heights.count == weakSelf.allImageUrls.count) {
                        // 赋值所有cell的高度数组itemHeights
                        weakSelf.waterflowLayout.itemHeights = weakSelf.heights;
                        [weakSelf.collectionView reloadData];
                    }
                }
            }
        }];
    }
}

#pragma mark <UICollectionViewDataSource>
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allImageUrls.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.imageView.image = self.picImageArr[indexPath.item];
    // 注：非常关键的一句，由于cell的复用，imageView的frame可能和cell对不上，需要重新设置。
    cell.imageView.frame = cell.bounds;
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

- (void)dealloc {
    NSLog(@"dealloc");
}


@end
