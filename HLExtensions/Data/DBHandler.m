//
//  DBHelper.m
//  QBStoreSDK
//
//  Created by Sean Yue on 15/9/27.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

#import <FMDB/FMDB.h>
#import "DBHandler.h"
#import <objc/runtime.h>

#define db_name @"db.sqlite"
#define LocalizedStr(key)  NSLocalizedString(key, @"")

#ifdef  DEBUG
#define HLog(fmt,...) {NSLog((@"%s [Line:%d]" fmt),__PRETTY_FUNCTION__,__LINE__,##__VA_ARGS__);}
#else
#define HLog(...)
#endif

@interface DBPersistentProperty : NSObject
@property (nonatomic) NSString *propertyPath;
@property (nonatomic) NSString *propertyType;
@property (nonatomic) id propertyValue;

+ (instancetype)persistentPropertyWithPath:(NSString *)path type:(NSString *)type value:(id)value;

@end

@implementation DBPersistentProperty

+ (instancetype)persistentPropertyWithPath:(NSString *)path type:(NSString *)type value:(id)value {
    DBPersistentProperty *persistentProp = [[self alloc] init];
    persistentProp.propertyPath = path;
    persistentProp.propertyType = type;
    persistentProp.propertyValue = value;
    return persistentProp;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"propertyPath:%@; propertyType:%@; propertyValue:%@", self.propertyPath, self.propertyType, self.propertyValue];
}
@end

@implementation NSMutableDictionary (SetOperation)

- (NSMutableDictionary *) addDic : (NSDictionary *) addDictionary
{
    if (addDictionary == nil || [addDictionary count] ==0) {
        return self;
    }
    
    [addDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        __block BOOL foundmatch = NO;
        [self enumerateKeysAndObjectsUsingBlock:^(id tmpKey, id tmpObj, BOOL *stop) {
            if ( [(NSString *)tmpObj isEqualToString:key]) {
                foundmatch = YES;
                *stop = YES;
                [self setObject:obj forKey:tmpKey];
            }
        }];
        
        if (!foundmatch)
            [self setObject:obj forKey:key];
    }];
    
    return self;
}

- (NSMutableDictionary *) minusDic : (NSDictionary *) minusDictionary
{
    if (minusDictionary == nil || [minusDictionary count] ==0) {
        return self;
    }
    
    [minusDictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [self removeObjectForKey:key];
    }];
    
    return self;
}

- (NSMutableDictionary *) addByKeyArray : (NSArray *) keyArray
{
    if (keyArray == nil || [keyArray count] ==0) {
        return self;
    }
    
    [keyArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj isKindOfClass:[NSString class]]) {
            [self setObject:@"" forKey:obj];
        }
    }];
    
    return self;
}

- (NSMutableDictionary *) minusByKeyArray : (NSMutableArray *) keyArray modifyInput: (BOOL) mInput
{
    if (keyArray == nil || [keyArray count] ==0) {
        return self;
    }
    
    for (int i=0; i< [keyArray count]; i++) {
        id obj = [keyArray objectAtIndex:i];
        if ([obj isKindOfClass:[NSString class]]) {
            if ([self objectForKey:obj] != nil) {
                [self removeObjectForKey:obj];
                if (mInput) {
                    [keyArray removeObjectAtIndex:i];
                    i--;
                }
            }
        }
    }
    
    return self;
}

- (NSMutableDictionary *) mergeWithUpdateDic: (NSMutableDictionary *)updateDic
{
    if (updateDic == nil || [updateDic count] ==0) {
        return self;
    }
    
    [updateDic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([self objectForKey:key] != nil) {
            [self removeObjectForKey:key];
            [self setObject:@"" forKey:obj];
            [updateDic removeObjectForKey:key];
        }
    }];
    
    return self;
}

- (NSMutableDictionary *) minusByKeyArrayUseValue: (NSMutableArray *) keyArray modifyInput:(BOOL)mInput
{
    for (int i=0; i<[keyArray count]; i++) {
        id arraykey = [keyArray objectAtIndex:i];
        [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([(NSString *)obj isEqualToString:arraykey]) {
                [self removeObjectForKey:key];
                [keyArray replaceObjectAtIndex:i withObject:key];
            }
        }];
    }
    
    return self;
}

@end


typedef NS_ENUM(NSInteger, TZSDbTableCmpResult) {
    TZSDbTableNotExist       = 1,
    TZSDbTableChanged        = 2,
    TZSDbTableTheSame        = 3,
    TZSDbTableMigratable     = 4,
};

@interface DBHandler () {
    FMDatabaseQueue *otDbQueue;
}
@end

static DBHandler *dbHandler = nil;
@implementation DBHandler

#pragma mark -dbFilePath
+ (NSString *)dbFilePath {
    NSArray *documentArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *dbPath = [[documentArr objectAtIndex:0] stringByAppendingPathComponent:db_name];
    return dbPath;
}

#pragma mark -sharedInstance
+ (DBHandler *)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dbHandler = [[DBHandler alloc] init];
    });
    return dbHandler;
}

+ (NSString *)createTableSQLWithModel:(NSObject *)model inDb:(FMDatabase *)db{
    //NSString *modelName = NSStringFromClass(model.class);
    NSMutableArray *sqlProperties = [NSMutableArray array];
    NSDictionary *objProperties = [[self class] persistentPropertiesOfClass:[model class]];
    //NSArray<DBPersistentProperty *> *propArr = [[self class] persistentPropertiesOfInstance:model];
    [objProperties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"NSNumber"]) {
            [sqlProperties addObject:[NSString stringWithFormat:@"`%@` double", key]];
        } else if ([obj isEqualToString:@"NSString"]) {
            [sqlProperties addObject:[NSString stringWithFormat:@"`%@` text", key]];
        }
    }];
    
    NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)",NSStringFromClass(model.class),[sqlProperties componentsJoinedByString:@","]];
    return createTableSQL;
}

#pragma mark -init
- (instancetype)init {
    if (self = [super init]) {
        otDbQueue = [FMDatabaseQueue databaseQueueWithPath:[DBHandler dbFilePath]];
        [self createTableVersionDb];
    }
    return self;
}

#pragma mark -insertOrUpdateWithModelArr
- (BOOL)insertOrUpdateWithModelArr:(NSArray *)modelArr byPrimaryKey:(NSString *)pKey{
    if (modelArr.count > 0) {
        // 检测建表逻辑
        NSObject *model = modelArr.lastObject;
        TZSDbTableCmpResult cmpResult = [self verifyCompatibilyForTable:model];
        // for now - if the class property type is not compatible with the current database table
        if (cmpResult == TZSDbTableMigratable) {
            // do the migration
            BOOL migrateResult = [self migrateClassTable:model];
            if (migrateResult) {
                // if migration success the means the table are the same as current class
                cmpResult = TZSDbTableTheSame;
            }
            else{
                // for the migration failure case, the only left option is to drop the table and create a new version
                cmpResult = TZSDbTableChanged;
            }
        }
        
        if (cmpResult == TZSDbTableChanged) {
            [self dropModels:[model class]];
        }
        
        if (cmpResult != TZSDbTableTheSame) {
            [otDbQueue inDatabase:^(FMDatabase *db) {
                @try {
                    if (![db open]) {
                        HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                        return ;
                    }
                    NSString *createSQL = [DBHandler createTableSQLWithModel:(NSObject *)model inDb:db];
                    db.shouldCacheStatements = YES;
                    if (![db executeUpdate:createSQL]) {
                        HLog(@"create DB fail - %@", createSQL);
                    };
                }
                @catch (NSException *exception) {
                    HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
                }
                @finally {
                    [db close];
                }
            }];
        }
    }
    
    // insert or update the data
    for (int i=0; i<modelArr.count; i++) {
        NSObject * model = [modelArr objectAtIndex:i];
        
        // check if this model exists in the db
        // not sure if this might be a potential efficiency problem, but querying everytime for every object feels pretty weird, so list this as TODO
        BOOL recordExists = NO;
        NSObject * pKeyValue = nil;
        if (pKey != nil) {
            pKeyValue = [[self class] fetchValueFrom:model forKey:pKey];
            if (pKeyValue != nil) {
                NSArray * existingObjs =  [NSArray array];
                existingObjs = [self queryWithClass:[model class] key:pKey value:pKeyValue orderByKey:nil desc:NO];
                // TODO - shall we change this to == 1 ?
                if (existingObjs.count > 0) {
                    recordExists = YES;
                }
            }
        }
        
        if (recordExists) {
            [self updateModel:model primaryKey:pKey pKeyValue:pKeyValue];
        }
        else{
            [self insertModel:model];
        }
    }
    
    return YES;
}

- (BOOL) deleteModels: (NSArray *)arrOfmodel withPrimaryKey: (NSString *)key
{
    __block BOOL deleteRst = NO;
    // first get table name & set up the sql command
    NSObject * model = arrOfmodel.lastObject;
    NSString * tableName = NSStringFromClass([model class]);
    NSString * sqlString = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@",tableName,key];
    
    NSObject * pKeyValue = [[self class] fetchValueFrom:model forKey:key];
    if ([pKeyValue isKindOfClass:[NSString class]]) {
        // binding the like parameter doesn't need ''
        sqlString = [sqlString stringByAppendingString:@" LIKE ?"];
    }
    else if ([pKeyValue isKindOfClass:[NSNumber class]]) {
        sqlString = [sqlString stringByAppendingString:@" = ?"];
    }
    else{
        HLog(@"parameter error");
        return NO;
    }
    
    // execute it
    for (NSObject * delModel in arrOfmodel) {
        NSObject * delMKeyValue = [[self class] fetchValueFrom:delModel forKey:key];
        [otDbQueue inDatabase:^(FMDatabase *db) {
            @try {
                if (![db open]) {
                    HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                    return ;
                }
                HLog(@"executing insert sql - %@",sqlString);
                deleteRst = [db executeUpdate:sqlString, delMKeyValue];
            }
            @catch (NSException *exception) {
                HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
            }
            @finally {
                [db close];
            }
        }];
    }
    return deleteRst;
}

- (NSArray *)queryWithClass:(Class)modelClass key:(NSString *)key value:(NSObject *)value orderByKey:(NSString *)oKey desc:(BOOL)desc
{
    NSMutableArray * resultObjArray = [NSMutableArray array];
    NSString * tableName = NSStringFromClass(modelClass);
    
    NSString* sqlString = @"";
    
    // table
    sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    
    // condition
    if (key != nil && value != nil) {
        if ([value isKindOfClass:[NSString class]]) {
            // TODO - currently it's a full match under the case of string scenario, need to consider pattern match by %
            // NOTE - binding the like parameter doesn't need ''
            sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"where %@ LIKE ? ", key]];
        }
        else if([value isKindOfClass:[NSNumber class]]){
            sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"where %@=? ", key]];
        }
        else
        {
            // object other than nsstring nsnumber is not supported for now
            return resultObjArray;
        }
    }
    
    // sort
    if (oKey != nil) {
        sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"order by %@ %@", oKey, desc ? @"DESC" : @"ASC"]];
    }
    
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            FMResultSet* result = [db executeQuery:sqlString,value];
            //FMResultSet* result = [db executeQuery:@"SELECT * FROM TZSUser where usrId LIKE 'r817k5d6'"];
            while ([result next]) {
                id<NSObject> obj = [self objectFromFMResult:result byClass:modelClass];
                if (obj != nil) {
                    [resultObjArray addObject:obj];
                }
            }
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    return resultObjArray;
}

- (NSArray *)queryWithClass:(Class)modelClass key:(NSString *)key models:(NSArray *)models orderByKey:(NSString *)oKey desc:(BOOL)desc {
    NSMutableArray * resultObjArray = [NSMutableArray array];
    NSString * tableName = NSStringFromClass(modelClass);
    
    NSString* sqlString = @"";
    
    // table
    sqlString = [NSString stringWithFormat:@"SELECT * FROM %@ ",tableName];
    
    // condition
    NSMutableArray *values = [NSMutableArray array];
    [models enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [values addObject:[obj valueForKey:key]];
    }];
    
    if (key != nil && values != nil && values.count != 0) {
        NSObject *obj = values.firstObject;
        NSLog(@"%@",obj);
        if([obj isKindOfClass:[NSNumber class]]){
            sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"where %@ ", key]];
        } else {
            // object other than nsstring nsnumber is not supported for now
            return resultObjArray;
        }
    }
    
//    sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"whereasdfadsf "]];

    sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"in (%@)",[values componentsJoinedByString:@","]]];
    
    // sort
    if (oKey != nil) {
        sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"order by %@ %@", oKey, desc ? @"DESC" : @"ASC"]];
    }
    
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            FMResultSet* result = [db executeQuery:sqlString];
            //FMResultSet* result = [db executeQuery:@"SELECT * FROM TZSUser where usrId LIKE 'r817k5d6'"];
            while ([result next]) {
                id<NSObject> obj = [self objectFromFMResult:result byClass:modelClass];
                if (obj != nil) {
                    [resultObjArray addObject:obj];
                }
            }
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    return resultObjArray;
}

- (BOOL)dropModels:(Class)modelClass
{
    NSString *createTableSQL = [NSString stringWithFormat:@"DROP TABLE IF EXISTS %@",NSStringFromClass(modelClass.class)];
    
    __block BOOL dropResult = NO;
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            dropResult = [db executeUpdate:createTableSQL];
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    
    return dropResult;
}

+ (NSDictionary *)persistentPropertiesOfClass:(Class)class {
    return [self persistentPropertiesOfClass:class forKeyPath:nil];
}

+ (NSDictionary *)persistentPropertiesOfClass:(Class)class forKeyPath:(NSString *)keyPath {
    if (class == nil) {
        return nil;
    }
    
    unsigned int propertyCount;
    objc_property_t *properties = class_copyAllPropertyList(class, &propertyCount);
    NSMutableDictionary *propDic = [NSMutableDictionary dictionary];
    //NSMutableArray * arrOfValue = [[NSMutableArray alloc]init];
    for (unsigned int i = 0; i < propertyCount; i++) {
        objc_property_t property = properties[i];
        // 属性
        const char *propertyName = property_getName(property);
        NSString *propertyStr = [NSString stringWithUTF8String:propertyName];
        
        if ([class conformsToProtocol:@protocol(DBPersistentDelegate)] && [class respondsToSelector:@selector(DBPersistenceExcludedProperties)]) {
            NSArray *excludedProperties = [class DBPersistenceExcludedProperties];
            if ([excludedProperties containsObject:propertyStr]) {
                continue;
            }
        }
        const char *attributeOfProperty = property_getAttributes(property);
        NSString *strOfAttribute = [NSString stringWithUTF8String:attributeOfProperty];
        
        NSString *subpath;
        if (keyPath) {
            subpath = [NSString stringWithFormat:@"%@.%@", keyPath, propertyStr];
        } else {
            subpath = propertyStr;
        }
        
        //NSObject * pKeyValue = [instance valueForKey:propertyStr];
        //pKeyValue = pKeyValue ?: @"NULL";
        if ([propertyStr isEqualToString:@"status"]) {
            
        }
        NSString *propertyType;
        if ([strOfAttribute rangeOfString:@"Array"].location == NSNotFound) {
            
            if ([strOfAttribute rangeOfString:@"NSNumber"].location != NSNotFound
                || [strOfAttribute hasPrefix:@"Tq"] || [strOfAttribute hasPrefix:@"TQ"]) {
                propertyType = @"NSNumber";
            }
            else if ([strOfAttribute rangeOfString:@"NSString"].location != NSNotFound) {
                propertyType = @"NSString";
            }
        }
        
        if (propertyType) {
            [propDic setObject:propertyType forKey:subpath];
        } else {
            if (![class conformsToProtocol:@protocol(DBPersistentDelegate)]) {
                continue;
            }
            
            if (![class DBShouldPersistentSubProperties]) {
                continue;
            }
            
            if (![class respondsToSelector:@selector(DBPersistenceCustomObjectMapping)]) {
                continue;
            }
            
            
            NSDictionary *objectMapping = [class DBPersistenceCustomObjectMapping];
            [propDic addEntriesFromDictionary:[[self class] persistentPropertiesOfClass:NSClassFromString(objectMapping[propertyStr])forKeyPath:subpath]];
        }
    }
    free(properties);
    return propDic;
}

#pragma mark private funcitons - shall NOT be public
- (BOOL) insertModel: (NSObject *)model
{
    __block BOOL insertResult = NO;
    // first get table name
    NSString * tableName = NSStringFromClass([model class]);
    __block NSString * sqlString = [NSString stringWithFormat:@"INSERT INTO %@ VALUES(",tableName];
    
    // enum through the properties and set up 1 sql command 2 parameter array
    NSMutableArray * arrOfValue = [[NSMutableArray alloc] init];
    NSDictionary *objProperties = [[self class] persistentPropertiesOfClass:[model class]];
    [objProperties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        sqlString = [sqlString stringByAppendingString:@"?,"];
        [arrOfValue addObject:[model valueForKeyPath:key] ?: [NSNull null]];
    }];
    sqlString = [sqlString substringToIndex:[sqlString length]-1];
    
    sqlString = [sqlString stringByAppendingString:@")"];
    
    // execute it
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            HLog(@"executing insert sql - %@",sqlString);
            insertResult = [db executeUpdate:sqlString withArgumentsInArray:arrOfValue];
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];

    return insertResult;
}


- (BOOL) updateModel: (NSObject *)model primaryKey: (NSString *)pkey pKeyValue: (NSObject *)value
{
    __block BOOL insertResult = NO;
    // first get table name
    NSString * tableName = NSStringFromClass([model class]);
    NSString * sqlString = [NSString stringWithFormat:@"UPDATE %@ set ",tableName];
    
    NSMutableArray * keyValuePairArr = [NSMutableArray array];
    NSMutableArray * arrOfValue = [[NSMutableArray alloc]init];
    // enum through the properties and set up 1 sql command 2 parameter array
    NSDictionary *objProperties = [[self class] persistentPropertiesOfClass:[model class]];
    [objProperties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        [keyValuePairArr addObject:[NSString stringWithFormat:@"`%@` = ?", key]];
        [arrOfValue addObject:[model valueForKeyPath:key] ?: [NSNull null]];
    }];

    sqlString = [sqlString stringByAppendingString:[keyValuePairArr componentsJoinedByString:@","]];
    sqlString = [sqlString stringByAppendingString:[NSString stringWithFormat:@"where `%@` = ?", pkey]];
    [arrOfValue addObject:value];
    
    // execute it
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            
            HLog(@"executing insert sql - %@",sqlString);
            insertResult = [db executeUpdate:sqlString withArgumentsInArray:arrOfValue];
            // do we need to close FMResultSet? or DB close is sufficient?
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    return insertResult;
}

#pragma mark -buildSetSelectorWithProperty
+ (SEL) buildSelectorWithProperty:(NSString *)property {
    NSString *propertySEL = [NSString stringWithFormat:@"set%@%@:",[property substringToIndex:1].uppercaseString,[property substringFromIndex:1]];
    SEL setSelector = NSSelectorFromString(propertySEL);
    return setSelector;
}

+ (SEL) buildGetSelectorWithProperty:(NSString *)property {
    SEL getSelector = NSSelectorFromString(property);
    return getSelector;
}


- ( id<NSObject>) objectFromFMResult: (FMResultSet *)resultSet byClass: (Class)modelClass
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    
    // first create the target class object
    if (![modelClass isSubclassOfClass:[NSObject class]]) {
        return nil;
    }
    
    id resultObj = [[modelClass alloc]init];
    
    NSDictionary *objProperties = [[self class] persistentPropertiesOfClass:modelClass];
    [objProperties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSString *resultStr = (NSString *)[resultSet stringForColumn:key];
        
        if (resultStr) {
            if ([obj isEqualToString:@"NSNumber"]) {
                [[self class] object:resultObj setValue:@(resultStr.doubleValue) forKeyPath:key];
            } else {
                [[self class] object:resultObj setValue:resultStr forKeyPath:key];
            }
        }
    }];
    // let's give it back
    return resultObj;
}

+ (void)object:(NSObject *)object setValue:(id)value forKeyPath:(NSString *)keyPath {
    if (![[object class] conformsToProtocol:@protocol(DBPersistentDelegate)]
        || ![[object class] respondsToSelector:@selector(DBPersistenceCustomObjectMapping)]) {
        return [object setValue:value forKeyPath:keyPath];
    }
    
    NSArray *pathComponents = [keyPath componentsSeparatedByString:@"."];
    if (pathComponents.count < 2) {
        return [object setValue:value forKeyPath:keyPath];
    }
    
    NSDictionary *customObjectMapping = [[object class] performSelector:@selector(DBPersistenceCustomObjectMapping)];
    NSString *subPropName = pathComponents.firstObject;
    NSString *subPropType = customObjectMapping[subPropName];
    if (subPropType) {
        id subPropObject = [object valueForKey:subPropName];
        if (!subPropObject) {
            Class propClass = NSClassFromString(subPropType);
            subPropObject = [[propClass alloc] init];
        }
        [object setValue:subPropObject forKey:subPropName];
        
        [[self class] object:subPropObject setValue:value forKeyPath:[[pathComponents subarrayWithRange:NSMakeRange(1, pathComponents.count-1)] componentsJoinedByString:@"."]];
    }
}

+ (NSObject *) fetchValueFrom: (NSObject *)model forKey:(NSString *)key
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    SEL getterSel = [[self class] buildGetSelectorWithProperty:key];
    if ([model respondsToSelector:getterSel]) {
        return [model performSelector:getterSel];
    }
    return nil;
}

// currently the compatibility check is quite weak, only check for the number of columns
// for future implementation of compatibility and data migration, check .h file header corresponding section
- (TZSDbTableCmpResult) verifyCompatibilyForTable: (NSObject *) model
{
    if ([model isKindOfClass:[DBTableVersion class]])
        return TZSDbTableTheSame;
    
    if (![self isTableExist:NSStringFromClass(model.class)]) {
        return TZSDbTableNotExist;
    }
    
    // try the migration version first
    if ([model.class conformsToProtocol:@protocol(DBMigrationProtocol)]) {
        NSNumber * currentVersion = (NSNumber *)[model performSelector:@selector(dataVersionOfClass)];
        NSUInteger dbVersion = [self getInDbClassVersion:model.class];
        
        if (currentVersion.unsignedIntegerValue != dbVersion) {
            return TZSDbTableMigratable;
        }
    }
    
    NSDictionary *objProperties = [[self class] persistentPropertiesOfClass:[model class]];
    int currentTableColNo = [self tableColumnCount:NSStringFromClass(model.class)];
    if (currentTableColNo != objProperties.count) {
        return TZSDbTableChanged;
    }
//    free(properties);
    return  TZSDbTableTheSame;
}

- (BOOL) isTableExist: (NSString *)tableName
{
    NSString * checkSql = [NSString stringWithFormat:@"SELECT name FROM sqlite_master WHERE type='table' AND name='%@' ", tableName];
    __block BOOL exist = NO;
    
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            FMResultSet * resultSet =  [db executeQuery:checkSql];
            if (resultSet.next) {
                exist = YES;
            }
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    
    return  exist;
}

- (unsigned int) tableColumnCount:(NSString *)tableName
{
    NSString * schemaSql =  [NSString stringWithFormat:@"PRAGMA table_info(%@)", tableName];
    
    __block unsigned int countOfCol = 0;
    // execute it
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            [db executeStatements:schemaSql withResultBlock:^int(NSDictionary *resultsDictionary) {
                countOfCol++;
                return 0;
            }];
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    
    return countOfCol;
}

#pragma mark table of table version related functions

- (void) createTableVersionDb
{
    NSString * tableName = NSStringFromClass([DBTableVersion class]);
    if (![self isTableExist:tableName]) {
        [otDbQueue inDatabase:^(FMDatabase *db) {
            @try {
                if (![db open]) {
                    HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                    return ;
                }
                NSString *createSQL = [DBHandler createTableSQLWithModel:(NSObject *)[[DBTableVersion alloc]init] inDb:db];
                db.shouldCacheStatements = YES;
                if (![db executeUpdate:createSQL]) {
                    HLog(@"create DB fail - %@", createSQL);
                };
            }
            @catch (NSException *exception) {
                HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
            }
            @finally {
                [db close];
            }
        }];
    }
}

- (void) updateClassVersion: (NSObject*)model
{
    DBTableVersion * tVersion = [[DBTableVersion alloc]init];
    tVersion.tablename =  NSStringFromClass([model class]);
    NSNumber * version = (NSNumber *)[model performSelector:@selector(dataVersionOfClass)];
    tVersion.version = version;
    [self insertOrUpdateWithModelArr:@[tVersion] byPrimaryKey:@"tablename"];
}

- (NSUInteger) getInDbClassVersion: (Class)modelClass
{
    NSString * tableName = NSStringFromClass(modelClass);
    NSArray * tVersionArray = [self queryWithClass:[DBTableVersion class] key:@"tablename" value:tableName orderByKey:nil desc:NO];
    if (tVersionArray != nil && [tVersionArray count] == 1) {
        DBTableVersion * tVersion = tVersionArray.lastObject;
        return tVersion.version.integerValue;
    }
    return 0;
}

- (BOOL) migrateClassTable: (NSObject *) model
{
    // just a double check
    if (![model.class conformsToProtocol:@protocol(DBMigrationProtocol)]) {
        return NO;
    }
    
    // this part of the code is a little bit duplicated, i just wanna the function to be totally seperated as we may face quite a lot of change
    NSNumber * currentVersion = (NSNumber *)[model performSelector:@selector(dataVersionOfClass)];
    NSUInteger dbVersion = [self getInDbClassVersion:model.class];
    
    if (currentVersion.unsignedIntegerValue == dbVersion) {
        return YES;
    }
    // NOTE FOR NOW WE ONLY support upgrade, but downgrade shall be supported ;-) it's easy, i just need time
    if (currentVersion.unsignedIntegerValue < dbVersion) {
        return NO;
    }
    
    // let's get the delta information for add/delete/update
    NSMutableDictionary * totalAddSet    = [NSMutableDictionary dictionary];
    NSMutableDictionary * totalUpdateSet = [NSMutableDictionary dictionary];
    NSMutableDictionary * totaldeleteSet = [NSMutableDictionary dictionary];
    
    for (NSUInteger i = dbVersion+1; i <= currentVersion.unsignedIntegerValue; i++){
        NSArray * addArray = [model performSelector:@selector(addedKeysForVersion:) withObject:[NSNumber numberWithUnsignedInteger:i]];
        NSArray * deleleArray = [model performSelector:@selector(deletedKeysForVersion:) withObject:[NSNumber numberWithUnsignedInteger:i]];
        NSMutableDictionary * updateDic = [NSMutableDictionary dictionaryWithDictionary:[model performSelector:@selector(renamedKeysForVersion:) withObject:[NSNumber numberWithUnsignedInteger:i]]];
        
        // quite complicated here, i almost give up on this one... so here is the scenario
        // Short version:
        // for all the changes from orignial to target, we would like a final change to summarize
        
        // Long version:
        // For all the   ADDS     UPDATES     DELETES
        //               add1      update1    delete1
        //               add2      update2    delete2
        //               ..        ..         ..
        //               addn      updaten    deleten
        
        // the first thing for any addx, deletex and updatex is merge them with previous changes So -
        // 1. ADDs minus deletex, if a match is found, then both of the item can be removed
        // 2. DELETES minus addx, if a match is found, then both of the item can be removed - think about 1&2, quite a lot of cases actually ;-D
        // 3. ADDs merge with updatex, if a key to key match is found, the key in ADDs will be replaced by updatex's value, then remove it from updatex
        // 4. UPDATES minus deletex, in case the updated key is removed. then remove the update item and change deletex to the original item.
        
        // after above merges then put addx into ADDS, updatex into UPDATES, deletex into DELETES
        
        NSMutableArray * dArray = [NSMutableArray arrayWithArray:deleleArray];
        NSMutableArray * aArray = [NSMutableArray arrayWithArray:addArray];
        
        [totalAddSet minusByKeyArray:dArray modifyInput:YES];
        [totaldeleteSet minusByKeyArray:aArray modifyInput:YES];
        [totalAddSet mergeWithUpdateDic:updateDic];
        [totalUpdateSet minusByKeyArrayUseValue:dArray modifyInput:YES];
        
        [totalAddSet addByKeyArray:aArray];
        [totaldeleteSet addByKeyArray:dArray];
        [totalUpdateSet addDic:updateDic];
    }
    
    // ok - after having the final ADDS DELETS UPDATES, let's operate on the db
    // due to the fact that sqlite doesn't support the alter for column name or delete column - here is my approach to do the dirty job
    
    // first get all the target class properties
    NSDictionary *objProperties = [[self class] persistentPropertiesOfClass:[model class]];
    NSMutableArray *propertyArr = [NSMutableArray arrayWithCapacity:objProperties.count];
    [objProperties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isEqualToString:@"NSNumber"]) {
            [propertyArr addObject:[NSString stringWithFormat:@"`%@` double",key]];
        } else {
            [propertyArr addObject:[NSString stringWithFormat:@"`%@` text",key]];
        }
    }];
    
    // dump all the data from origial table and creat objects from that
    NSString * queryString = [NSString stringWithFormat:@"SELECT * FROM %@ ",NSStringFromClass(model.class)];
    NSMutableArray * mergedObjects = [NSMutableArray array];
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            FMResultSet* result = [db executeQuery:queryString];
            while ([result next]) {
                // try load it do new class
                // create a object of new class
                id resultObj = [[model.class alloc]init];
                NSDictionary *objProperties = [[self class] persistentPropertiesOfClass:[model class]];
                [objProperties enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull keyPath, id  _Nonnull type, BOOL * _Nonnull stop) {
                    __block NSString * origKey = keyPath;
                    [totalUpdateSet enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        if ([(NSString *)obj isEqualToString:origKey]) {
                            origKey = (NSString *)key;
                            *stop = YES;
                        }
                    }];
                    
                    
                    if ([type isEqualToString:@"NSNumber"]) {
                        double rstDoulbleValue = [result doubleForColumn:origKey];
                        [[self class] object:resultObj setValue:@(rstDoulbleValue) forKeyPath:keyPath];
                    } else {
                        NSString * rstStringValue = [result stringForColumn:origKey];
                        [[self class] object:resultObj setValue:rstStringValue forKeyPath:keyPath];
                    }
                }];
                [mergedObjects addObject:resultObj];
            }
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    
    // drop the old table
    [self dropModels:model.class];
    
    // create new
    NSString *createTableSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)",NSStringFromClass(model.class),[propertyArr componentsJoinedByString:@","]];
    [otDbQueue inDatabase:^(FMDatabase *db) {
        @try {
            if (![db open]) {
                HLog(@"%@",LocalizedStr(@"DB_ERROR"));
                return ;
            }
            db.shouldCacheStatements = YES;
            if (![db executeUpdate:createTableSQL]) {
                HLog(@"create DB fail - %@", createTableSQL);
            };
        }
        @catch (NSException *exception) {
            HLog(@"%@%@",LocalizedStr(@"DB_EXCEPTION"),exception.userInfo.description);
        }
        @finally {
            [db close];
        }
    }];
    
    // insert data in
    for (int i=0; i<mergedObjects.count; i++) {
        NSObject * model = [mergedObjects objectAtIndex:i];
        
        NSString *primaryKey = [model performSelector:@selector(primaryKey)];
        // check if this model exists in the db
        // not sure if this might be a potential efficiency problem, but querying everytime for every object feels pretty weird, so list this as TODO
        BOOL recordExists = NO;
        NSObject * pKeyValue = nil;
        if (primaryKey != nil) {
            pKeyValue = [[self class] fetchValueFrom:model forKey:primaryKey];
            if (pKeyValue != nil){
                NSArray * existingObjs =  [NSArray array];
                existingObjs = [self queryWithClass:[model class] key:primaryKey value:pKeyValue orderByKey:nil desc:NO];
                // TODO - shall we change this to == 1 ?
                if (existingObjs.count > 0) {
                    recordExists = YES;
                }
            }
        }
        if (recordExists) {
            [self updateModel:model primaryKey:primaryKey pKeyValue:pKeyValue];
        }
        else{
            [self insertModel:model];
        }
    }
    
    // update table version information
    DBTableVersion * newDBTVersion = [[DBTableVersion alloc]init];
    newDBTVersion.tablename = NSStringFromClass(model.class);
    newDBTVersion.version = currentVersion;
    [self insertOrUpdateWithModelArr:@[newDBTVersion] byPrimaryKey:@"tablename"];
    
//    free(properties);
    return YES;
}

#pragma mark extension for copy_propertyList

// copies the property list util it reaches the NSObject
// Attention - same as class_copyPropertyList, the returned objc_property_t * needs to be explictly freed by caller.
objc_property_t *class_copyAllPropertyList(Class cls, unsigned int *outCount)
{
    unsigned int propertyCountInAll = 0;
    objc_property_t * currentProperties = NULL;
    Class currentCls = cls;
    while (currentCls != [NSObject class]) {
        unsigned int propertyCount;
        objc_property_t *properties = class_copyPropertyList(currentCls, &propertyCount);
        if (currentProperties == NULL) {
            propertyCountInAll += propertyCount;
            currentProperties = malloc(propertyCountInAll * sizeof(objc_property_t));
            if (currentProperties != NULL) {
                for (int i=0; i<propertyCount; i++) {
                    currentProperties[i] = properties[i];
                }
            }
        }
        else{
            unsigned int oldCount = propertyCountInAll;
            propertyCountInAll += propertyCount;
            currentProperties = realloc(currentProperties, propertyCountInAll* sizeof(objc_property_t));
            for (int i=oldCount; i<propertyCountInAll; i++) {
                currentProperties[i] = properties[i-oldCount];
            }
        }
        currentCls = class_getSuperclass(currentCls);
        free(properties);
    }
    *outCount = propertyCountInAll;
    return currentProperties;
}
@end
