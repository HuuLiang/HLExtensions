//
//  NSArray+Random.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSArray+Random.h"

@implementation NSArray (Random)

- (NSArray *)HL_arrayByPickingRandomCount:(NSUInteger)count {
    if (count > self.count) {
        count = self.count;
    }
    
    NSMutableArray *results = [NSMutableArray arrayWithCapacity:count];
    
    NSMutableArray *arr = self.mutableCopy;
    for (NSUInteger i = 0; i < count; ++i) {
        NSUInteger index = arc4random_uniform((uint32_t)arr.count);
        [results addObject:arr[index]];
        [arr removeObjectAtIndex:index];
    }
    return results;
}

- (NSArray *)HL_match:(BOOL (^)(id obj))match {
    NSMutableArray *matchedArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (match && match(obj)) {
            [matchedArray addObject:obj];
        }
    }];
    
    return matchedArray.count > 0 ? matchedArray : nil;
}

- (NSArray *)HL_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match {
    NSArray *matchedArray = [self HL_match:match];
    return [matchedArray HL_arrayByPickingRandomCount:count];
}

- (NSArray *)HL_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match afterFilter:(NSArray * (^)(NSArray *array))filter
{
    NSArray *filteredArray = filter(self);
    return [filteredArray HL_arrayByPickingRandomCount:count match:match];
}

@end
