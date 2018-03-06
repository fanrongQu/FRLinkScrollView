//
//  FRLinkScrollViewController.m
//  FRLinkScroll
//
//  Created by mac on 2018/3/1.
//  Copyright © 2018年 QFR. All rights reserved.
//

#import "FRLinkScrollViewController.h"


static CGFloat rubberBandDistance(CGFloat offset, CGFloat dimension) {
    
    const CGFloat constant = 0.55f;
    CGFloat result = (constant * fabs(offset) * dimension) / (dimension + constant * fabs(offset));
    // The algorithm expects a positive offset, so we have to negate the result if the offset was negative.
    return offset < 0.0f ? -result : result;
}

@interface FRLinkScrollViewController ()<UIGestureRecognizerDelegate,UIScrollViewDelegate> {
    CGFloat width;
    CGFloat height;
    CGFloat currentScorllY;
    
    UIView *toolView;
    
    __block BOOL isVertical;//是否是垂直
}

//弹性和惯性动画
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, weak) UIDynamicItemBehavior *decelerationBehavior;
@property (nonatomic, strong) FRDynamicItem *dynamicItem;
@property (nonatomic, weak) UIAttachmentBehavior *springBehavior;

@end

@implementation FRLinkScrollViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    width = [UIScreen mainScreen].bounds.size.width;
    height = [UIScreen mainScreen].bounds.size.height;
    
    [self.view addSubview:self.mainScrollView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    pan.delegate = self;
    [self.view addGestureRecognizer:pan];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.dynamicItem = [[FRDynamicItem alloc] init];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.animator removeAllBehaviors];
}

- (UIScrollView *)mainScrollView {
    if (_mainScrollView == nil) {
        _mainScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, width, height - 64)];
        _mainScrollView.delegate = self;
        _mainScrollView.scrollEnabled = NO;
    }
    return _mainScrollView;
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer *)gestureRecognizer;
        CGFloat currentY = [recognizer translationInView:self.view].y;
        CGFloat currentX = [recognizer translationInView:self.view].x;
        
        if (currentY == 0.0) {
            return YES;
        } else {
            if (fabs(currentX)/currentY >= 5.0) {
                return YES;
            } else {
                return NO;
            }
        }
    }
    return NO;
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)recognizer {
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
            currentScorllY = self.mainScrollView.contentOffset.y;
            CGFloat currentY = [recognizer translationInView:self.view].y;
            CGFloat currentX = [recognizer translationInView:self.view].x;
            
//            if (currentY == 0.0) {
//                isVertical = NO;
//            } else {
                if (fabs(currentX)/currentY >= 5.0) {
                    isVertical = NO;
                } else {
                    isVertical = YES;
                }
//            }
            [self.animator removeAllBehaviors];
            break;
        case UIGestureRecognizerStateChanged:
        {
            //locationInView:获取到的是手指点击屏幕实时的坐标点；
            //translationInView：获取到的是手指移动后，在相对坐标中的偏移量
            
            if (isVertical) {
                //往上滑为负数，往下滑为正数
                CGFloat currentY = [recognizer translationInView:self.view].y;
                [self controlScrollForVertical:currentY AndState:UIGestureRecognizerStateChanged];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
            
            break;
        case UIGestureRecognizerStateEnded:
        {
            
            if (isVertical) {
                self.dynamicItem.center = self.view.bounds.origin;
                //velocity是在手势结束的时候获取的竖直方向的手势速度
                CGPoint velocity = [recognizer velocityInView:self.view];
                UIDynamicItemBehavior *inertialBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.dynamicItem]];
                [inertialBehavior addLinearVelocity:CGPointMake(0, velocity.y) forItem:self.dynamicItem];
                // 通过尝试取2.0比较像系统的效果
                inertialBehavior.resistance = 2.0;
                __block CGPoint lastCenter = CGPointZero;
                __weak typeof(self) weakSelf = self;
                inertialBehavior.action = ^{
                    if (isVertical) {
                        //得到每次移动的距离
                        CGFloat currentY = weakSelf.dynamicItem.center.y - lastCenter.y;
                        [weakSelf controlScrollForVertical:currentY AndState:UIGestureRecognizerStateEnded];
                    }
                    lastCenter = weakSelf.dynamicItem.center;
                };
                [self.animator addBehavior:inertialBehavior];
                self.decelerationBehavior = inertialBehavior;
            }
        }
            break;
        default:
            break;
    }
    //保证每次只是移动的距离，不是从头一直移动的距离
    [recognizer setTranslation:CGPointZero inView:self.view];
}

//控制上下滚动的方法
- (void)controlScrollForVertical:(CGFloat)detal AndState:(UIGestureRecognizerState)state {
    CGFloat maxOffsetY = CGRectGetHeight(self.topView.frame);
    //判断是主ScrollView滚动还是子ScrollView滚动,detal为手指移动的距离
    if (self.mainScrollView.contentOffset.y >= maxOffsetY) {
        CGFloat offsetY = self.childScrollView.contentOffset.y - detal;
        if (offsetY < 0) {
            //当子ScrollView的contentOffset小于0之后就不再移动子ScrollView，而要移动主ScrollView
            offsetY = 0;
            self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.frame.origin.x, self.mainScrollView.contentOffset.y - detal);
        } else if (offsetY > (self.childScrollView.contentSize.height - self.childScrollView.frame.size.height)) {
            //当子ScrollView的contentOffset大于contentSize.height时
            
            offsetY = self.childScrollView.contentOffset.y - rubberBandDistance(detal, height);
        }
        if (offsetY == 0) {
            for (UITableView *tableView in self.childVCArray) {
                tableView.contentOffset = CGPointMake(0, 0);
            }
        }
        self.childScrollView.contentOffset = CGPointMake(0, offsetY);
    } else {
        CGFloat mainOffsetY = self.mainScrollView.contentOffset.y - detal;
        if (mainOffsetY < 0) {
            
            mainOffsetY = self.mainScrollView.contentOffset.y - rubberBandDistance(detal, height);
            
        } else if (mainOffsetY > maxOffsetY) {
            mainOffsetY = maxOffsetY;
        }
        self.mainScrollView.contentOffset = CGPointMake(self.mainScrollView.frame.origin.x, mainOffsetY);
        
        if (mainOffsetY == 0) {
            for (UITableView *tableView in self.childVCArray) {
                tableView.contentOffset = CGPointMake(0, 0);
            }
        }
    }
    
    BOOL outsideFrame = self.mainScrollView.contentOffset.y < 0 || self.childScrollView.contentOffset.y > (self.childScrollView.contentSize.height - self.childScrollView.frame.size.height);
    if (outsideFrame &&
        (self.decelerationBehavior && !self.springBehavior)) {//滚动范围超出视图范围，需要弹性返回
        
        CGPoint target = CGPointZero;
        BOOL isMian = NO;
        if (self.mainScrollView.contentOffset.y < 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FRLinkScrollTopBouncesNote object:nil];
            self.dynamicItem.center = self.mainScrollView.contentOffset;
            target = CGPointZero;
            isMian = YES;
        } else if (self.childScrollView.contentOffset.y > (self.childScrollView.contentSize.height - self.childScrollView.frame.size.height)) {
            [[NSNotificationCenter defaultCenter] postNotificationName:FRLinkScrollBottomBouncesNote object:nil];
            self.dynamicItem.center = self.childScrollView.contentOffset;
            target = CGPointMake(self.childScrollView.contentOffset.x, (self.childScrollView.contentSize.height - self.childScrollView.frame.size.height));
            isMian = NO;
        }
        [self.animator removeBehavior:self.decelerationBehavior];
        __weak typeof(self) weakSelf = self;
        UIAttachmentBehavior *springBehavior = [[UIAttachmentBehavior alloc] initWithItem:self.dynamicItem attachedToAnchor:target];
        springBehavior.length = 0;
        springBehavior.damping = 1;
        springBehavior.frequency = 2;
        springBehavior.action = ^{
            if (isMian) {
                weakSelf.mainScrollView.contentOffset = weakSelf.dynamicItem.center;
                if (weakSelf.mainScrollView.contentOffset.y == 0) {
                    for (UITableView *tableView in self.childVCArray) {
                        tableView.contentOffset = CGPointMake(0, 0);
                    }
                }
            } else {
                weakSelf.childScrollView.contentOffset = self.dynamicItem.center;
            }
        };
        [self.animator addBehavior:springBehavior];
        self.springBehavior = springBehavior;
    }
}

- (void)setChildScrollView:(UITableView *)childScrollView {
    _childScrollView = childScrollView;
    [self.animator removeAllBehaviors];
}


@end

@implementation FRDynamicItem

- (instancetype)init {
    if (self = [super init]) {
        _bounds = CGRectMake(0, 0, 1, 1);
    }
    return self;
}

@end
