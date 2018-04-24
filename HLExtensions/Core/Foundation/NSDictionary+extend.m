//
//  NSDictionary+extend.m
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import "NSDictionary+extend.h"

@implementation NSDictionary (extend)

- (NSString *)descriptionWithLocale:(id)locale {
    NSMutableString *string = [NSMutableString string];
    
    // 开头有个{
    [string appendString:@"{\n"];
    
    // 遍历所有的键值对
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [string appendFormat:@"\t%@%@%@", [key isKindOfClass:[NSString class]]?@"\"":@"", key, [key isKindOfClass:[NSString class]]?@"\"":@""];
        [string appendString:@" : "];
        
        [string appendFormat:@"%@%@%@,\n", [obj isKindOfClass:[NSString class]]?@"\"":@"", obj, [obj isKindOfClass:[NSString class]]?@"\"":@""];
    }];
    
    // 结尾有个}
    [string appendString:@"}"];
    
    // 查找最后一个逗号
    NSRange range = [string rangeOfString:@"," options:NSBackwardsSearch];
    if (range.location != NSNotFound)
        [string deleteCharactersInRange:range];
    
    return string;
}

@end
