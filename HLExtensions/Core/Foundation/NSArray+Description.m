//
//  NSArray+Description.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSArray+Description.h"

@implementation NSArray (Description)

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

@end
