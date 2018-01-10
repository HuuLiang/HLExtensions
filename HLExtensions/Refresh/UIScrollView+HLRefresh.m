//
//  UIScrollView+HLRefresh.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "UIScrollView+HLRefresh.h"

#import "MJRefresh.h"

static const void *kHLRefreshViewAssociatedKey = &kHLRefreshViewAssociatedKey;
static const void *kHLShowLastUpdatedTimeAssociatedKey = &kHLShowLastUpdatedTimeAssociatedKey;
static const void *kHLShowStateAssociatedKey = &kHLShowStateAssociatedKey;

@implementation UIScrollView (HLRefresh)

- (UIColor *)HL_refreshTextColor {
    return [UIColor colorWithWhite:0.5 alpha:1];
}

- (BOOL)HL_isRefreshing {
    if ([self.HL_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.HL_refreshView;
        return refresh.state == MJRefreshStateRefreshing;
    }
    return NO;
}

- (UIView *)HL_refreshView {
    return objc_getAssociatedObject(self, kHLRefreshViewAssociatedKey);
}

- (void)setHL_showLastUpdatedTime:(BOOL)HL_showLastUpdatedTime {
    objc_setAssociatedObject(self, kHLShowLastUpdatedTimeAssociatedKey, @(HL_showLastUpdatedTime), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ([self.mj_header isKindOfClass:[MJRefreshStateHeader class]]) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.mj_header;
        header.lastUpdatedTimeLabel.hidden = !HL_showLastUpdatedTime;
    }
}

- (BOOL)HL_showLastUpdatedTime {
    NSNumber *value = objc_getAssociatedObject(self, kHLShowLastUpdatedTimeAssociatedKey);
    return value.boolValue;
}

- (void)setHL_showStateLabel:(BOOL)HL_showStateLabel {
    objc_setAssociatedObject(self, kHLShowStateAssociatedKey, @(HL_showStateLabel), OBJC_ASSOCIATION_COPY_NONATOMIC);
    
    if ([self.mj_header isKindOfClass:[MJRefreshStateHeader class]]) {
        MJRefreshStateHeader *header = (MJRefreshStateHeader *)self.mj_header;
        header.stateLabel.hidden = !HL_showStateLabel;
    }
}

- (BOOL)HL_showStateLabel {
    NSNumber *value = objc_getAssociatedObject(self, kHLShowStateAssociatedKey);
    return value.boolValue;
}

- (void)HL_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_header) {
        MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
        //            refreshHeader.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        refreshHeader.lastUpdatedTimeLabel.textColor = [self HL_refreshTextColor];
        refreshHeader.stateLabel.textColor = [self HL_refreshTextColor];
        refreshHeader.lastUpdatedTimeLabel.hidden = !self.HL_showLastUpdatedTime;
        self.mj_header = refreshHeader;
        
        objc_setAssociatedObject(self, kHLRefreshViewAssociatedKey, refreshHeader, OBJC_ASSOCIATION_ASSIGN);
    }
}

- (void)HL_triggerPullToRefresh {
    
    if ([self.HL_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.HL_refreshView;
        [refresh beginRefreshing];
    }
}

- (void)HL_endPullToRefresh {
    if ([self.HL_refreshView isKindOfClass:[MJRefreshComponent class]]) {
        MJRefreshComponent *refresh = (MJRefreshComponent *)self.HL_refreshView;
        [refresh endRefreshing];
    }
    
    [self.mj_footer resetNoMoreData];
}

- (void)HL_addPagingRefreshWithHandler:(void (^)(void))handler {
    [self HL_addPagingRefreshAutomaticallyHidden:NO WithHandler:handler];
}

- (void)HL_addPagingRefreshAutomaticallyHidden:(BOOL)automaticallyHidden WithHandler:(void (^)(void))handler {
    if (!self.mj_footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        refreshFooter.automaticallyHidden = automaticallyHidden;
        refreshFooter.stateLabel.textColor = [self HL_refreshTextColor];
        self.mj_footer = refreshFooter;
    }
}

- (void)HL_pagingRefreshNoMoreData {
    [self.mj_footer endRefreshingWithNoMoreData];
}

- (void)HL_setPagingRefreshText:(NSString *)text {
    if ([self.mj_footer isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.mj_footer;
        [footer setTitle:text forState:MJRefreshStateIdle];
    }
}

- (void)HL_setPagingNoMoreDataText:(NSString *)text {
    if ([self.mj_footer isKindOfClass:[MJRefreshAutoNormalFooter class]]) {
        MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.mj_footer;
        [footer setTitle:text forState:MJRefreshStateNoMoreData];
    }
}

@end
