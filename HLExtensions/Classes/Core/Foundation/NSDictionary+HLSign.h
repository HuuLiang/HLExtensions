//
//  NSDictionary+HLSign.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (HLSign)

- (NSString *)concatenatedValues;
- (NSString *)concatenatedValuesWithKeys:(NSArray *)keys;
- (NSString *)signWithDictionary:(NSDictionary *)dic keyOrders:(NSArray *)keys;

- (NSDictionary *)encryptedDictionarySignedTogetherWithDictionary:(NSDictionary *)dicForSignTogether
                                                        keyOrders:(NSArray *)keys
                                                  passwordKeyName:(NSString *)pwdKeyName;
- (NSString *)encryptedStringWithSign:(NSString *)sign
                             password:(NSString *)pwd
                          excludeKeys:(NSArray *)excludedKeys;

- (NSString *)encryptedStringWithSign:(NSString *)sign
                             password:(NSString *)pwd
                          excludeKeys:(NSArray *)excludedKeys
                    shouldIncludeSign:(BOOL)shouldIncludeSign;

@end

extern NSString *const kParamKeyName;
extern NSString *const kEncryptionKeyName;
extern NSString *const kEncryptionDataName;
