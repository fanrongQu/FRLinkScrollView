//
//  FRLinkScrollViewController.h
//  FRLinkScroll
//
//  Created by mac on 2018/3/1.
//  Copyright © 2018年 QFR. All rights reserved.
//

#import <UIKit/UIKit.h>

// 视图下拉弹性效果通知
static NSString * const FRLinkScrollTopBouncesNote = @"FRLinkScrollTopBouncesNote";

// 视图上拉弹性效果通知
static NSString * const FRLinkScrollBottomBouncesNote = @"FRLinkScrollBottomBouncesNote";

@interface FRLinkScrollViewController : UIViewController

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIScrollView *mainScrollView;
@property (nonatomic, strong) UIScrollView *subScrollView;

@property (nonatomic, strong) NSMutableArray *childVCArray;
@property (nonatomic, strong) UITableView *childScrollView;

@end

@interface FRDynamicItem : NSObject <UIDynamicItem>

@property (nonatomic, readwrite) CGPoint center;
@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readwrite) CGAffineTransform transform;

@end
