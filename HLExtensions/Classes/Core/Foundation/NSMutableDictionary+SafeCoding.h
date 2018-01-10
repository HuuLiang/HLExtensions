//
//  NSMutableDictionary+SafeCoding.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (SafeCoding)

- (void)safelySetObject:(id)object forKey:(id <NSCopying>)key;
- (void)safelySetUInt:(NSUInteger)uint forKey:(id <NSCopying>)key;

@end
