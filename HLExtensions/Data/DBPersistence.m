//
//  DBPersistence.m
//  QBStoreSDK
//
//  Created by Sean Yue on 16/5/9.
//  Copyright © 2016年 iqu8. All rights reserved.
//

#import "DBPersistence.h"
#import "DBHandler.h"


@implementation DBPersistence (Observation)

+ (NSMutableDictionary<NSString *, NSMutableArray *> *)sharedObersers {
    static NSMutableDictionary *_sharedObersers;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObersers = [NSMutableDictionary dictionary];
    });
    return _sharedObersers;
}

+ (void)registerObserver:(id<DBPersistentObserver>)observer {
    if (observer == nil) {
        return ;
    }
    
    NSMutableDictionary<NSString *, NSMutableArray *> *observerDic = [self sharedObersers];
    NSMutableArray *observers = observerDic[NSStringFromClass([self class])];
    if (!observers) {
        observers = [NSMutableArray array];
        [observerDic setObject:observers forKey:NSStringFromClass([self class])];
    }
    
    [observers addObject:observer];
}

+ (void)removeObserver:(id<DBPersistentObserver>)observer {
    if (observer == nil) {
        return ;
    }
    
    NSMutableDictionary<NSString *, NSMutableArray *> *observerDic = [self sharedObersers];
    NSMutableArray *observers = observerDic[NSStringFromClass([self class])];
    [observers removeObject:observer];
}

+ (void)notifyObserversWithOperation:(DBPersistenceOperation)operation {
    NSMutableDictionary<NSString *, NSMutableArray *> *observerDic = [self sharedObersers];
    NSMutableArray *observers = observerDic[NSStringFromClass([self class])];
    [observers enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj conformsToProtocol:@protocol(DBPersistentObserver)]) {
            id<DBPersistentObserver> observer = obj;
            if ([observer respondsToSelector:@selector(DBPersistentClass:didFinishOperation:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [observer DBPersistentClass:[self class] didFinishOperation:operation];
                });
            }
        }
    }];
}

@end

@implementation DBPersistence

+ (dispatch_queue_t)persistenceQueue {
    static dispatch_queue_t _persistenceQueue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *queueName = [NSString stringWithFormat:@"com.qbstore.queue.persistence.%@", [self class]];
        _persistenceQueue = dispatch_queue_create(queueName.UTF8String, nil);
    });
    return _persistenceQueue;
}

+ (BOOL)DBShouldPersistentSubProperties {
    return NO;
}

+ (NSArray *)DBPersistenceExcludedProperties {
    return @[@"description",@"debugDescription",@"hash",@"superclass"];
}

+ (NSArray *)objectsFromPersistence {
    return [[DBHandler sharedInstance] queryWithClass:[self class] key:nil value:nil orderByKey:nil desc:NO];
}

+ (NSArray *)objectsFromPersistenceAsync:(void (^)(NSArray *objects))asyncBlock {
    if (asyncBlock) {
        dispatch_async(self.persistenceQueue, ^{
            NSArray *objects = [self objectsFromPersistence];
            dispatch_async(dispatch_get_main_queue(), ^{
                asyncBlock(objects);
                if (objects && objects.count > 0) {
                    [self notifyObserversWithOperation:DBPersistenceOperationLoad];
                }
            });
        });
    } else {
        return [self objectsFromPersistence];
    }
    return nil;
}

+ (instancetype)objectFromPersistenceWithPKValue:(id)value {
    return [[DBHandler sharedInstance] queryWithClass:[self class] key:[[self class] primaryKey] value:value orderByKey:nil desc:NO].firstObject;
}

+ (instancetype)objectFromPersistenceWithPKValue:(id)value async:(void (^)(id obj))asyncBlock {
    if (asyncBlock) {
        dispatch_async(self.persistenceQueue, ^{
            id object = [self objectFromPersistenceWithPKValue:value];
            dispatch_async(dispatch_get_main_queue(), ^{
                asyncBlock(object);
                if (object) {
                    [self notifyObserversWithOperation:DBPersistenceOperationLoad];
                }
            });
        });
    } else {
        return [self objectFromPersistenceWithPKValue:value];
    }
    return nil;
}

+ (void)saveObjects:(NSArray *)objects {
    [self saveObjects:objects withCompletion:nil];
}

+ (void)saveObjects:(NSArray *)objects withCompletion:(void (^)(BOOL success))completionBlock {
    if (objects.count == 0) {
        return ;
    }
    
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([obj class] == [self class], @"DBPersistence: the object to be persisted must be a class of %@!", [self class]);
    }];
    
    dispatch_async(self.persistenceQueue, ^{
        BOOL ret = [[DBHandler sharedInstance] insertOrUpdateWithModelArr:objects byPrimaryKey:[[self class] primaryKey]];
        if (ret) {
            [self notifyObserversWithOperation:DBPersistenceOperationSave];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(ret);
            });
        }
    });
}

+ (void)removeAllObjectsFromPersistence {
    [self removeAllObjectsFromPersistenceWithCompletion:nil];
}

+ (void)removeAllObjectsFromPersistenceWithCompletion:(void (^)(BOOL success))completionBlock {
    dispatch_async(self.persistenceQueue, ^{
        BOOL ret = [[DBHandler sharedInstance] dropModels:[self class]];
        if (ret) {
            [self notifyObserversWithOperation:DBPersistenceOperationRemove];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(ret);
            });
        }
    });
}

+ (void)removeFromPersistenceWithObjects:(NSArray *)objects {
    if (objects.count == 0) {
        return ;
    }
    
    [objects enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSAssert([obj class] == [self class], @"DBPersistence: the object to be persisted must be a class of %@!", [self class]);
    }];
    
    dispatch_async(self.persistenceQueue, ^{
        BOOL ret = [[DBHandler sharedInstance] deleteModels:objects withPrimaryKey:[[self class] primaryKey]];
        if (ret) {
            [self notifyObserversWithOperation:DBPersistenceOperationRemove];
        }
        
    });
}

- (void)save {
    [self saveWithCompletion:nil];
}

- (void)saveWithCompletion:(void (^)(BOOL success))completionBlock {
    dispatch_async([self class].persistenceQueue, ^{
        BOOL ret = [[DBHandler sharedInstance] insertOrUpdateWithModelArr:@[self] byPrimaryKey:[[self class] primaryKey]];
        if (ret) {
            [[self class] notifyObserversWithOperation:DBPersistenceOperationSave];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(ret);
            });
        }
    });
}

- (void)removeFromPersistence {
    [self removeFromPersistenceWithCompletion:nil];
}

- (void)removeFromPersistenceWithCompletion:(void (^)(BOOL success))completionBlock {
    dispatch_async([self class].persistenceQueue, ^{
        BOOL ret = [[DBHandler sharedInstance] deleteModels:@[self] withPrimaryKey:[[self class] primaryKey]];
        if (ret) {
            [[self class] notifyObserversWithOperation:DBPersistenceOperationRemove];
        }
        
        if (completionBlock) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completionBlock(ret);
            });
        }
    });
}

@end

@implementation DBPersistence (SubclassingHooks)

+ (NSString *)primaryKey {
    NSAssert(0, @"You must override +primaryKey in your subclass of DBPersisitence!");
    return nil;
}

@end
