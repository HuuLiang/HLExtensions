//
//  NSObject+DictionaryRepresentation.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

extern NSString *const kPersistenceTypeKey;

typedef NSString * (^YYKPlistPersistenceCryptBlock)(NSString *propertyName, id instance);

@interface NSObject (DictionaryRepresentation)

- (NSDictionary *)dictionaryRepresentationWithEncryptBlock:(YYKPlistPersistenceCryptBlock)encryptBlock;
+ (instancetype)objectFromDictionary:(NSDictionary *)dic withDecryptBlock:(YYKPlistPersistenceCryptBlock)decryptBlock;
+ (BOOL)persist:(NSArray *)objects inSpace:(NSString *)spaceName withPrimaryKey:(NSString *)primaryKey clearBeforePersistence:(BOOL)shouldClear encryptBlock:(YYKPlistPersistenceCryptBlock)encryptBlock;
+ (NSArray *)allPersistedObjectsInSpace:(NSString *)spaceName withDecryptBlock:(YYKPlistPersistenceCryptBlock)decryptBlock;

@end
