//
//  UIView+RoundCorner.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "UIView+RoundCorner.h"
#import <objc/runtime.h>
#import "Aspects.h"

static const void *kForceRoundCornerAssociatedKey = &kForceRoundCornerAssociatedKey;
static const void *kAspectHookLayoutSubviewsAssociatedKey = &kAspectHookLayoutSubviewsAssociatedKey;

static const void *kRectCornerAssociatedKey = &kRectCornerAssociatedKey;

@implementation UIView (RoundCorner)

- (void)setForceRoundCorner:(BOOL)forceRoundCorner {
    objc_setAssociatedObject(self, kForceRoundCornerAssociatedKey, @(forceRoundCorner), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    id<AspectToken> aspectToken = objc_getAssociatedObject(self, kAspectHookLayoutSubviewsAssociatedKey);
    if (forceRoundCorner && !aspectToken) {
        aspectToken = [self aspect_hookSelector:@selector(layoutSubviews)
                                    withOptions:AspectPositionAfter
                                     usingBlock:^(id<AspectInfo> aspectInfo)
                       {
                           UIView *thisView = [aspectInfo instance];
                           thisView.layer.cornerRadius = CGRectGetHeight(thisView.bounds)/2;
                           thisView.layer.masksToBounds = YES;
                       } error:nil];
        objc_setAssociatedObject(self, kAspectHookLayoutSubviewsAssociatedKey, aspectToken, OBJC_ASSOCIATION_RETAIN);
    } else if (!forceRoundCorner) {
        [aspectToken remove];
        objc_setAssociatedObject(self, kAspectHookLayoutSubviewsAssociatedKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    
    [self setNeedsLayout];
}

- (BOOL)forceRoundCorner {
    NSNumber *value = objc_getAssociatedObject(self, kForceRoundCornerAssociatedKey);
    return value.boolValue;
}


- (void)setRectCorner:(UIRectCorner)rectCorner {
    objc_setAssociatedObject(self, kForceRoundCornerAssociatedKey, @(rectCorner), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    id<AspectToken> aspectToken = objc_getAssociatedObject(self, kAspectHookLayoutSubviewsAssociatedKey);
    if (rectCorner && !aspectToken) {
        aspectToken = [self aspect_hookSelector:@selector(layoutSubviews)
                                    withOptions:AspectPositionAfter
                                     usingBlock:^(id<AspectInfo> aspectInfo)
                       {
                           UIView *thisView = [aspectInfo instance];
                           UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:thisView.bounds byRoundingCorners:rectCorner cornerRadii:CGSizeMake(thisView.layer.cornerRadius, thisView.layer.cornerRadius)];
                           CAShapeLayer *layer = [[CAShapeLayer alloc] init];
                           layer.frame = maskPath.bounds;
                           layer.path = maskPath.CGPath;
                           thisView.layer.mask = layer;
                       } error:nil];
        objc_setAssociatedObject(self, kAspectHookLayoutSubviewsAssociatedKey, aspectToken, OBJC_ASSOCIATION_RETAIN);
    } else if (!rectCorner) {
        [aspectToken remove];
        objc_setAssociatedObject(self, kAspectHookLayoutSubviewsAssociatedKey, nil, OBJC_ASSOCIATION_ASSIGN);
    }
    
    [self setNeedsLayout];
}

- (UIRectCorner)rectCorner {
    NSNumber *value = objc_getAssociatedObject(self, kRectCornerAssociatedKey);
    return value.unsignedIntegerValue;
}

@end
