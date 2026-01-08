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

/*
const char *(*orig_class_getImageName)(Class cls);
const char *new_class_getImageName(Class cls)
{
    const char* result = orig_class_getImageName(cls);
    if (isCallerTweak())
    {
        return result;
    }

    if(!is_hidden_dyld(result))
    {
        return result;
    }

    return ;
}
*/

static const char * _Nonnull * (*original_objc_copyImageNames)(unsigned int *outCount);
static const char * _Nonnull * replaced_objc_copyImageNames(unsigned int *outCount)
{
    const char * _Nonnull *original = original_objc_copyImageNames(outCount);
    if (isCallerTweak() || !original || !outCount)
    {
        return original;
    }

    unsigned int origCount = *outCount;
    unsigned int keepCount = 0;
    for (unsigned int i = 0; i < origCount; i++)
    {
        if (!is_hidden_dyld(original[i]))
        {
            keepCount++;
        }
    }

    const char * _Nonnull *filtered = (const char * _Nonnull *)malloc((keepCount + 1) * sizeof(const char * _Nonnull));
    if (!filtered)
    {
        return original;
    }

    unsigned int idx = 0;
    for (unsigned int i = 0; i < origCount; i++)
    {
        if (!is_hidden_dyld(original[i]))
        {
            filtered[idx++] = original[i];
        }
    }

    filtered[idx] = NULL;

    *outCount = keepCount;
    return filtered;
}


%ctor
{
    c_hook("objc_copyImageNames", (void*)replaced_objc_copyImageNames, (void**)&original_objc_copyImageNames);
    
    //HOOK_C(replaced_objc_copyImageNames,objc_copyImageNames);
}

