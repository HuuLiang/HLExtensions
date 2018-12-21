//
//  UIViewController+flicker.h
//  HLExtensions
//
//  Created by Liang on 2018/11/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^xxx)(void);

@interface UIViewController (flicker)

- (void)showInViewController:(UIViewController *)viewController;
- (void)showInViewController:(UIViewController *)viewController inRect:(CGRect)rect backgroundColor:(UIColor *)backgroundColor;
- (void)showInViewController:(UIViewController *)viewController inRect:(CGRect)rect backgroundColor:(UIColor *)backgroundColor animationBlock:(void (^ __nullable)(void))showAnimationBlock;

- (void)hide;
- (void)hideWithAnimationBlock:(void (^)(void))hideAnimationBlock;

@end

NS_ASSUME_NONNULL_END
