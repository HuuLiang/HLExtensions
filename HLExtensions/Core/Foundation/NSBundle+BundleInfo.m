//
//  NSBundle+BundleInfo.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "NSBundle+BundleInfo.h"

@implementation NSBundle (BundleInfo)

- (NSString *)bundleVersion {
    return self.infoDictionary[@"CFBundleShortVersionString"];
}

- (NSString *)bundleName {
    return self.infoDictionary[@"CFBundleDisplayName"];
}

@end
