//
//  NSObject+BaseRepresentation.h
//  HLPodSpec
//
//  Created by Liang on 2018/1/9.
//

#import <Foundation/Foundation.h>

@interface NSObject (BaseRepresentation)

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
