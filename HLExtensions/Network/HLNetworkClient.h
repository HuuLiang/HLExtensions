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

typedef NS_ENUM(NSInteger, HLNetworkStatus) {
    HLNetworkStatusUnknown = -1,
    HLNetworkStatusNotReachable = 0,
    HLNetworkStatusWiFi = 1,
    HLNetworkStatus2G = 2,
    HLNetworkStatus3G = 3,
    HLNetworkStatus4G = 4
};

typedef void (^HLNetworkReachabilityChangedAction)(BOOL reachable);


@interface HLNetworkClient : NSObject

HLDeclareSingletonMethod(sharedClient)

@property (nonatomic,readonly) HLNetworkStatus networkStatus;
@property (nonatomic,copy) HLNetworkReachabilityChangedAction reachabilityChangedAction;

- (void)startMonitoring;

- (void)requestURLPath:(NSString *)urlPath
            withParams:(id)params
                method:(HLHttpMethod)method
     completionHandler:(HLCompletionHandler)completionHandler;



@end

FOUNDATION_EXTERN NSString *const kHLNetworkClientErrorDomain;
