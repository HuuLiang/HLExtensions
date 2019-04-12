//
//  HLHudManager.h
//  HLExtensions
//
//  Created by Liang on 2018/4/24.
//

#import <UIKit/UIKit.h>
#import "HLDefines.h"

@interface HLHudManager : NSObject

HLDeclareSingletonMethod(sharedManager)

- (void)showLoading;
- (void)showLoadingInfo:(NSString *)info;
- (void)showLoadingInfo:(NSString *)info withDuration:(NSTimeInterval)duration complete:(void (^)(void))complete;
- (void)showLoadingInfo:(NSString *)info
           withDuration:(NSTimeInterval)duration
            isSucceeded:(BOOL)isSucceeded
               complete:(NSString *(^)(void))complete;

- (void)showProgress:(CGFloat)progress;

- (void)showError:(NSString *)error;
- (void)showSuccess:(NSString *)success;
- (void)showInfo:(NSString *)info;

- (void)hide;
- (void)hide:(void(^)(void))completion;


@end
