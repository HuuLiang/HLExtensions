//
//  NSBundle+BundleInfo.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface NSBundle (BundleInfo)

@property (nonatomic,readonly) NSString *bundleVersion;
@property (nonatomic,readonly) NSString *bundleName;

@end
