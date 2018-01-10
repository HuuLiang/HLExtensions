//
//  UIView+GeometryMetrics.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "UIView+GeometryMetrics.h"

@implementation UIView (GeometryMetrics)

- (CGFloat)GM_width {
    return self.bounds.size.width;
}

- (CGFloat)GM_height {
    return self.bounds.size.height;
}

- (CGSize)GM_size {
    return self.bounds.size;
}

- (CGFloat)GM_left {
    return self.frame.origin.x;
}

- (CGFloat)GM_top {
    return self.frame.origin.y;
}

- (CGFloat)GM_right {
    return CGRectGetMaxX(self.frame);
}

- (CGFloat)GM_bottom {
    return CGRectGetMaxY(self.frame);
}

- (CGFloat)GM_centerX {
    return self.GM_left + self.GM_width/2;
}

- (CGFloat)GM_centerY {
    return self.GM_top + self.GM_height/2;
}

- (CGPoint)GM_boundsCenter {
    return CGPointMake(self.bounds.origin.x + self.GM_width/2, self.bounds.origin.y + self.GM_height/2);
}

@end
