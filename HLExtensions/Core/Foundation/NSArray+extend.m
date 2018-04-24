//
//  NSArray+extend.m
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import "NSArray+extend.h"

@implementation NSArray (extend)

#pragma mark - Description

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *string = [NSMutableString string];
    
    // 开头有个[
    [string appendString:@"[\n"];
    
    // 遍历所有的元素
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [string appendFormat:@"\t\"%@\",\n", obj];
        } else {
            [string appendFormat:@"\t%@,\n", obj];
        }
        
    }];
    
    // 结尾有个]
    [string appendString:@"]"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}

#pragma mark - Random

- (NSArray *)hl_arrayByPickingRandomCount:(NSUInteger)count {
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

- (NSArray *)hl_match:(BOOL (^)(id obj))match {
    NSMutableArray *matchedArray = [NSMutableArray array];
    [self enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (match && match(obj)) {
            [matchedArray addObject:obj];
        }
    }];
    
    return matchedArray.count > 0 ? matchedArray : nil;
}

- (NSArray *)hl_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match {
    NSArray *matchedArray = [self hl_match:match];
    return [matchedArray hl_arrayByPickingRandomCount:count];
}

- (NSArray *)hl_arrayByPickingRandomCount:(NSUInteger)count match:(BOOL (^)(id obj))match afterFilter:(NSArray * (^)(NSArray *array))filter {
    NSArray *filteredArray = filter(self);
    return [filteredArray hl_arrayByPickingRandomCount:count match:match];
}


#pragma mark - SafeIndex

- (id)hl_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    } else {
        return nil;
    }
}



@end
