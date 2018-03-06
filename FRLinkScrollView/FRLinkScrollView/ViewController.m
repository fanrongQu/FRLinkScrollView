//
//  ViewController.m
//  FRLinkScrollView
//
//  Created by mac on 2018/3/6.
//  Copyright © 2018年 fanrongQu. All rights reserved.
//

#import "ViewController.h"
#import "NewsViewController.h"
#import "NewsListViewController.h"

@interface ViewController ()

@property(nonatomic, strong)NewsViewController *newsVC;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat width = self.view.bounds.size.width;
    CGFloat height = self.view.bounds.size.height;
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, width, 250)];
    topView.backgroundColor = [UIColor redColor];
    [self.mainScrollView addSubview:topView];
    self.topView = topView;
    
    self.newsVC = [[NewsViewController alloc] init];
    [self addChildViewController:self.newsVC];
    
    [self.mainScrollView addSubview:self.newsVC.view];
    self.newsVC.view.frame = CGRectMake(0, CGRectGetMaxY(topView.frame), width, height);
    
    [self setUpAllViewControllerSuccess];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpAllViewControllerSuccess) name:@"setUpAllViewControllerSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(FRSlideMenuClickOrScrollDidFinshNote:) name:FRSlideMenuClickOrScrollDidFinshNote object:nil];
}



- (void)setUpAllViewControllerSuccess {
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    self.childVCArray = [NSMutableArray arrayWithCapacity:0];
    NSArray *childVCs = self.newsVC.childViewControllers;
    for (UIViewController *childVC in childVCs) {
        if ([childVC isKindOfClass:[NewsListViewController class]]) {
            NewsListViewController *listVC = (NewsListViewController *)childVC;
            listVC.tableView.scrollEnabled = NO;
            CGRect frame = listVC.tableView.frame;
            frame.origin.y = 0;
            frame.size.height = frame.size.height - 44 - 64;//标题高度  导航高度
            listVC.tableView.frame = frame;
            [self.childVCArray addObject:listVC.tableView];
        }
    }
    self.subScrollView = self.newsVC.contentScrollView;
    
    self.childScrollView = self.childVCArray.firstObject;
    
    self.mainScrollView.contentSize = CGSizeMake(width, CGRectGetHeight(self.topView.frame) - 64 + self.subScrollView.frame.size.height);
}


- (void)FRSlideMenuClickOrScrollDidFinshNote:(NSNotification *)noti {
    if ([noti.object isKindOfClass:[NewsListViewController class]]) {
        
        NewsListViewController *listVC = noti.object;
        self.childScrollView = listVC.tableView;
    }
}


@end
