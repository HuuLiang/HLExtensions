//
//  NSArray+SafeIndex.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSArray+SafeIndex.h"

@implementation NSArray (SafeIndex)

- (id)s_objectAtIndex:(NSUInteger)index {
    if (index < self.count) {
        return [self objectAtIndex:index];
    } else {
        return nil;
    }
}

@end
