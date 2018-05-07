//
//  UIViewController+showOrHide.m
//  Coupling
//
//  Created by Liang on 2018/5/4.
//  Copyright © 2018年 Liang. All rights reserved.
//

#import "UIViewController+showOrHide.h"
#import "HLDefines.h"
#import <BlocksKit/BlocksKit.h>

@implementation UIViewController (showOrHide)

- (void)showInViewController:(UIViewController *)viewController {
    BOOL anyView = [viewController.childViewControllers bk_any:^BOOL(id obj) {
        if ([obj isKindOfClass:[self class]]) {
            return YES;
        }
        return NO;
    }];
    
    if (anyView) {
        return ;
    }
    
    if ([viewController.view.subviews containsObject:self.view]) {
        return ;
    }
    
    [viewController addChildViewController:self];
    //    self.view.frame = viewController.view.bounds;
    CGRect superVCBounds = viewController.view.bounds;
    self.view.frame = CGRectMake(superVCBounds.origin.x, superVCBounds.origin.y, superVCBounds.size.width, superVCBounds.size.height+49);
    self.view.alpha = 0;
    self.view.backgroundColor = [kColor(@"#000000") colorWithAlphaComponent:1];
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
    
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 1;
    }];
}

- (void)hide {
    if (!self.view.superview) {
        return ;
    }
    [UIView animateWithDuration:0.25 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

@end
