//
//  DBTableVersion.h
//  QBStoreSDK
//
//  Created by Sean Yue on 15/9/27.
//  Copyright (c) 2015 iqu8. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DBTableVersion : NSObject

@property (retain, nonatomic) NSString * tablename;
@property (retain, nonatomic) NSNumber * version;

@end
