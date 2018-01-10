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

@end
