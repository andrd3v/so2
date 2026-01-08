//
//  NSProcess.mm
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
#include <sys/types.h>

#import <objc/runtime.h>
#import <objc/message.h>

#import "helper.h"
#import "inter.h"

#include <stdlib.h>
#include <unistd.h>
#include <limits.h>

%hook NSProcessInfo

- (NSDictionary<NSString *, NSString *> *)environment
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSDictionary *originalEnv = %orig;
    NSMutableDictionary *env = [originalEnv mutableCopy];
    [env removeObjectForKey:@"DYLD_INSERT_LIBRARIES"];
    [env removeObjectForKey:@"DEBUG"];
    [env removeObjectForKey:@"SIMULATOR_DEVICE_NAME"];
    return [env copy];
}

- (NSArray<NSString *> *)swizzled_arguments
{
    if (is_caller_tweak())
    {
        return %orig;
    }


    NSArray *originalArguments = %orig;
    NSMutableArray *filteredArguments = [NSMutableArray array];
    
    for (NSString *arg in originalArguments)
    {
        if (![arg containsString:@"-DebugOnDeviceConversionMeasurement"] && ![arg containsString:@"-DebugDeferredDeepLink"])
        {
            [filteredArguments addObject:arg];
        }
    }
    
    return [filteredArguments copy];
}

- (BOOL) isOperatingSystemAtLeastVersion:(NSOperatingSystemVersion) version
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    return YES;
}

- (BOOL) macCatalystApp
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    return NO;
}

- (BOOL) isiOSAppOnMac
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    return NO;
}


%end
