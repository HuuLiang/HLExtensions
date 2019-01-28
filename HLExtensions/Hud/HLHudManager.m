//
//  HLHudManager.m
//  HLExtensions
//
//  Created by Liang on 2018/4/24.
//

#import "HLHudManager.h"
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "BlocksKit.h"

static const SVProgressHUDMaskType kDefaultMaskType = SVProgressHUDMaskTypeBlack;

@interface HLHudManager ()
@property (nonatomic,retain) MBProgressHUD *progressHUD; //used in iOS7
@end

@implementation HLHudManager

HLSynthesizeSingletonMethod(sharedManager)

- (instancetype)init {
    self = [super init];
    if (self) {
        if (@available(iOS 8.0, *)) {
            [SVProgressHUD setDefaultMaskType:kDefaultMaskType];
            [SVProgressHUD setMinimumSize:CGSizeMake(kScreenWidth/4, kScreenWidth/4)];
            [SVProgressHUD setMinimumDismissTimeInterval:2];
        }
    }
    return self;
}

- (MBProgressHUD *)progressHUD {
    if (_progressHUD) {
        return _progressHUD;
    }
    
    UIWindow *keyWindow = [UIApplication sharedApplication].delegate.window;
    if (!keyWindow) {
        return nil;
    }
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:keyWindow];
    _progressHUD.userInteractionEnabled = NO;
    //    _progressHUD.mode = MBProgressHUDModeText;
    _progressHUD.minShowTime = 2;
    _progressHUD.detailsLabel.font = [UIFont systemFontOfSize:16.];
    _progressHUD.label.font = [UIFont systemFontOfSize:20.];
    [keyWindow addSubview:_progressHUD];
    return _progressHUD;
}

- (void)showLoading {
    if (@available(iOS 8.0, *)) {
        [SVProgressHUD show];
    } else {
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        [self.progressHUD showAnimated:YES];
    }
}

- (void)showLoadingInfo:(NSString *)info {
    if (@available(iOS 8.0, *)) {
        [SVProgressHUD showWithStatus:info];
    } else {
        self.progressHUD.mode = MBProgressHUDModeIndeterminate;
        
        if (info.length > 0) {
            if (info.length < 10) {
                self.progressHUD.label.text = info;
                self.progressHUD.detailsLabel.text = nil;
            } else {
                self.progressHUD.label.text = nil;
                self.progressHUD.detailsLabel.text = info;
            }
        }
        
        [self.progressHUD showAnimated:YES];
    }
}

- (void)showLoadingInfo:(NSString *)info withDuration:(NSTimeInterval)duration complete:(void (^)(void))complete {
    [self showLoadingInfo:info];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, duration * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self hide];
        if (complete) {
            complete();
        }
    });
}

- (void)showLoadingInfo:(NSString *)info withDuration:(NSTimeInterval)duration isSucceeded:(BOOL)isSucceeded complete:(NSString *(^)(void))complete {
    @weakify(self);
    [self showLoadingInfo:info];
    [self bk_performBlock:^(id obj) {
        @strongify(self);
        NSString *text = complete ? complete() : nil;
        if (isSucceeded) {
            [self showSuccess:text];
        } else {
            [self showError:text];
        }
    } afterDelay:duration];
}

- (void)showProgress:(CGFloat)progress {
    if (@available(iOS 8.0, *)) {
        [SVProgressHUD showProgress:progress];
    } else {
        self.progressHUD.mode = MBProgressHUDModeDeterminate;
        self.progressHUD.progress = progress;
        [self.progressHUD showAnimated:YES];
    }
}

- (void)showError:(NSString *)error {
    if (@available(iOS 8.0, *)) {
        [SVProgressHUD showErrorWithStatus:error];
    } else {
        [self showInfo:error];
    }
}

- (void)showSuccess:(NSString *)success {
    if (@available(iOS 8.0, *)) {
        [SVProgressHUD showSuccessWithStatus:success];
    } else {
        [self showInfo:success];
    }
}

- (void)showInfo:(NSString *)info {
    if (@available(iOS 8.0, *)) {
        [SVProgressHUD showInfoWithStatus:info];
    } else {
        if (info.length > 0) {
            self.progressHUD.mode = MBProgressHUDModeText;
            
            if (info.length < 10) {
                self.progressHUD.label.text = info;
                self.progressHUD.detailsLabel.text = nil;
            } else {
                self.progressHUD.label.text = nil;
                self.progressHUD.detailsLabel.text = info;
            }
            [self.progressHUD showAnimated:YES];
            [self.progressHUD hideAnimated:YES];
        }
    }
}

- (void)hide {
    if (@available(iOS 8.0, *)) {
        [SVProgressHUD dismiss];
    } else {
        [self.progressHUD hideAnimated:YES];
    }
}


@end
