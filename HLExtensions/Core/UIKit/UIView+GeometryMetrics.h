//
//  UIView+GeometryMetrics.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <UIKit/UIKit.h>

@interface UIView (GeometryMetrics)

@property (nonatomic,readonly) CGFloat GM_width;
@property (nonatomic,readonly) CGFloat GM_height;
@property (nonatomic,readonly) CGSize GM_size;

@property (nonatomic,readonly) CGFloat GM_left;  //minX
@property (nonatomic,readonly) CGFloat GM_right; //maxX
@property (nonatomic,readonly) CGFloat GM_top;   //minY
@property (nonatomic,readonly) CGFloat GM_bottom; //maxY

@property (nonatomic,readonly) CGFloat GM_centerX;
@property (nonatomic,readonly) CGFloat GM_centerY;
@property (nonatomic,readonly) CGPoint GM_boundsCenter;

@end
