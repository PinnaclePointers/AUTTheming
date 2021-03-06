//
//  AUTTheme+SymbolsGeneration.m
//  AUTThemingSymbolsGenerator
//
//  Created by Eric Horacek on 12/28/14.
//  Copyright (c) 2014 Automatic Labs, Inc. All rights reserved.
//

#import <GBCli/GBCli.h>
#import <AUTTheming/AUTTheming.h>
#import <AUTTheming/AUTTheme_Private.h>
#import "AUTTheme+SymbolsGeneration.h"
#import "NSOutputStream+StringWriting.h"

typedef NS_ENUM(NSInteger, FileType) {
    FileTypeHeader,
    FileTypeImplementation
};

typedef NS_ENUM(NSInteger, SymbolType) {
    SymbolTypeConstantKeys,
    SymbolTypeClassNames,
    SymbolTypeProperties,
    SymbolTypeCount
};

@implementation AUTTheme (SymbolsGeneration)

#pragma mark - Public

- (void)generateSymbolsFilesInDirectory:(NSURL *)directoryURL indentation:(NSString *)indentation prefix:(NSString *)prefix; {
    NSParameterAssert(directoryURL);
    NSParameterAssert(indentation);
    NSParameterAssert(prefix);
    
    [self
        generateSymbolsFileOfType:FileTypeHeader
        intoDirectoryWithURL:directoryURL
        indentation:indentation
        prefix:prefix];
    [self
        generateSymbolsFileOfType:FileTypeImplementation
        intoDirectoryWithURL:directoryURL
        indentation:indentation
        prefix:prefix];
}

+ (void)generateSymbolsUmbrellaHeaderFromThemes:(NSArray *)themes inDirectory:(NSURL *)directoryURL prefix:(NSString *)prefix; {
    NSParameterAssert(themes);
    NSAssert(themes.count > 0, @"Must supply at least one theme");
    NSParameterAssert(directoryURL);
    NSParameterAssert(prefix);
    
    // Create an opened stream from the file at the specified directory
    NSString *outputFilename = [self umbrellaHeaderFilenameWithPrefix:prefix];
    NSOutputStream *outputStream = [self.class
        openedOutputStreamForFilename:outputFilename
        inDirectory:directoryURL];
    
    // Write a warning comment at the top of the file
    NSString *warningComment = [self.class
        warningCommentForFilename:outputFilename];
    [outputStream aut_writeString:warningComment];
    
    // Add an import for reach of the themes
    for (AUTTheme *theme in themes) {
        NSString *name = [self symbolsNameFromName:theme.names.firstObject];
        NSString *import = [self symbolsHeaderImportForName:name prefix:prefix];
        [outputStream aut_writeString:[import stringByAppendingString:@"\n"]];
    }
    
    [outputStream close];
    
    gbprintln(@"Generated: %@", outputFilename);
}

- (NSArray *)constantKeys {
    return self.constants.allKeys;
}

- (NSArray *)classNames {
    return self.classes.allKeys;
}

- (NSArray *)properties {
    NSMutableSet *properties = [NSMutableSet new];
    for (AUTThemeClass *class in self.classes.allValues) {
        [properties addObjectsFromArray:class.properties.allKeys];
    }
    return properties.allObjects;
}

#pragma mark - Private

- (void)generateSymbolsFileOfType:(FileType)fileType intoDirectoryWithURL:(NSURL *)directoryURL indentation:(NSString *)indentation prefix:(NSString *)prefix {
    NSParameterAssert(directoryURL);
    NSParameterAssert(indentation);
    NSParameterAssert(prefix);
    
    NSString *name = [self.class symbolsNameFromName:self.names.firstObject];
    NSString *filename = self.filenames.firstObject;
    
    // Open a stream from the symbols file at the specified directory
    NSString *outputFilename = [self.class
        symbolsFilenameFromName:name
        forFileType:fileType
        prefix:prefix];
    
    NSOutputStream *outputStream = [self.class
        openedOutputStreamForFilename:outputFilename
        inDirectory:directoryURL];
    [outputStream open];
    
    // Write a warning comment at the top of the file
    NSString *warningComment = [self.class
        warningCommentForFilename:filename];
    [outputStream aut_writeString:warningComment];
    
    // Add the necessary import
    NSString *import = [self
        symbolsImportForName:name
        fileType:fileType
        prefix:prefix];
    
    [outputStream
        aut_writeString:[NSString stringWithFormat: @"\n%@\n", import]];
    
    // Add the theme name constant
    NSString *nameConstant = [self
        symbolsThemeNameStringConstFromName:name
        forFiletype:fileType
        prefix:prefix];
    
    [outputStream
        aut_writeString:[NSString stringWithFormat:@"\n%@\n", nameConstant]];
    
    // Write all types of symbols from the theme
    for (SymbolType symbolType = 0; symbolType < SymbolTypeCount; symbolType++) {
        NSString *symbolsDeclartion = [self
            symbolsDeclartionOfType:symbolType
            withFiletype:fileType
            name:name
            indentation:indentation
            prefix:prefix];
        
        if (symbolsDeclartion) {
            NSString *symbolsDeclarationOutput = [NSString stringWithFormat:
                @"\n%@\n",
                symbolsDeclartion];
            [outputStream aut_writeString:symbolsDeclarationOutput];
        }
    }
    
    [outputStream close];
    
    gbprintln(@"Generated: %@", outputFilename);
}

+ (NSOutputStream *)openedOutputStreamForFilename:(NSString *)filename inDirectory:(NSURL *)directoryURL {
    NSParameterAssert(filename);
    NSParameterAssert(directoryURL);
    
    NSURL *outputFileURL = [directoryURL URLByAppendingPathComponent:filename];
    NSOutputStream *outputStream = [NSOutputStream
        outputStreamWithURL:outputFileURL
        append:NO];
    [outputStream open];
    return outputStream;
}

static NSString * const NamePrefix = @"Theme";

+ (NSString *)symbolsNameFromName:(NSString *)name {
    NSParameterAssert(name);
    
    NSString *symbolsName = name;
    // Append 'theme' to the end of the name (unless its name is already 'Theme', then just leave it)
    if (![symbolsName isEqualToString:NamePrefix]) {
        symbolsName = [symbolsName stringByAppendingString:NamePrefix];
    }
    return symbolsName;
}

+ (NSString *)commandToGenerateSymbols {
    NSString *processName = NSProcessInfo.processInfo.processName;
    
    NSArray *arguments = NSProcessInfo.processInfo.arguments;
    NSArray *argumentsMinusProcessName = [arguments
        subarrayWithRange:(NSRange){
            .location = 1,
            .length = (arguments.count - 1)
        }];
    NSString *argumentsAsString = [argumentsMinusProcessName
        componentsJoinedByString:@" "];

    NSString *command = [NSString stringWithFormat:
        @"%@ %@",
        processName,
        argumentsAsString];

    return command;
}

+ (NSString *)symbolsFilenameFromName:(NSString *)name forFileType:(FileType)filetype prefix:(NSString *)prefix {
    NSParameterAssert(name);
    NSParameterAssert(prefix);
    
    NSString *extension = [self extensionForFiletype:filetype];
    return [NSString stringWithFormat:
        @"%@%@Symbols.%@",
        prefix,
        name,
        extension];
}

+ (NSString *)umbrellaHeaderFilenameWithPrefix:(NSString *)prefix {
    NSParameterAssert(prefix);
    
    return [NSString stringWithFormat:@"%@ThemeSymbols.h", prefix];
}

+ (NSString *)extensionForFiletype:(FileType)fileType {
    switch (fileType) {
    case FileTypeHeader:
        return @"h";
    case FileTypeImplementation:
        return @"m";
    }
    return nil;
}

static NSString * const WarningCommentFormat = @"\
// WARNING: Do not modify. This file is machine-generated from '%@'.\n\
// To update these symbols, run the command:\n\
// $ %@\n\
";

+ (NSString *)warningCommentForFilename:(NSString *)filename {
    NSParameterAssert(filename);
    
    return [NSString stringWithFormat:
        WarningCommentFormat,
        filename,
        [self commandToGenerateSymbols]];
}

- (NSString *)symbolsImportForName:(NSString *)name fileType:(FileType)fileType prefix:(NSString *)prefix {
    NSParameterAssert(name);
    
    switch (fileType) {
    case FileTypeHeader:
        return @"#import <Foundation/Foundation.h>";
    case FileTypeImplementation:
        return [self.class symbolsHeaderImportForName:name prefix:prefix];
    }
    return nil;
}

+ (NSString *)symbolsHeaderImportForName:(NSString *)name prefix:(NSString *)prefix {
    
    NSString *importFileName = [self
        symbolsFilenameFromName:name
        forFileType:FileTypeHeader
        prefix:prefix];
    
    return [NSString stringWithFormat:@"#import \"%@\"", importFileName];
}

- (NSString *)symbolsThemeNameStringConstFromName:(NSString *)name forFiletype:(FileType)fileType prefix:(NSString *)prefix {
    NSParameterAssert(name);
    NSParameterAssert(prefix);
    
    NSString *constantName = [NSString stringWithFormat:
        @"%@%@Name",
        prefix,
        name];
    
    switch (fileType) {
    case FileTypeHeader:
        return [NSString stringWithFormat:
            @"extern NSString * const %@;",
            constantName];
    case FileTypeImplementation:
        return [NSString stringWithFormat:
            @"NSString * const %@ = @\"%@\";",
            constantName,
            name];
    }
    return nil;
}

- (NSString *)symbolsDeclartionOfType:(SymbolType)symbolType withFiletype:(FileType)fileType name:(NSString *)name indentation:(NSString *)indentation prefix:(NSString *)prefix {
    NSParameterAssert(indentation);
    NSParameterAssert(prefix);
    
    NSArray *symbols = [self symbolsForType:symbolType];
    if (!symbols || !symbols.count) {
        return nil;
    }
    
    NSMutableArray *lines = [NSMutableArray new];
 
    NSString *enumName = [self
        enumNameForSymbolType:symbolType
        name:name
        prefix:prefix];
    
    [lines addObject:[self
        openingDeclarationForFiletype:fileType
        enumName:enumName]];
    
    for (NSString *symbol in symbols) {
        [lines addObject:[self
            memberDeclarationForSymbol:symbol
            fileType:fileType
            indentation:indentation]];
    }
    [lines addObject:[self
        closingDeclarationForFiletype:fileType
        enumName:enumName]];
    
    return [lines componentsJoinedByString:@"\n"];
}

- (NSString *)openingDeclarationForFiletype:(FileType)filetype enumName:(NSString *)enumName {
    NSParameterAssert(enumName);
    
    switch (filetype) {
    case FileTypeHeader:
        return [NSString stringWithFormat:
            @"extern const struct %@ {",
            enumName];
    case FileTypeImplementation:
        return [NSString stringWithFormat:
            @"const struct %@ %@ = {",
            enumName,
            enumName];
    }
    return nil;
}

- (NSString *)memberDeclarationForSymbol:(NSString *)symbol fileType:(FileType)filetype indentation:(NSString *)indentation {
    NSParameterAssert(symbol);
    NSParameterAssert(indentation);
    
    switch (filetype) {
    case FileTypeHeader:
        return [NSString stringWithFormat:
            @"%@__unsafe_unretained NSString *%@;",
            indentation,
            symbol];
    case FileTypeImplementation:
        return [NSString stringWithFormat:
            @"%@.%@ = @\"%@\",",
            indentation,
            symbol,
            symbol];
    }
    return nil;
}

- (NSString *)closingDeclarationForFiletype:(FileType)filetype enumName:(NSString *)enumName {
    NSParameterAssert(enumName);
    
    switch (filetype) {
        case FileTypeHeader:
            return [NSString stringWithFormat:@"} %@;", enumName];
        case FileTypeImplementation:
            return @"};";
    }
    return nil;
}

- (NSString *)enumNameForSymbolType:(SymbolType)symbolType name:(NSString *)name prefix:(NSString *)prefix {
    NSParameterAssert(name);
    NSParameterAssert(prefix);
    
    NSString *enumName = [NSString stringWithFormat:@"%@%@", prefix, name];
    switch (symbolType) {
    case SymbolTypeClassNames:
        return [enumName stringByAppendingString:@"ClassNames"];
    case SymbolTypeConstantKeys:
        return [enumName stringByAppendingString:@"ConstantKeys"];
    case SymbolTypeProperties:
        return [enumName stringByAppendingString:@"Properties"];
    default:
        return nil;
    }
}

- (NSArray *)symbolsForType:(SymbolType)symbolType {
    switch (symbolType) {
    case SymbolTypeClassNames:
        return self.classNames;
    case SymbolTypeConstantKeys:
        return self.constantKeys;
    case SymbolTypeProperties:
        return self.properties;
    default:
        return nil;
    }
}

@end
