//
//  UIButton+imageSpacing.h
//  HLExtensions
//
//  Created by Liang on 2018/4/24.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HLButtonEdgeInsetsStyle) {
    HLButtonEdgeInsetsStyleTop, // image在上，label在下
    HLButtonEdgeInsetsStyleLeft, // image在左，label在右
    HLButtonEdgeInsetsStyleBottom, // image在下，label在上
    HLButtonEdgeInsetsStyleRight // image在右，label在左
};


@interface UIButton (imageSpacing)

/**
 *  设置button的titleLabel和imageView的布局样式，及间距
 *
 *  @param style titleLabel和imageView的布局样式
 *  @param space titleLabel和imageView的间距
 */
- (void)layoutButtonWithEdgeInsetsStyle:(HLButtonEdgeInsetsStyle)style
                        imageTitleSpace:(CGFloat)space;


@end
