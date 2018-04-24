//
//  NSArray+extend.h
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (extend)

/** Ramdom */
- (NSArray *)hl_arrayByPickingRandomCount:(NSUInteger)count;
- (NSArray *)hl_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match;
- (NSArray *)hl_arrayByPickingRandomCount:(NSUInteger)count
                                    match:(BOOL (^)(id obj))match
                              afterFilter:(NSArray * (^)(NSArray *array))filter;

/** SafeIndex */
- (ObjectType)hl_objectAtIndex:(NSUInteger)index;

@end
