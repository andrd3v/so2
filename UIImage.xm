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

%hook UIImage
- (instancetype)initWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (UIImage *)imageWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}
%end
