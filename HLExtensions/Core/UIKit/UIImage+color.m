//
//  UIImage+color.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "UIImage+color.h"

@implementation UIImage (color)

+ (UIImage *)imageWithColor:(UIColor *)aColor {
    CGRect imageRect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(imageRect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [aColor CGColor]);
    CGContextFillRect(context, imageRect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
