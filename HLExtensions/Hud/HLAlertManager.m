//
//  HLAlertManager.m
//  HLExtensions
//
//  Created by Liang on 2018/4/28.
//

#import "HLAlertManager.h"
#import <SIAlertView/SIAlertView.h>

@implementation HLAlertManager

HLSynthesizeSingletonMethod(sharedManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        [[SIAlertView appearance] setBackgroundStyle:SIAlertViewBackgroundStyleGradient];
        [[SIAlertView appearance] setTransitionStyle:SIAlertViewTransitionStyleFade];
    }
    return self;
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message {
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alert addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDestructive handler:nil];
    [alert show];
}

- (void)alertWithTitle:(NSString *)title message:(NSString *)message action:(HLAction)action {
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alert addButtonWithTitle:@"确定" type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        HLSafelyCallBlock(action, self);
    }];
    [alert show];
}

- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              OKButton:(NSString *)OKButton
          cancelButton:(NSString *)cancelButton
              OKAction:(HLAction)OKAction
          cancelAction:(HLAction)cancelAction
{
    SIAlertView *alert = [[SIAlertView alloc] initWithTitle:title andMessage:message];
    [alert addButtonWithTitle:cancelButton type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) {
        HLSafelyCallBlock(cancelAction, self);
    }];
    [alert addButtonWithTitle:OKButton type:SIAlertViewButtonTypeDestructive handler:^(SIAlertView *alertView) {
        HLSafelyCallBlock(OKAction, self);
    }];
    [alert show];
    
}


@end
