//
//  DBPersistence.h
//  QBStoreSDK
//
//  Created by Sean Yue on 16/5/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, DBPersistenceOperation) {
    DBPersistenceOperationNone,
    DBPersistenceOperationLoad,
    DBPersistenceOperationSave,
    DBPersistenceOperationRemove
};

@protocol DBPersistence <NSObject>

- (void)save;
- (void)saveWithCompletion:(void (^)(BOOL success))completionBlock;
- (void)removeFromPersistence;
- (void)removeFromPersistenceWithCompletion:(void (^)(BOOL success))completionBlock;

@end

@protocol DBPersistentDelegate <NSObject>

@required
+ (BOOL)DBShouldPersistentSubProperties;
@optional
+ (NSArray *)DBPersistenceExcludedProperties;
+ (NSDictionary *)DBPersistenceCustomObjectMapping;
@end

@protocol DBPersistentObserver <NSObject>

@optional
- (void)DBPersistentClass:(Class)className didFinishOperation:(DBPersistenceOperation)operation;

@end

@interface DBPersistence : NSObject <DBPersistence,DBPersistentDelegate>

+ (NSArray *)objectsFromPersistenceAsync:(void (^)(NSArray *objects))asyncBlock;

+ (instancetype)objectFromPersistenceWithPKValue:(id)value async:(void (^)(id obj))asyncBlock;

+ (void)saveObjects:(NSArray *)objects;
+ (void)saveObjects:(NSArray *)objects withCompletion:(void (^)(BOOL success))completionBlock;

+ (void)removeAllObjectsFromPersistence;
+ (void)removeAllObjectsFromPersistenceWithCompletion:(void (^)(BOOL success))completionBlock;

+ (void)removeFromPersistenceWithObjects:(NSArray *)objects;

- (void)save;
- (void)saveWithCompletion:(void (^)(BOOL success))completionBlock;
- (void)removeFromPersistence;
- (void)removeFromPersistenceWithCompletion:(void (^)(BOOL success))completionBlock;

@end

@interface DBPersistence (SubclassingHooks)

+ (NSString *)primaryKey; // Subclass should override this method to provide customed primary key

@end

@interface DBPersistence (Observation)

+ (void)registerObserver:(__weak id<DBPersistentObserver>)observer;
+ (void)removeObserver:(__weak id<DBPersistentObserver>)observer;

@end
