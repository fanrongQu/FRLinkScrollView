//
//  NewsViewController.m
//  NYNews
//
//  Created by mac on 2017/8/29.
//  Copyright © 2017年 fanrongQu. All rights reserved.
//

#import "NewsViewController.h"
#import "NewsListViewController.h"

@interface NewsViewController ()

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getNewsMenus];
    
    [self setNewsView];
    
}

- (void)setNewsView{
    
    [self setUpTitleEffect:^(BOOL *isShowAddMenuView, UIColor *__autoreleasing *titleScrollViewColor, UIColor *__autoreleasing *norColor, UIColor *__autoreleasing *selColor, UIFont *__autoreleasing *titleFont, CGFloat *titleHeight) {
        *isShowAddMenuView = NO;
        *titleScrollViewColor = [UIColor blueColor];
        *norColor = [UIColor lightGrayColor];
        *titleHeight = 40;
    }];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    [self setUpContentViewFrame:^(UIView *contentView) {
        contentView.frame = CGRectMake(0, 0, width, height - 64);
    }];
    
    // 设置字体缩放
    [self setUpTitleScale:^(BOOL *isShowTitleScale, CGFloat *titleScale) {
        
        // 是否需要字体缩放
        *isShowTitleScale = YES;
        
        // 字体缩放比例
        *titleScale = 1.22;
    }];
}

/**
 *  获取所有新闻分类
 */
- (void)getNewsMenus {
    
    NSArray *newsMenus = @[@"标题1",@"标题2",@"标题3",@"标题4",@"标题5"];
   
    [self setUpAllViewControllerWithArray:newsMenus];
}

// 添加所有子控制器
- (void)setUpAllViewControllerWithArray:(NSArray *)array {

    NSInteger count = array.count;
    for (int i = 0; i < count; i++) {
        
        NSString *name = array[i];
        
        NewsListViewController *childVC = [[NewsListViewController alloc] init];
        childVC.title = name;
        
        [self addChildViewController:childVC];

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"setUpAllViewControllerSuccess" object:nil];
}


@end
