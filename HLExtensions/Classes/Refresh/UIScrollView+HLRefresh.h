//
//  UIScrollView+HLRefresh.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (HLRefresh)

@property (nonatomic) BOOL HL_showLastUpdatedTime;
@property (nonatomic) BOOL HL_showStateLabel;
@property (nonatomic,weak,readonly) UIView *HL_refreshView;
@property (nonatomic,readonly) BOOL HL_isRefreshing;

- (void)HL_addPullToRefreshWithHandler:(void (^)(void))handler;
- (void)HL_triggerPullToRefresh;
- (void)HL_endPullToRefresh;

- (void)HL_addPagingRefreshWithHandler:(void (^)(void))handler;
- (void)HL_addPagingRefreshAutomaticallyHidden:(BOOL)automaticallyHidden WithHandler:(void (^)(void))handler;
- (void)HL_pagingRefreshNoMoreData;
- (void)HL_setPagingRefreshText:(NSString *)text;
- (void)HL_setPagingNoMoreDataText:(NSString *)text;


@end
