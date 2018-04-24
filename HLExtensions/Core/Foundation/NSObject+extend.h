//
//  NSObject+extend.h
//  HLExtensions
//
//  Created by Liang on 2018/4/23.
//

#import <Foundation/Foundation.h>

@interface NSObject (extend)

/** Properties */
+ (NSArray *)propertiesOfClass:(Class)cls;
- (NSArray *)allProperties;

/** BaseRepresentation */
+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary;
+ (NSArray *)objectsFromArray:(NSArray *)array;
- (NSDictionary *)dictionaryRepresentation;

@end

#define SynthesizePropertyClassMethod(propName, propClass) \
- (Class)propName##Class { return [propClass class]; }

#define SynthesizeContainerPropertyElementClassMethod(propName, elementClass) \
- (Class)propName##ElementClass { return [elementClass class]; }

#define SynthesizeDictionaryPropertyKeyClassMethod(propName, keyClass) \
- (Class)propName##KeyClass { return [keyClass class]; }

#define SynthesizeDictionaryPropertyValueClassMethod(propName, valueClass) \
- (Class)propName##ValueClass { return [valueClass class]; }

#define SynthesizeDictionaryPropertyValueElementClassMethod(propName, valueElementClass) \
- (Class)propName##ValueElementClass { return [valueElementClass class]; }
