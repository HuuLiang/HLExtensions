//
//  HLNetworkClient.h
//  HLExtensions
//
//  Created by Liang on 2018/4/24.
//

#import <Foundation/Foundation.h>
#import "HLDefines.h"

typedef NS_ENUM(NSUInteger, HLHttpMethod) {
    HLHttpGETMethod,
    HLHttpPOSTMethod,
    HLHttpDefaultMethod = HLHttpPOSTMethod
};

@interface HLNetworkClient : NSObject

HLDeclareSingletonMethod(sharedClient)
HLDeclareSingletonMethod(staticClient)

- (void)requestURLPath:(NSString *)urlPath
            withParams:(id)params
                method:(HLHttpMethod)method
     completionHandler:(HLCompletionHandler)completionHandler;

@end

FOUNDATION_EXTERN NSString *const kHLNetworkClientErrorDomain;
