//
//  NSMutableDictionary+extend.m
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import "NSMutableDictionary+extend.h"

@implementation NSMutableDictionary (extend)

#pragma mark - safecoding
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
