//
//  NSValueTransformer+TypeFiltering.h
//  Pods
//
//  Created by Eric Horacek on 3/9/15.
//
//

#import <Foundation/Foundation.h>

@interface NSValueTransformer (TypeFiltering)

/**
 Returns the first value trasformer that is able to transform the specified object to the specified Obj-C type.
 
 @param object The object that the value transformer should be able to transform the value of.
 @param objCType The Obj-C type of the value that the value transformer should transform the object to. You may pass
 the value returned by the @encode directive.
 
 @return A NSValueTransformer instance, or nil if one could not be found.
 */
+ (NSValueTransformer *)aut_valueTransformerForTransformingObject:(id)object toObjCType:(const char *)objCType;

/**
 Returns the first value trasformer that is able to transform the specified object to the Obj-C class.
 
 @param object The object that the value transformer should be able to transform the value of.
 @param class The class of the value that the value transformer should transform the object to.
 
 @return A NSValueTransformer instance, or nil if one could not be found.
 */
+ (NSValueTransformer *)aut_valueTransformerForTransformingObject:(id)object toClass:(Class)class;

@end