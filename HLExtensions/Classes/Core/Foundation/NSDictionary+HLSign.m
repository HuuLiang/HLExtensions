//
//  NSDictionary+HLSign.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSDictionary+HLSign.h"
#import "NSString+crypt.h"
#import "NSString+md5.h"

NSString *const kParamKeyName       = @"params";
NSString *const kEncryptionKeyName  = @"key";
NSString *const kEncryptionDataName = @"data";

@implementation NSDictionary (HLSign)

- (NSString *)concatenatedValues {
    return [self concatenatedValuesWithKeys:self.allKeys];
}

- (NSString *)concatenatedValuesWithKeys:(NSArray *)keys {
    NSMutableString *concatenatedValues = [NSMutableString string];
    for (NSString *key in keys) {
        NSObject *value = [self valueForKey:key];
        [concatenatedValues appendString:value.description];
    }
    return concatenatedValues;
}

- (NSString *)signWithDictionary:(NSDictionary *)dic keyOrders:(NSArray *)keys {
    NSArray *sortedKeys = [self.allKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2];
    }];
    
    NSMutableString *signedString = [self concatenatedValuesWithKeys:sortedKeys].mutableCopy;
    [signedString appendString:[dic concatenatedValuesWithKeys:keys]];
    [signedString appendString:@"null"];
    return signedString.md5;
}

- (NSString *)signedParamRepresentationWithSign:(NSString *)sign
                             encryptionPassword:(NSString *)password
                                    excludeKeys:(NSArray *)excludedKeys
                              shouldIncludeSign:(BOOL)shouldIncludeSign {
    NSParameterAssert(sign != nil);
    
    __block NSMutableString *params = [NSMutableString string];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([key isKindOfClass:[NSString class]] && ![excludedKeys containsObject:key]) {
            NSString *keyValueString = [NSString stringWithFormat:@"&%@=%@", key, obj];
            [params appendString:keyValueString];
        }
    }];
    
    NSString *signedParams = params;
    if (shouldIncludeSign) {
        signedParams = [NSString stringWithFormat:@"sign=%@%@", sign, params ?: @""];
    }
    return [signedParams encryptedStringWithPassword:[password.md5 substringToIndex:16]];
}

- (NSDictionary *)encryptedDictionarySignedTogetherWithDictionary:(NSDictionary *)dicForSignTogether
                                                        keyOrders:(NSArray *)keys
                                                  passwordKeyName:(NSString *)pwdKeyName {
    NSString *password = [self objectForKey:pwdKeyName];
    if (password.length == 0) {
        password = [dicForSignTogether objectForKey:pwdKeyName];
        NSAssert(password.length > 0, @"No password for encryption found!");
    }
    
    NSString *sign = [self signWithDictionary:dicForSignTogether keyOrders:keys];
    NSAssert(sign.length > 0, @"The sign of url params must NOT be nil!");
    
    //    __block NSMutableString *params = [NSMutableString string];
    //    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    //        if ([key isKindOfClass:[NSString class]] && ![pwdKeyName isEqualToString:key]) {
    //            NSString *keyValueString = [NSString stringWithFormat:@"&%@=%@", key, obj];
    //            [params appendString:keyValueString];
    //        }
    //    }];
    //
    NSString *params = [self signedParamRepresentationWithSign:sign
                                            encryptionPassword:password
                                                   excludeKeys:@[pwdKeyName]
                                             shouldIncludeSign:YES];
    //    NSString *signParam = [NSString stringWithFormat:@"sign=%@", sign];
    //    if (params.length > 0) {
    //        signParam = [signParam stringByAppendingString:params];
    //    }
    
    //    NSString *encryptedParam = [signParam encryptedStringWithPassword:password.md5];
    return [NSDictionary dictionaryWithObject:params forKey:kParamKeyName];
}

- (NSString *)encryptedStringWithSign:(NSString *)sign
                             password:(NSString *)pwd
                          excludeKeys:(NSArray *)excludedKeys {
    return [self encryptedStringWithSign:sign password:pwd excludeKeys:excludedKeys shouldIncludeSign:YES];
}

- (NSString *)encryptedStringWithSign:(NSString *)sign
                             password:(NSString *)pwd
                          excludeKeys:(NSArray *)excludedKeys
                    shouldIncludeSign:(BOOL)shouldIncludeSign {
    NSString *params = [self signedParamRepresentationWithSign:sign encryptionPassword:pwd excludeKeys:excludedKeys shouldIncludeSign:shouldIncludeSign];
    return params;
}

@end
