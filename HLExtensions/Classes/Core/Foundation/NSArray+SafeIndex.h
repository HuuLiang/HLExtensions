//
//  NSArray+SafeIndex.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface NSArray<__covariant ObjectType> (SafeIndex)

- (ObjectType)s_objectAtIndex:(NSUInteger)index;

@end
