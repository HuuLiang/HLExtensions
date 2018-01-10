//
//  NSMutableDictionary+SafeCoding.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSMutableDictionary+SafeCoding.h"

@implementation NSMutableDictionary (SafeCoding)

- (void)safelySetObject:(id)object forKey:(id <NSCopying>)key {
    if (object) {
        [self setObject:object forKey:key];
    }
}

- (void)safelySetUInt:(NSUInteger)uint forKey:(id <NSCopying>)key {
    if (uint != NSNotFound) {
        [self setObject:@(uint) forKey:key];
    }
}

@end
