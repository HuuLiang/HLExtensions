//
//  NSObject+extend.m
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import "NSObject+extend.h"

#import <objc/runtime.h>

static NSString *const kElementClassSuffix = @"ElementClass";


@implementation NSObject (extend)

#pragma mark - Properties
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

#pragma mark - BaseRepresentation
+ (NSArray *)excludedCommonProperties {
    return @[@"debugDescription", @"description", @"hash", @"superclass"];
}

- (NSDictionary *)dictionaryRepresentation {
    NSArray *properties = self.allProperties;
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [properties enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([[[self class] excludedCommonProperties] containsObject:obj]) {
            return ;
        }
        
        id value = [self valueForKey:obj];
        if (!value) {
            return ;
        }
        
        if ([value isKindOfClass:[NSNumber class]]
            || [value isKindOfClass:[NSDate class]]
            || [value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSDictionary class]]) {
            [dic setObject:value forKey:obj];
        } else if ([value isKindOfClass:[NSArray class]]) {
            NSArray *valueArr = (NSArray *)value;
            if (valueArr.count == 0) {
                return ;
            }
            
            Class elementClass = [self valueForKey:[obj stringByAppendingString:kElementClassSuffix]];
            
            if (elementClass == [NSString class]
                || elementClass == [NSNumber class]
                || elementClass == [NSDate class]) {
                [dic setObject:value forKey:obj];
                return ;
            }
            
            NSMutableArray *arr = [NSMutableArray array];
            [dic setObject:arr forKey:obj];
            
            [valueArr enumerateObjectsUsingBlock:^(id  _Nonnull arrObj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSDictionary *arrDic = [arrObj dictionaryRepresentation];
                if (arrDic) {
                    [arr addObject:arrDic];
                }
            }];
            
        } else {
            [dic setObject:[value dictionaryRepresentation] forKey:obj];
        }
    }];
    return dic.count > 0 ? dic : nil;
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dic {
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    id object = [[self alloc] init];
    [object parseWithDictionary:dic];
    return object;
}

- (void)parseWithDictionary:(NSDictionary *)dic {
    [self parseDataWithDictionary:dic inInstance:self];
}

- (void)parseDataWithDictionary:(NSDictionary *)dic inInstance:(id)instance {
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    if (!dic || !instance) {
        return ;
    }
    
    NSArray *properties = [NSObject propertiesOfClass:[instance class]];
    [properties enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString *propertyName = (NSString *)obj;
        
        id value = [dic objectForKey:propertyName];
        if ([value isKindOfClass:[NSString class]]
            || [value isKindOfClass:[NSNumber class]]) {
            [instance setValue:value forKey:propertyName];
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            id property = [instance valueForKey:propertyName];
            Class subclass = [property class];
            if (!subclass) {
                NSString *classPropertyName = [propertyName stringByAppendingString:@"Class"];
                
                if ([instance respondsToSelector:NSSelectorFromString(classPropertyName)]) {
                    subclass = [instance valueForKey:classPropertyName];
                }
            }
            
            if (subclass) {
                id subinstance = [[subclass alloc] init];
                [instance setValue:subinstance forKey:propertyName];
                
                [self parseDataWithDictionary:(NSDictionary *)value inInstance:subinstance];
                
            } else {
                NSString *keyClassPropName = [propertyName stringByAppendingString:@"KeyClass"];
                
                Class keyClass = nil;
                if ([instance respondsToSelector:NSSelectorFromString(keyClassPropName)]) {
                    keyClass = [instance valueForKey:keyClassPropName];
                }
                
                NSString *valueClassPropName = [propertyName stringByAppendingString:@"ValueClass"];
                
                Class valueClass = nil;
                if ([instance respondsToSelector:NSSelectorFromString(valueClassPropName)]) {
                    valueClass = [instance valueForKey:valueClassPropName];
                }
                
                NSString *valueElementClassPropName = [propertyName stringByAppendingString:@"ValueElementClass"];
                
                Class valueElementClass = nil;
                if ([instance respondsToSelector:NSSelectorFromString(valueElementClassPropName)]) {
                    valueElementClass = [instance valueForKey:valueElementClassPropName];
                }
                
                if (!keyClass || (!valueClass && !valueElementClass)) {
                    [instance setValue:value forKey:propertyName];
                    return ;
                }
                
                NSMutableDictionary *mdic = [[NSMutableDictionary alloc] init];
                [instance setValue:mdic forKey:propertyName];
                
                [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    if ([obj isKindOfClass:[NSArray class]] && valueElementClass) {
                        NSArray *valueArr = [self parseDataWithArray:obj elementClass:valueElementClass];
                        if (valueArr) {
                            [mdic setObject:valueArr forKey:key];
                        }
                    } else {
                        [mdic setObject:obj forKey:key];
                    }
                }];
            }
            
        } else if ([value isKindOfClass:[NSArray class]]) {
            Class subclass = [instance valueForKey:[propertyName stringByAppendingString:kElementClassSuffix]];
            if (!subclass) {
#ifdef DEBUG
                NSLog(@"JSON Parsing Warning: cannot find element class of property: %@ in class: %@\n", propertyName, [[instance class] description]);
#endif
                return;
            }
            
            if (subclass == [NSString class] || subclass == [NSNumber class]) {
                [instance setValue:value forKey:propertyName];
                return ;
            }
            
            NSArray *arr = [self parseDataWithArray:value elementClass:subclass];
            if (arr) {
                [instance setValue:arr forKey:propertyName];
            }
        }
    }];
#pragma clang diagnostic pop
}

- (NSArray *)parseDataWithArray:(NSArray *)arr elementClass:(Class)elementClass {
    if (!elementClass) {
        return nil;
    }
    
    NSMutableArray *results = [NSMutableArray array];
    
    for (NSDictionary *subDic in arr) {
        id subinstance = [[elementClass alloc] init];
        [results addObject:subinstance];
        [self parseDataWithDictionary:subDic inInstance:subinstance];
    }
    
    return results.count > 0 ? results : nil;
}

+ (NSArray *)objectsFromArray:(NSArray *)array {
    NSMutableArray *objects = [NSMutableArray array];
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSDictionary class]]) {
            id object = [[self alloc] init];
            [object parseWithDictionary:obj];
            [objects addObject:object];
        }
    }];
    
    return objects.count > 0 ? objects : nil;
}


@end
