//
//  AUTTheme.h
//  AUTTheming
//
//  Created by Eric Horacek on 12/22/14.
//  Copyright (c) 2014 Automatic Labs, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AUTBackwardsCompatableNullability.h"

AUT_NS_ASSUME_NONNULL_BEGIN

@class AUTThemeClass;

/**
 
 */
@interface AUTTheme : NSObject

/**
 Creates a theme object from a theme file with the specified name.
 
 @param themeName The name of the theme file. If the theme file ends with
                  "Theme", then you may alternatively specify only the prefix
                  before "Theme" as the theme name. Required.
 @param error     If an error occurs, upon return contains an NSError object
                  that describes the problem.
 
 @return A theme object.
 */
+ (instancetype)themeFromJSONThemeNamed:(NSString *)themeName error:(NSError **)error;

/**
 Creates a theme object from a set of one or mores theme files with the
 specified names.
 
 @param themeNames Names of the theme files as NSStrings. If the theme file ends
                   with "Theme", then you may alternatively specify only the
                   prefix before "Theme" as the theme name. Required.
 @param error      If an error occurs, upon return contains an NSError object
                   that describes the problem.
 
 @return A theme object.
 */
+ (instancetype)themeFromJSONThemesNamed:(NSArray *)themeNames error:(NSError **)error;

/**
 Creates a theme object from a set of one or mores theme files with the
 specified names.
 
 @param themeNames The names of the theme file. If the theme file ends with
                   "Theme", then you may alternatively specify only the prefix
                   before "Theme" as the theme name. Required.
 @param bundle     The bundle that the themes should be loaded from. Optional.
 @param error      If an error occurs, upon return contains an NSError object
                   that describes the problem.
 
 @return A theme object.
 */
+ (instancetype)themeFromJSONThemesNamed:(NSArray *)themeNames bundle:(aut_nullable NSBundle *)bundle error:(NSError **)error;

/**
 Initializes a theme from a theme file.
 
 @param fileURL The NSURL reference to the theme file that the theme object
                should be created from. Required.
 @param error   If an error occurs, upon return contains an NSError object that
                describes the problem.
 
 @return A theme object.
 */
- (instancetype)initWithJSONFile:(NSURL *)fileURL error:(NSError **)error;

/**
 Initializes a theme from a theme file.
 
 @param files An array of NSURL reference to the theme file that the theme
              object should be created from. Required.
 @param error If an error occurs, upon return contains an NSError object that
              describes the problem.
 
 @return A theme object.
 */
- (instancetype)initWithJSONFiles:(NSArray *)fileURLs error:(NSError **)error;

/**
 Initializes a theme from a theme dictionary.
 
 @param dictionary The dictionary to initialze the theme from. Should mirror the
                   syntax of the JSON theme files. Required.
 @param error      If an error occurs, upon return contains an NSError object
                   that describes the problem.
 
 @return A theme object.
 */
- (instancetype)initWithThemeDictionary:(NSDictionary *)dictionary error:(NSError **)error;

/**
 Initializes a theme from an array of theme dictionaries.
 
 @param dictionaries The dictionaries to initialze the theme from. Should mirror
                     the syntax of the JSON theme files. Required.
 @param error        If an error occurs, upon return contains an NSError object
                     that describes the problem.
 
 @return A theme object.
 */
- (instancetype)initWithThemeDictionaries:(NSArray *)dictionaries error:(NSError **)error;

/**
 The constant value from the theme collection for the specified key.
 
 @param key The key for the desired constant.
 
 @return The constant value for the specified key, or if there is none, `nil`.
 */
- (id)constantValueForKey:(NSString *)key;

/**
 The class object for the specified class name.
 
 @param name The name of the desired class.
 
 @return The class for the specified name, or if there is none, `nil`.
 */
- (AUTThemeClass *)classForName:(NSString *)name;

/**
 Applies a theme class with the specified name to an object.
 
 @param name   If name is nil or does not map to an existing class on theme,
               this method has no effect.
 @param object If the object is nil or has no registered class appliers, this
               method has no effect.
 
 @return Whether the class was applied to the object.
 */
- (BOOL)applyClassWithName:(NSString *)name toObject:(id)object;

@end

/**
 The domain for theme parsing errors.
 */
extern NSString * const AUTThemingErrorDomain;

AUT_NS_ASSUME_NONNULL_END
