//
//  NSString+lenght.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSString+lenght.h"

@implementation NSString (lenght)

- (BOOL)isEmpty {
    if (self == nil || self == NULL)
        return YES;
    if ([self isKindOfClass:[NSNull class]])
        return YES;
    if ([[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0)
        return YES;
    if ([self isEqualToString:@"(null)"])
        return YES;
    if ([self isEqualToString:@"(null)(null)"])
        return YES;
    if ([self isEqualToString:@"<null>"])
        return YES;
    
    // return Default
    return NO;
}

@end
