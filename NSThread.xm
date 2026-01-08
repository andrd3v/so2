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


%hook NSThread
- (NSArray *)callStackReturnAddresses
{
    NSArray* result = %orig;

    if(!is_caller_tweak() && result)
    {
        NSMutableArray* result_filtered = [result mutableCopy];

        for(NSNumber* ret_addr in result)
        {
            if(is_addr_in_my_lib([ret_addr pointerValue]))
            {
                [result_filtered removeObject:ret_addr];
            }
        }

        result = [result_filtered copy];
    }

    return result;
}

- (NSArray *)callStackSymbols
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSArray *originalStack = %orig;
    NSMutableArray *filteredStack = [NSMutableArray array];

    for (NSString *symbol in originalStack)
    {
        const char *symCString = [symbol UTF8String];

        if (!is_hidden_sym(symCString))
        {
            [filteredStack addObject:symbol];
        }
    }

    return [filteredStack copy];
}

%end

