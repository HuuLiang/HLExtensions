//
//  NSString+crypt.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface NSString (crypt)

- (NSString *)encryptedStringWithPassword:(NSString *)password;
- (NSString *)decryptedStringWithPassword:(NSString *)password;
- (NSString *)decryptedStringWithKeys:(NSArray *)keys;

@end
