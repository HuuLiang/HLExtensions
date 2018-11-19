//
//  UIViewController+flicker.h
//  HLExtensions
//
//  Created by Liang on 2018/11/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (flicker)

- (void)showInViewController:(UIViewController *)viewController;

- (void)hide;

@end

NS_ASSUME_NONNULL_END
