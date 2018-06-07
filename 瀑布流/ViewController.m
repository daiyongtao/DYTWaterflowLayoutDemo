//
//  ViewController.m
//  瀑布流
//
//  Created by 戴永涛 on 2018/6/6.
//  Copyright © 2018年 DaiYongtao. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    NSLog(@"The segue id is %@", segue.identifier);
    UIViewController *destinationVC = segue.destinationViewController;
    if ([destinationVC isKindOfClass:[CollectionViewController class]]) {
        CollectionViewController *collectionVC = (CollectionViewController *)destinationVC;
        // 垂直
        if ([segue.identifier isEqualToString:@"vertical"]) {
            collectionVC.type = VerticalType;
        }
        // 水平
        else if ([segue.identifier isEqualToString:@"horizontal"]) {
            collectionVC.type = HorizontalType;
        }
    }
}

@end
