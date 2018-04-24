//
//  NSString+extend.h
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import <Foundation/Foundation.h>

@interface NSString (extend)

/** md5 */
- (NSString *)md5;

/** crypt */
- (NSString *)encryptedStringWithPassword:(NSString *)password;
- (NSString *)decryptedStringWithPassword:(NSString *)password;
- (NSString *)decryptedStringWithKeys:(NSArray *)keys;

/** lenght */
- (BOOL)isEmpty;

@end
