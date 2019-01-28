//
//  HLImagePicker.m
//  AFNetworking
//
//  Created by Liang on 2019/1/24.
//

#import "HLImagePicker.h"

#import "HLAlertManager.h"

#import <CommonCrypto/CommonDigest.h>
#import <CoreServices/CoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^DidFinishTakeMediaCompletedBlock)(UIImage *image, NSDictionary *editingInfo);

@interface HLImagePicker () <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate>
@property (nonatomic, copy) DidFinishTakeMediaCompletedBlock didFinishTakeMediaCompleted;
@property (nonatomic, strong) UIViewController *viewController;
@end

@implementation HLImagePicker

- (void)dealloc {
    NSLog(@"🌳💓🌳💓🌳💓🌳💓🌳💓🌳💓🌳💓🌳💓🌳💓🌳💓");
}

+ (instancetype)picker {
    static HLImagePicker *_picker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _picker = [[HLImagePicker alloc] init];
    });
    return _picker;
}

- (void)getImageInCurrentViewController:(UIViewController *)viewController handler:(ImagePicker)picker {
    [self getImageInCurrentViewController:viewController withType:NSNotFound handler:picker];
}

- (void)getImageInCurrentViewController:(UIViewController *)viewController withType:(UIImagePickerControllerSourceType)sourceType handler:(ImagePicker)picker {
    @weakify(self);
    self.didFinishTakeMediaCompleted = ^(UIImage *image, NSDictionary *editingInfo) {
        @strongify(self);
        UIImage *originalImage = editingInfo[UIImagePickerControllerOriginalImage];
        if (originalImage) {
            picker(originalImage,[self getMd5ImageKeyNameWithImage:originalImage]);
        } else {
            NSLog(@"图片获取失败");
        }
    };
    self.viewController = viewController;
    
    
    if (sourceType == NSNotFound) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"请选择图片获取方式" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"选择相册",@"选择相机", nil];
        [actionSheet showInView:viewController.view];
    } else {
        [self showOnPickerViewControllerSourceType:sourceType onViewController:viewController completed:self.didFinishTakeMediaCompleted];
    }
}


- (void)showOnPickerViewControllerSourceType:(UIImagePickerControllerSourceType)sourceType onViewController:(UIViewController *)viewController completed:(DidFinishTakeMediaCompletedBlock)completed {
    if (![self checkAuthorization:sourceType]) {
        [[HLAlertManager sharedManager] alertWithTitle:@"访问受限" message:@"您没有授权我们访问相关设备，是否前往设置授权访问,或者稍后您也可以在设备的\"设置-隐私\"中更改授权" OKButton:@"设置" cancelButton:@"取消" OKAction:^(id obj) {
            if (@available(iOS 10.0, *)) {
                //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"App-Prefs:"] options:@{} completionHandler:nil];
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            } else {
                //                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=NOTIFICATIONS_ID&path=com.yxc8710.SettingSkip"]];//prefs:root=服务&path=路径
                //            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=com.yxc8710.SettingSkip"]];//prefs:root=bundleID
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }
        } cancelAction:^(id obj) {
            
        }];
        completed(nil,nil);
        return;
    }
    
//    self.didFinishTakeMediaCompleted = [completed copy];
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.editing = YES;
    imagePickerController.delegate = self;
    imagePickerController.sourceType = sourceType;
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        imagePickerController.mediaTypes =  @[(NSString *)kUTTypeImage];
    }
    [viewController presentViewController:imagePickerController animated:YES completion:NULL];
}

- (void)dismissPickerViewController:(UIImagePickerController *)picker {
    __weak typeof(self) WeakSelf = self;
    [picker dismissViewControllerAnimated:YES completion:^{
        __strong typeof(WeakSelf) StrongSelf = WeakSelf;
        StrongSelf.didFinishTakeMediaCompleted = nil;
        StrongSelf.viewController = nil;
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera || picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        if (self.didFinishTakeMediaCompleted) {
            self.didFinishTakeMediaCompleted(nil, info);
        }
        [self dismissPickerViewController:picker];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissPickerViewController:picker];
}

// MARK:UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        [self showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypePhotoLibrary onViewController:self.viewController completed:self.didFinishTakeMediaCompleted];
    } else if (buttonIndex == 1) {
        [self showOnPickerViewControllerSourceType:UIImagePickerControllerSourceTypeCamera onViewController:self.viewController completed:self.didFinishTakeMediaCompleted];
    }
}

// MARK:Private Methods

- (NSString *)getMd5ImageKeyNameWithImage:(UIImage *)image {
    
    NSData *sourceData = UIImageJPEGRepresentation(image, 1.0);
    
    if (!sourceData) {
        return nil;//判断sourceString如果为空则直接返回nil。
    }
    //需要MD5变量并且初始化
    CC_MD5_CTX  md5;
    CC_MD5_Init(&md5);
    //开始加密(第一个参数：对md5变量去地址，要为该变量指向的内存空间计算好数据，第二个参数：需要计算的源数据，第三个参数：源数据的长度)
    CC_MD5_Update(&md5, sourceData.bytes, (CC_LONG)sourceData.length);
    //声明一个无符号的字符数组，用来盛放转换好的数据
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    //将数据放入result数组
    CC_MD5_Final(result, &md5);
    //将result中的字符拼接为OC语言中的字符串，以便我们使用。
    NSMutableString *resultString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [resultString appendFormat:@"%02X",result[i]];
    }
    //    NSLog(@"resultString=========%@",resultString);
    return  resultString;
}

- (BOOL)checkAuthorization:(UIImagePickerControllerSourceType)sourceType {
    if (sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0) {
            ALAuthorizationStatus author =[ALAssetsLibrary authorizationStatus];
            if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied) {
                return NO;
            }
        }
        else {
            PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
            if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                return NO;
            }
        }
        return YES;
    } else if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        AVAuthorizationStatus authStatus =  [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied) {
            return NO;
        }
        return YES;
    }
    return NO;
}

@end
