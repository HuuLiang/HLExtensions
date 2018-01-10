//
//  NSArray+Random.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface NSArray (Random)

- (NSArray *)HL_arrayByPickingRandomCount:(NSUInteger)count;
- (NSArray *)HL_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match;
- (NSArray *)HL_arrayByPickingRandomCount:(NSUInteger)count
                                    match:(BOOL (^)(id obj))match
                              afterFilter:(NSArray * (^)(NSArray *array))filter;

@end
