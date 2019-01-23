//
//  UIScrollView+HLRefresh.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "UIScrollView+HLRefresh.h"
#import "MJRefresh.h"

@implementation UIScrollView (HLRefresh)

- (UIColor *)HL_refreshTextColor {
    return [UIColor colorWithWhite:0.5 alpha:1];
}

- (BOOL)HL_isRefreshing {
    if (self.mj_header || self.mj_footer) {
        return self.mj_header.isRefreshing || self.mj_footer.isRefreshing;
    }
    return NO;
}

- (void)HL_setRefreshViewHidden:(BOOL)hide {
    if (self.mj_header) {
        [self.mj_header setHidden:hide];
    }
    if (self.mj_footer) {
        self.mj_footer.hidden = hide;
    }
}

- (void)HL_addPullToRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_header) {
        MJRefreshNormalHeader *refreshHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:handler];
        refreshHeader.stateLabel.textColor = [self HL_refreshTextColor];
        self.mj_header = refreshHeader;
    }
}

- (void)HL_triggerPullToRefresh {
    if (self.mj_header) {
        [self.mj_header beginRefreshing];
    }
}

- (void)HL_endPullToRefresh {
    if (self.mj_header && self.mj_header.isRefreshing) {
        [self.mj_header endRefreshing];
    }
    if (self.mj_footer && self.mj_footer.isRefreshing) {
        [self.mj_footer endRefreshing];
    }
}

- (void)HL_addPagingRefreshWithHandler:(void (^)(void))handler {
    if (!self.mj_footer) {
        MJRefreshAutoNormalFooter *refreshFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:handler];
        refreshFooter.stateLabel.textColor = [self HL_refreshTextColor];
        self.mj_footer = refreshFooter;
    }
}

- (void)HL_pagingRefreshNoMoreData {
    [self.mj_footer endRefreshingWithNoMoreData];
}

@end
