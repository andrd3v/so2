//
//  bundle.mm
//  copsbp
//
//  Created by andr on 30.03.2025.
//

#import <Foundation/Foundation.h>

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld_images.h>

#import <mach/mach.h>
#import <mach/mach_traps.h>

#include <dlfcn.h>
#import <sys/stat.h>

#import <objc/runtime.h>

#include <dlfcn.h>
#include <objc/runtime.h>
#include <sys/signal.h>
#include <sys/sysctl.h>
#include <sys/types.h>
#include <sys/stat.h>

#import "inter.h"
#import "helper.h"


#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <string>
#include <vector>
#include <algorithm>
#include <iostream>
#include <cctype>
#include <cstdio>

#include <fstream>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <string.h>

@interface NSBundle (Spoof)
@end

@implementation NSBundle (Spoof)

+ (void)load
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
                
        Method original_infoDictionary = class_getInstanceMethod(self, @selector(infoDictionary));
        Method swizzled_infoDictionary_m = class_getInstanceMethod(self, @selector(swizzled_infoDictionary));
        if (original_infoDictionary && swizzled_infoDictionary_m) method_exchangeImplementations(original_infoDictionary, swizzled_infoDictionary_m);
        
        Method original_bundleIdentifier = class_getInstanceMethod(self, @selector(bundleIdentifier));
        Method swizzled_bundleIdentifier_m = class_getInstanceMethod(self, @selector(swizzled_bundleIdentifier));
        if (original_bundleIdentifier && swizzled_bundleIdentifier_m) method_exchangeImplementations(original_bundleIdentifier, swizzled_bundleIdentifier_m);
        
    });
}

- (NSDictionary *)swizzled_infoDictionary
{
    NSMutableDictionary *original = [[self swizzled_infoDictionary] mutableCopy];
    if (self == [NSBundle mainBundle]) {
        original[@"CFBundleIdentifier"] = [NSString stringWithCString:MY_BUNDLEID_APP encoding:NSUTF8StringEncoding];
        original[@"CFBundleName"] = [NSString stringWithCString:MY_APP_NAME encoding:NSUTF8StringEncoding];
        [original removeObjectForKey:@"SignerIdentity"];
    }
    return [original copy];
}

- (NSString *)swizzled_bundleIdentifier
{
    return (self == [NSBundle mainBundle]) ? [NSString stringWithCString:MY_BUNDLEID_APP encoding:NSUTF8StringEncoding] : [self swizzled_bundleIdentifier];
}


@end

%hook NSBundle
/*
- (NSString *)bundleIdentifier
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    return (self == [NSBundle mainBundle]) ? [NSString stringWithCString:MY_BUNDLEID_APP encoding:NSUTF8StringEncoding] : %orig;
}

- (NSDictionary *)infoDictionary
{
    if(is_caller_tweak())
    {
        return %orig;
    }
    
    NSDictionary *orig = %orig;
    if (!orig)
    {
        return nil;
    }
    
    NSMutableDictionary *original = [orig mutableCopy];
    if (self == [NSBundle mainBundle])
    {
        original[@"CFBundleIdentifier"] = [NSString stringWithCString:MY_BUNDLEID_APP encoding:NSUTF8StringEncoding];
        original[@"CFBundleName"] = [NSString stringWithCString:MY_APP_NAME encoding:NSUTF8StringEncoding];
        [original removeObjectForKey:@"SignerIdentity"];
    }
    return [original copy];
}
*/
- (id)objectForInfoDictionaryKey:(NSString *)key
{
    
    NSDictionary *fakeInfo =
    @{
        @"CFBundleIdentifier": [NSString stringWithCString:MY_BUNDLEID_APP encoding:NSUTF8StringEncoding],
        @"CFBundleName": [NSString stringWithCString:MY_APP_NAME encoding:NSUTF8StringEncoding],
    };
    
    if(!is_caller_tweak() && [key isEqualToString:@"SignerIdentity"])
    {
        return nil;
    }
    
    if(!is_caller_tweak() && [key isEqualToString:@"CFBundleIdentifier"])
    {
        return fakeInfo[key] ?: %orig;
    }

    if(!is_caller_tweak() && [key isEqualToString:@"CFBundleName"])
    {
        return fakeInfo[key] ?: %orig;
    }


    return %orig;
}

+ (instancetype)bundleWithURL:(NSURL *)url
{
    
    NSString *urlString = [url absoluteString];
    const char *path = [urlString UTF8String];

    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }
    
    return %orig;
}

+ (instancetype)bundleWithPath:(NSString *)path
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String))
    {
        return nil;
    }
    
    return %orig;
}

- (instancetype)initWithURL:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }
    
    return %orig;
}

- (instancetype)initWithPath:(NSString *)path
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String))
    {
        return nil;
    }
    
    return %orig;
}

+ (NSBundle *)bundleForClass:(Class)aClass
{
    if(!is_caller_tweak() && is_addr_in_my_lib((__bridge void *)aClass))
    {
        return nil;
    }

    return %orig;
}

+ (NSBundle *)bundleWithIdentifier:(NSString *)identifier
{
    NSBundle* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result && is_hidden_file([result bundlePath].UTF8String))
    {
        return nil;
    }

    return result;
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath
{
    NSURL* result = %orig;
    if (!result) return nil;

    
    NSString *urlString = [result absoluteString];
    const char *path = [urlString UTF8String];
    
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return result;
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext
{
    NSURL* result = %orig;
    if (!result) return nil;

    NSString *urlString = [result absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return result;
}

- (NSArray<NSURL *> *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSURL* url in result)
        {
            NSString *urlString = [url absoluteString];
            const char *path = [urlString UTF8String];
            
            if(is_hidden_file(path))
            {
                [result_filtered removeObject:url];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

- (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName
{
    NSURL* result = %orig;
    if (!result) return nil;

    NSString *urlString = [result absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return result;
}

- (NSArray<NSURL *> *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath localization:(NSString *)localizationName
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSURL* url in result)
        {
            NSString *urlString = [url absoluteString];
            const char *path = [urlString UTF8String];
            
            if(is_hidden_file(path))
            {
                [result_filtered removeObject:url];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

+ (NSURL *)URLForResource:(NSString *)name withExtension:(NSString *)ext subdirectory:(NSString *)subpath inBundleWithURL:(NSURL *)bundleURL
{
    NSURL* result = %orig;
    if (!result) return nil;

    NSString *urlString = [result absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return result;
}

+ (NSArray<NSURL *> *)URLsForResourcesWithExtension:(NSString *)ext subdirectory:(NSString *)subpath inBundleWithURL:(NSURL *)bundleURL
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSURL* url in result)
        {
            NSString *urlString = [url absoluteString];
            const char *path = [urlString UTF8String];
            
            if(is_hidden_file(path))
            {
                [result_filtered removeObject:url];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext
{
    NSString* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && is_hidden_file(result.UTF8String))
    {
        return nil;
    }

    return result;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath
{
    NSString* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && is_hidden_file(result.UTF8String))
    {
        return nil;
    }

    return result;
}

- (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName
{
    NSString* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && is_hidden_file(result.UTF8String))
    {
        return nil;
    }

    return result;
}

- (NSArray<NSString *> *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSString* path in result)
        {
            if(is_hidden_file(path.UTF8String))
            {
                [result_filtered removeObject:path];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

- (NSArray<NSString *> *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)subpath forLocalization:(NSString *)localizationName
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSString* path in result)
        {
            if(is_hidden_file(path.UTF8String))
            {
                [result_filtered removeObject:path];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

+ (NSString *)pathForResource:(NSString *)name ofType:(NSString *)ext inDirectory:(NSString *)bundlePath
{
    NSString* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && is_hidden_file(result.UTF8String))
    {
        return nil;
    }

    return result;
}

+ (NSArray<NSString *> *)pathsForResourcesOfType:(NSString *)ext inDirectory:(NSString *)bundlePath
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSString* path in result)
        {
            if(is_hidden_file(path.UTF8String))
            {
                [result_filtered removeObject:path];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

+ (NSArray<NSBundle *> *)allBundles
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSBundle* bundle in result) {
            if(is_hidden_file([bundle bundlePath].UTF8String))
            {
                [result_filtered removeObject:bundle];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

+ (NSArray<NSBundle *> *)allFrameworks
{
    NSArray* result = %orig;
    if (!result) return nil;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSBundle* bundle in result)
        {
            if(is_hidden_file([bundle bundlePath].UTF8String))
            {
                [result_filtered removeObject:bundle];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

- (NSURL *)appStoreReceiptURL
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSURL *originalURL = %orig;
    NSString *originalPath = [originalURL path];

    NSArray<NSString *> *components = [originalPath pathComponents];
    NSString *realUUID = nil;

    for (NSInteger i = 0; i < components.count; i++)
    {
        if ([components[i] isEqualToString:@"Application"] && i > 0)
        {
            realUUID = components[i - 1];
            break;
        }
    }

    if (!realUUID)
    {
        realUUID = @"UNKNOWN-UUID";
    }

    NSString *fakePath = [NSString stringWithFormat:@"/private/var/mobile/Containers/Data/Application/%@/StoreKit/receipt", realUUID];
    return [NSURL fileURLWithPath:fakePath];
}
/**/

%end

