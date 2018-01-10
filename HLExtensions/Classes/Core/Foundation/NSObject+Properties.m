//
//  NSObject+Properties.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSObject+Properties.h"
#import <objc/runtime.h>

@implementation NSObject (Properties)

+ (NSArray *)propertiesOfClass:(Class)cls {
    NSMutableArray *propertyArr = [[NSMutableArray alloc] init];
    while (cls != [NSObject class]) {
        uint propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(cls, &propertyCount);
        for (uint i = 0; i < propertyCount; ++i) {
            objc_property_t property = properties[i];
            const char* propertyName = property_getName(property);
            if (propertyName) {
                NSString *propName = [NSString stringWithUTF8String:propertyName];
                [propertyArr addObject:propName];
            }
        }
        free(properties);
        cls = [cls superclass];
    }
    return propertyArr;
}

- (NSArray *)allProperties {
    return [NSObject propertiesOfClass:[self class]];
}

@end
