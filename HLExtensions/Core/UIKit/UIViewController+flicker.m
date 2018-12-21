//
//  UIViewController+flicker.m
//  HLExtensions
//
//  Created by Liang on 2018/11/19.
//

#import "UIViewController+flicker.h"
#import "HLDefines.h"
#import <BlocksKit/NSArray+BlocksKit.h>

@implementation UIViewController (flicker)

- (void)showInViewController:(UIViewController *)viewController {
    [self showInViewController:viewController inRect:viewController.view.bounds backgroundColor:[kColor(@"#000000") colorWithAlphaComponent:1]];
}

- (void)showInViewController:(UIViewController *)viewController inRect:(CGRect)rect backgroundColor:(UIColor *)backgroundColor {
    [self showInViewController:viewController inRect:rect backgroundColor:backgroundColor animationBlock:nil];
}

- (void)showInViewController:(UIViewController *)viewController inRect:(CGRect)rect backgroundColor:(UIColor *)backgroundColor animationBlock:(void (^)(void))showAnimationBlock {
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
    self.view.frame = rect;
    if (!showAnimationBlock) {
        self.view.alpha = 0.01;
    }

    self.view.backgroundColor = backgroundColor;
    [viewController.view addSubview:self.view];
    [self didMoveToParentViewController:viewController];
    
    if (!showAnimationBlock) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 1;
        }];
    } else {
        HLSafelyCallBlock(showAnimationBlock);
    }
}

- (void)hide {
    [self hideWithAnimationBlock:nil];
}

- (void)hideWithAnimationBlock:(void (^)(void))hideAnimationBlock {
    if (!self.view.superview) {
        return ;
    }
    
    if (!hideAnimationBlock) {
        [UIView animateWithDuration:0.25 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self willMoveToParentViewController:nil];
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }];
    } else {
        HLSafelyCallBlock(hideAnimationBlock);
    }
}


@end
