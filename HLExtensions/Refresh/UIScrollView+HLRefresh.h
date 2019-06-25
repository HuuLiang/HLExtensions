//
//  UIScrollView+HLRefresh.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (HLRefresh)

@property (nonatomic,readonly) BOOL HL_isRefreshing;
- (void)HL_setRefreshViewHidden:(BOOL)hide;

//header refresh
- (void)HL_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)HL_triggerPullToRefresh;
- (void)HL_endPullToRefresh;


//footer
- (void)HL_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)HL_pagingRefreshNoMoreData;

- (void)HL_pagingRefreshNormal;

@end
