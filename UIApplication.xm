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

#import "fishhook.h"
#import "helper.h"


%hook UIApplication
- (BOOL)canOpenURL:(NSURL *)url 
{
    NSArray *schemesToCheck = @[
        @"activator",
        @"cydia",
        @"filza",
        @"sileo",
        @"undecimus",
        @"zbra",
        @"saurik",
        @"pangu",
        @"mobileterminal",
        @"sbsettings",
        @"openssh"
        @"filza",
        @"db-lmvo0l08204d0a0",
        @"boxsdk-810yk37nbrpwaee5907xc4iz8c1ay3my",
        @"com.googleusercontent.apps.802910049260-0hf6uv6nsj21itl94v66tphcqnfl172r",
        @"sileo",
        @"zbra",
        @"santander",
        @"icleaner",
        @"xina",
        @"ssh",
        @"apt-repo",
        @"cydia",
        @"activator",
        @"postbox",
    ];
    
    if ([schemesToCheck containsObject:url.scheme] && !is_caller_tweak())
    {
        return NO;
    }

    return %orig;
}
%end

%hook UIDevice
+ (BOOL)isJailbroken
{
    return NO;
}

- (BOOL)isJailBreak
{
    return NO;
}

- (BOOL)isJailBroken
{
    return NO;
}

+ (BOOL) bdx_isJailBroken
{
    return NO;
}

+ (BOOL)btd_isJailBroken
{
    return NO;
}

%end
