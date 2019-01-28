//
//  HLImagePicker.h
//  AFNetworking
//
//  Created by Liang on 2019/1/24.
//

#import <Foundation/Foundation.h>

typedef void(^ImagePicker)(UIImage *pickerImage,NSString *keyName);

@interface HLImagePicker : NSObject

+ (instancetype)picker;

- (void)getImageInCurrentViewController:(UIViewController *)viewController handler:(ImagePicker)picker;

- (void)getImageInCurrentViewController:(UIViewController *)viewController withType:(UIImagePickerControllerSourceType)sourceType handler:(ImagePicker)picker;


@end

