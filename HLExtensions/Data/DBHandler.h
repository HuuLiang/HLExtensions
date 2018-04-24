//
//  DBHelper.h
//  QBStoreSDK
//
//  Created by Sean Yue on 15/9/27.
//  Copyright (c) 2015年 iqu8. All rights reserved.
//

// The main purpose of this is to store any NSObject into db and query it back, without user implementation the sqlite (or core data) related code.

// THIS DB HANLDER is designed as a light db operation support, to minimize the work for a simple db usage case, for complex cases of data, use core data support is recommended.
// AS this is a light db op set, many of the TODOs listed below I do NOT intent to solve. As much as this is EASY & good for normal usage.

// TODOs :
//  - mapping is only supposed to be functioning ONLY by default getter/setter objects, how to support customized getter/setter will be considered
//  - mapping now is ONLY doing the first level NSString & NSNumber values, others are DROPPED for now, need to consider more on this.
//    - partially DONE - mapping can get properties all the (super) way up to NSObject.

//  - (DONE) think about auto data migration
//      - design for the DM (data migration)
//              - Every NSObject that uses this and require DM need to introduce a NSNumber * otdb_version property (for now must be unsigned int)
//              - create the protocol of data migration, including these functions
//                  - (NSArray *) fetchAllVersions
//                  - (NSString *) getCurrentVersion
//                  - (NSString *) getMappingFromVersion: (NSString *) originalV toVersion:(NSString *) targetV
//                    Please note the logic behind this funciton is like this:
//                     1. first db handler will find out the OV(orignial v) and current class TV(target v)
//                     2. then it will try to do DM directly from OV to target TV
//                     3. if 2 result in empty mapping, then db handler will continuesly try to do DM from OV to OV+1, until OV+1 reaches TV
//                    so if you have n versions, at least u need to provide 1->2 2->3 .... n-1->n mapping, but you can also add any mapping n - > m in case if convenience
//   YES - it's done now. see migrateClassTable and all the codes related to that, slightly different compare to above design but the idea is the same

//  - think about auto primary keys - no yet needed for now

#import "DBMigration.h"
#import "DBTableVersion.h"
#import "DBPersistence.h"

// TODO - move it out to Category in Framework, for now I don't want to add new file which fouces me to commit in git
@interface NSMutableDictionary (SetOperation)

- (NSMutableDictionary *) addDic : (NSDictionary *) addDictionary;
- (NSMutableDictionary *) minusDic : (NSDictionary *) minusDictionary;

- (NSMutableDictionary *) addByKeyArray : (NSArray *) keyArray;
- (NSMutableDictionary *) minusByKeyArray : (NSMutableArray *) keyArray modifyInput: (BOOL) mInput;

@end

@interface DBHandler : NSObject

/**
 *  拿取DB操作单例
 *
 *  @return DB操作实例-单例对象
 */
+ (DBHandler *)sharedInstance;

/**
 *  新插入或者更新数据
 *
 *  @return 操作成功还是失败
 */
- (BOOL)insertOrUpdateWithModelArr:(NSArray *)modelArr byPrimaryKey:(NSString *)pKey;

/**
 *  查询符合条件的数据
 *
 *  @param modelClass 查询的类 (必须是NSObject的子类)
 *  @param key        查询类中的字段名
 *  @param value      查询类中的字段名的取值
 *  @param oKey       查询结果排序依据字段
 *  @param desc       查询结果是否按照降序排列
 *
 *  @return 查询到得的数据记录
 */
- (NSArray *) queryWithClass: (Class)modelClass key: (NSString *) key value :(NSObject *) value orderByKey:(NSString *)oKey desc:(BOOL)desc;

/**
 *  删除符合条件的数据
 *
 *  @param arrOfmodel 删除model的数组
 *  @param key        删除model类的主键
 *
 *  @return 删除结果
 */
- (BOOL) deleteModels: (NSArray *)arrOfmodel withPrimaryKey: (NSString *)key;

/**
 *  删除该类型所有数据
 *
 *  @param modelClass 删除的目标类型
 *
 *  @return 删除结果
 */
- (BOOL) dropModels: (Class)modelClass;

@end
