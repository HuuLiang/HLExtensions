//
//  NSMutableDictionary+extend.h
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (extend)

/** safeCoding */
- (void)safelySetObject:(id)object forKey:(id <NSCopying>)key;
- (void)safelySetUInt:(NSUInteger)uint forKey:(id <NSCopying>)key;


@end
