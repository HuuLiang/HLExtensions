#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "NSArray+Description.h"
#import "NSArray+Random.h"
#import "NSArray+SafeIndex.h"
#import "NSBundle+BundleInfo.h"
#import "NSDate+Utilities.h"
#import "NSDictionary+Description.h"
#import "NSDictionary+HLSign.h"
#import "NSMutableDictionary+SafeCoding.h"
#import "NSObject+BaseRepresentation.h"
#import "NSObject+DictionaryRepresentation.h"
#import "NSObject+Properties.h"
#import "NSString+crypt.h"
#import "NSString+lenght.h"
#import "NSString+md5.h"
#import "RACEXTScope.h"
#import "RACmetamacros.h"
#import "UIDevice+Model.h"
#import "HLDefines.h"
#import "UIColor+hexColor.h"
#import "UIImage+color.h"
#import "UIView+GeometryMetrics.h"
#import "UIView+RoundCorner.h"
#import "UIScrollView+HLRefresh.h"

FOUNDATION_EXPORT double HLExtensionsVersionNumber;
FOUNDATION_EXPORT const unsigned char HLExtensionsVersionString[];

