//
//  UIDevice+Model.m
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import "UIDevice+Model.h"

#import <sys/sysctl.h>

@implementation UIDevice (Model)

- (NSString *)fullModelName {
    size_t size;
    int nR = sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    nR = sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *name = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    return name;
}

+ (QBDeviceType)deviceType {
    NSString *deviceName = [UIDevice currentDevice].fullModelName;
    if ([deviceName isEqualToString:@"iPhone3,1"] || [deviceName isEqualToString:@"iPhone3,2"] || [deviceName isEqualToString:@"iPhone3,3"]) {
        return QBDeviceType_iPhone4;
    } else if ([deviceName isEqualToString:@"iPhone4,1"]) {
        return QBDeviceType_iPhone4S;
    } else if ([deviceName isEqualToString:@"iPhone5,1"] || [deviceName isEqualToString:@"iPhone5,2"]) {
        return QBDeviceType_iPhone5;
    } else if ([deviceName isEqualToString:@"iPhone5,3"] || [deviceName isEqualToString:@"iPhone5,4"]) {
        return QBDeviceType_iPhone5C;
    } else if ([deviceName isEqualToString:@"iPhone6,1"] || [deviceName isEqualToString:@"iPhone6,2"]) {
        return QBDeviceType_iPhone5S;
    } else if ([deviceName isEqualToString:@"iPhone7,2"]) {
        return QBDeviceType_iPhone6;
    } else if ([deviceName isEqualToString:@"iPhone7,1"]) {
        return QBDeviceType_iPhone6P;
    } else if ([deviceName isEqualToString:@"iPhone8,1"]) {
        return QBDeviceType_iPhone6S;
    } else if ([deviceName isEqualToString:@"iPhone8,2"]) {
        return QBDeviceType_iPhone6SP;
    } else if ([deviceName isEqualToString:@"iPhone8,4"]) {
        return QBDeviceType_iPhoneSE;
    } else if ([deviceName isEqualToString:@"iPhone9,1"] || [deviceName isEqualToString:@"iPhone9,3"]) {
        return QBDeviceType_iPhone7;
    } else if ([deviceName isEqualToString:@"iPhone9,2"] || [deviceName isEqualToString:@"iPhone9,4"]) {
        return QBDeviceType_iPhone7P;
    } else if ([deviceName isEqualToString:@"iPhone10,1"] || [deviceName isEqualToString:@"iPhone10,4"]) {
        return QBDeviceType_iPhone8;
    } else if ([deviceName isEqualToString:@"iPhone10,2"] || [deviceName isEqualToString:@"iPhone10,5"]) {
        return QBDeviceType_iPhone8P;
    } else if ([deviceName isEqualToString:@"iPhone10,3"] || [deviceName isEqualToString:@"iPhone10,6"]) {
        return QBDeviceType_iPhoneX;
    } else if ([deviceName isEqualToString:@"iPod1,1"]) {
        return QBDeviceType_iPod_1G;
    } else if ([deviceName isEqualToString:@"iPod2,1"]) {
        return QBDeviceType_iPod_2G;
    } else if ([deviceName isEqualToString:@"iPod3,1"]) {
        return QBDeviceType_iPod_3G;
    } else if ([deviceName isEqualToString:@"iPod4,1"]) {
        return QBDeviceType_iPod_4G;
    } else if ([deviceName isEqualToString:@"iPod5,1"]) {
        return QBDeviceType_iPod_5G;
    } else if ([deviceName isEqualToString:@"iPad1,1"]) {
        return QBDeviceType_iPad;
    } else if ([deviceName isEqualToString:@"iPad1,2"]) {
        return QBDeviceType_iPad_3G;
    } else if ([deviceName isEqualToString:@"iPad2,1"] || [deviceName isEqualToString:@"iPad2,2"] || [deviceName isEqualToString:@"iPad2,3"] || [deviceName isEqualToString:@"iPad2,4"]) {
        return QBDeviceType_iPad_2;
    } else if ([deviceName isEqualToString:@"iPad2,5"] || [deviceName isEqualToString:@"iPad2,6"] || [deviceName isEqualToString:@"iPad2,7"]) {
        return QBDeviceType_iPad_Mini;
    } else if ([deviceName isEqualToString:@"iPad3,1"] || [deviceName isEqualToString:@"iPad3,2"] || [deviceName isEqualToString:@"iPad3,3"]) {
        return QBDeviceType_iPad_3;
    } else if ([deviceName isEqualToString:@"iPad3,4"] || [deviceName isEqualToString:@"iPad3,5"] || [deviceName isEqualToString:@"iPad3,6"]) {
        return QBDeviceType_iPad_4;
    } else if ([deviceName isEqualToString:@"iPad4,1"] || [deviceName isEqualToString:@"iPad4,2"]) {
        return QBDeviceType_iPad_Air;
    } else if ([deviceName isEqualToString:@"iPad4,4"] || [deviceName isEqualToString:@"iPad4,5"] || [deviceName isEqualToString:@"iPad4,6"]) {
        return QBDeviceType_iPad_Mini_2;
    } else if ([deviceName isEqualToString:@"iPad4,7"] || [deviceName isEqualToString:@"iPad4,8"] || [deviceName isEqualToString:@"iPad4,9"]) {
        return QBDeviceType_iPad_Mini_3;
    } else if ([deviceName isEqualToString:@"iPad5,1"] || [deviceName isEqualToString:@"iPad5,2"]) {
        return QBDeviceType_iPad_Mini_4;
    } else if ([deviceName isEqualToString:@"iPad5,3"] || [deviceName isEqualToString:@"iPad5,4"]) {
        return QBDeviceType_iPad_Air_2;
    } else if ([deviceName isEqualToString:@"iPad6,3"] || [deviceName isEqualToString:@"iPad6,4"]) {
        return QBDeviceType_iPad_Pro_9_7;
    } else if ([deviceName isEqualToString:@"iPad6,7"] || [deviceName isEqualToString:@"iPad6,8"]) {
        return QBDeviceType_iPad_Pro_12_9;
    } else if ([deviceName isEqualToString:@"iPad6,11"] || [deviceName isEqualToString:@"iPad6,12"]) {
        return QBDeviceType_iPad_5;
    } else if ([deviceName isEqualToString:@"iPad7,1"] || [deviceName isEqualToString:@"iPad7,2"]) {
        return QBDeviceType_iPad_Pro_12_9_2nd;
    } else if ([deviceName isEqualToString:@"iPad7,3"] || [deviceName isEqualToString:@"iPad7,4"]) {
        return QBDeviceType_iPad_Pro_10_5;
    } else if ([deviceName isEqualToString:@"AppleTV2,1"]) {
        return QBDeviceType_TV_2;
    } else if ([deviceName isEqualToString:@"AppleTV3,1"] || [deviceName isEqualToString:@"AppleTV3,2"]) {
        return QBDeviceType_TV_3;
    } else if ([deviceName isEqualToString:@"AppleTV5,3"]) {
        return QBDeviceType_TV_4;
    } else if ([deviceName isEqualToString:@"i386"] || [deviceName isEqualToString:@"x86_64"]) {
        return QBDeviceType_Simulator;
    }
    return QBDeviceTypeUnknown;
}


@end
