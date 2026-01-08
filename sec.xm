#import <Foundation/Foundation.h>

#import <mach-o/dyld.h>
#import <mach-o/getsect.h>
#import <mach-o/dyld_images.h>
#import <mach-o/loader.h>
#import <mach-o/nlist.h>
#import <mach-o/dyld_images.h>
#import "include/dyld_priv.h"

#import <mach/mach.h>
#import <mach/mach_traps.h>

#include <dlfcn.h>
#import <sys/stat.h>
#include <sys/types.h>

#import <objc/runtime.h>
#import <objc/message.h>

#import "helper.h"
#import "inter.h"
#import "fishhook.h"

#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>

/*
CFDictionaryRef orig_SecTaskCopyValuesForEntitlements(SecTaskRef task, CFArrayRef entitlements, CFErrorRef *error);
CFDictionaryRef my_SecTaskCopyValuesForEntitlements(SecTaskRef task, CFArrayRef entitlements, CFErrorRef *error)
{
    CFDictionaryRef dict = orig_SecTaskCopyValuesForEntitlements(task, entitlements, error);
    if (dict) 
    {
        CFStringRef appId = CFDictionaryGetValue(dict, CFSTR("application-identifier"));
        CFStringRef teamId = CFDictionaryGetValue(dict, CFSTR("com.apple.developer.team-identifier"));

        if (appId && teamId && CFStringHasPrefix(appId, teamId)) 
        {
            CFIndex len = CFStringGetLength(teamId);
            CFMutableStringRef newAppId = CFStringCreateMutableCopy(kCFAllocatorDefault, len, teamId);
            CFStringAppend(newAppId, CFSTR("."));
            CFStringAppend(newAppId, appId);

            CFDictionarySetValue(dict, CFSTR("application-identifier"), newAppId);
            CFRelease(newAppId);
        }
    }

    return dict;
}

__attribute__((constructor))
static void hook()
{
    c_hook("SecTaskCopyValuesForEntitlements", (void *)my_SecTaskCopyValuesForEntitlements, (void **)&orig_SecTaskCopyValuesForEntitlements);
}
*/