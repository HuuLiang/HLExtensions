//
//  HLUser.h
//  HLExtensions_Example
//
//  Created by Liang on 2019/1/17.
//  Copyright © 2019 757437150@qq.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBHandler.h"


@interface HLUser : DBPersistence

@property (nonatomic,copy) NSNumber *id;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,assign) NSInteger num;
//@property (nonatomic,copy) NSString *age;
//@property (nonatomic,copy) NSString *userName;


@end

