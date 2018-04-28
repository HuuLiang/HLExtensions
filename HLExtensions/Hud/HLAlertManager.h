//
//  HLAlertManager.h
//  HLExtensions
//
//  Created by Liang on 2018/4/28.
//

#import <Foundation/Foundation.h>
#import "HLDefines.h"

@interface HLAlertManager : NSObject

HLDeclareSingletonMethod(sharedManager)

- (void)alertWithTitle:(NSString *)title message:(NSString *)message;
- (void)alertWithTitle:(NSString *)title message:(NSString *)message action:(HLAction)action;
- (void)alertWithTitle:(NSString *)title
               message:(NSString *)message
              OKButton:(NSString *)OKButton
          cancelButton:(NSString *)cancelButton
              OKAction:(HLAction)OKAction
          cancelAction:(HLAction)cancelAction;


@end
