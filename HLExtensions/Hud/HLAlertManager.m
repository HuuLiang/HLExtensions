//
//  HLAlertManager.m
//  HLExtensions
//
//  Created by Liang on 2018/4/28.
//

#import "HLAlertManager.h"
#import <SCLAlertView_Objective_C/SCLAlertView.h>

@implementation HLAlertManager

HLSynthesizeSingletonMethod(sharedManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;
    alert.hideAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert showInfo:title subTitle:message closeButtonTitle:@"确定" duration:3];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message action:(HLAction)action {
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;
    alert.hideAnimationType = SCLAlertViewShowAnimationSimplyAppear;
    [alert alertIsDismissed:^{
        HLSafelyCallBlock(action, self);
    }];
    [alert showNotice:title subTitle:message closeButtonTitle:@"确定" duration:3];
}

- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              OKButton:(NSString *)OKButton
          cancelButton:(NSString *)cancelButton
              OKAction:(HLAction)OKAction
          cancelAction:(HLAction)cancelAction
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindow];
    alert.showAnimationType = SCLAlertViewShowAnimationFadeIn;
    alert.hideAnimationType = SCLAlertViewShowAnimationFadeIn;
    alert.horizontalButtons = YES;
    [alert addButton:cancelButton actionBlock:^{
        [alert hideView];
        HLSafelyCallBlock(cancelAction, self);
    }];
    [alert addButton:OKButton actionBlock:^{
        HLSafelyCallBlock(OKAction, self);
    }];
    [alert showNotice:title subTitle:message closeButtonTitle:nil duration:3];
}


@end
