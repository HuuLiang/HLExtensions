//
//  HLNetworkClient.m
//  HLExtensions
//
//  Created by Liang on 2018/4/24.
//

#import "HLNetworkClient.h"
#import "AFNetworking.h"
#import "NSString+extend.h"

@import CoreTelephony;

NSString *const kHLNetworkClientErrorDomain = @"com.hlextensions.errordomian.httpclient";

@interface HLNetworkClient ()
@property (nonatomic,retain) AFHTTPSessionManager *sessionManager;

@property (nonatomic,retain,readonly) CTTelephonyNetworkInfo *networkInfo;
@end


@implementation HLNetworkClient
@synthesize networkInfo = _networkInfo;

+ (instancetype)sharedClient {
    static HLNetworkClient *_sharedClient;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[self alloc] init];
    });
    return _sharedClient;
}

- (CTTelephonyNetworkInfo *)networkInfo {
    if (_networkInfo) {
        return _networkInfo;
    }
    
    _networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    return _networkInfo;
}

- (void)startMonitoring {
    @weakify(self);
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        @strongify(self);
        BOOL reachable = NO;
        if (status == AFNetworkReachabilityStatusReachableViaWWAN
            || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            reachable = YES;
        }
        HLSafelyCallBlock(self.reachabilityChangedAction, reachable);
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

- (HLNetworkStatus)networkStatus {
    AFNetworkReachabilityStatus status = [AFNetworkReachabilityManager sharedManager].networkReachabilityStatus;
    if (status == AFNetworkReachabilityStatusNotReachable) {
        return HLNetworkStatusNotReachable;
    } else if (status == AFNetworkReachabilityStatusReachableViaWiFi) {
        return HLNetworkStatusWiFi;
    } else if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
        NSString *radioAccess = self.networkInfo.currentRadioAccessTechnology;
        if ([radioAccess isEqualToString:CTRadioAccessTechnologyGPRS]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyEdge]
            || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return HLNetworkStatus2G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyWCDMA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSDPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyHSUPA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]
                   || [radioAccess isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return HLNetworkStatus3G;
        } else if ([radioAccess isEqualToString:CTRadioAccessTechnologyLTE]) {
            return HLNetworkStatus4G;
        }
    }
    return HLNetworkStatusUnknown;
}


- (AFHTTPSessionManager *)sessionManager {
    if (_sessionManager) {
        return _sessionManager;
    }
    
    _sessionManager = [[AFHTTPSessionManager alloc] init];
    _sessionManager.requestSerializer.timeoutInterval = 10;
    _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    return _sessionManager;
}

- (void)requestURLPath:(NSString *)urlPath
            withParams:(id)params
                method:(HLHttpMethod)method
     completionHandler:(HLCompletionHandler)completionHandler
{
    
    HLog(@"Request URL: %@ with params: \n%@", urlPath, params);
    
    NSDictionary *encryptedParams = params;// [self encryptParams:params];
    
    @weakify(self);
    if (method == HLHttpGETMethod) {
        [self.sessionManager GET:urlPath parameters:encryptedParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            @strongify(self);
            id decryptedResponse = [self decryptResponse:responseObject];
            HLog(@"HTTP URL:%@ \nResponse: %@", urlPath, decryptedResponse);
            HLSafelyCallBlock(completionHandler, decryptedResponse, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            HLog(@"HTTP URL:%@ \nNetwork Error: %@", urlPath, error.localizedDescription);
            HLSafelyCallBlock(completionHandler, nil, error);
        }];
    } else if (method == HLHttpPOSTMethod) {
        [self.sessionManager POST:urlPath parameters:encryptedParams progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            @strongify(self);
            id decryptedResponse = [self decryptResponse:responseObject];
            HLog(@"HTTP URL:%@ \nResponse: %@", urlPath, decryptedResponse);
            HLSafelyCallBlock(completionHandler, decryptedResponse, nil);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            HLog(@"HTTP URL:%@ \nNetwork Error: %@", urlPath, error.localizedDescription);
            HLSafelyCallBlock(completionHandler, nil, error);
        }];
    } else {
        NSError *error = [NSError errorWithDomain:kHLNetworkClientErrorDomain code:-1 userInfo:@{NSLocalizedDescriptionKey:@"The HTTP method type is NOT supported!"}];
        HLog(@"HTTP URL:%@ \nError:%@", urlPath, error.userInfo[NSLocalizedDescriptionKey]);
        HLSafelyCallBlock(completionHandler, nil, error);
    }
}


- (id)decryptResponse:(id)response {
    NSString *respString = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    if (respString.length == 0) {
        return nil;
    }
    
    id respObject = [NSJSONSerialization JSONObjectWithData:[respString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    return respObject;
}


@end
