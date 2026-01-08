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
#include <bootstrap.h>

static kern_return_t (*original_bootstrap_check_in)(mach_port_t bp, const char* service_name, mach_port_t* sp);
static kern_return_t replaced_bootstrap_check_in(mach_port_t bp, const char* service_name, mach_port_t* sp)
{
    if(!is_caller_tweak() && service_name) 
    {
        if(strstr(service_name, "cy:") == service_name
        || strstr(service_name, "lh:") == service_name
        || strstr(service_name, "rbs:") == service_name
        || strstr(service_name, "org.coolstar") == service_name
        || strstr(service_name, "com.ex") == service_name
        || strstr(service_name, "com.saurik") == service_name
        || strstr(service_name, "com.opa334") == service_name
        || strstr(service_name, "me.jjolano") == service_name
        || strstr(service_name, "jailbreakd") != NULL
        || strstr(service_name, "xyz.willy") == service_name
        || strstr(service_name, "com.ichitaso") == service_name
        || strstr(service_name, "net.limneos") == service_name
        || strstr(service_name, "com.level3tjg") == service_name
        || strstr(service_name, "org.thebigboss") == service_name
        || strstr(service_name, "amfid") != NULL
        || strstr(service_name, "substrated") != NULL
        || strstr(service_name, "mobilesubstrate") != NULL
        || strstr(service_name, "libhooker") != NULL
        || strstr(service_name, "preferencebundles") != NULL
        || strstr(service_name, "safe.mode") != NULL
        || strstr(service_name, "zygote") != NULL
        || strstr(service_name, "frida") != NULL
        || strstr(service_name, "debugserver") != NULL
        || strstr(service_name, "lldb") != NULL
        || strstr(service_name, "gdb") != NULL
        || strstr(service_name, "pspawn_hook") != NULL
        || strstr(service_name, "org.coolstar.launchd") == service_name)
        {
            return BOOTSTRAP_UNKNOWN_SERVICE;
        }
    }

    return original_bootstrap_check_in(bp, service_name, sp);
}


static kern_return_t (*original_bootstrap_look_up)(mach_port_t bp, const char* service_name, mach_port_t* sp);
static kern_return_t replaced_bootstrap_look_up(mach_port_t bp, const char* service_name, mach_port_t* sp) 
{
    if(!is_caller_tweak() && service_name) 
    {
        if(strstr(service_name, "cy:") == service_name
        || strstr(service_name, "lh:") == service_name
        || strstr(service_name, "rbs:") == service_name
        || strstr(service_name, "org.coolstar") == service_name
        || strstr(service_name, "com.ex") == service_name
        || strstr(service_name, "com.saurik") == service_name
        || strstr(service_name, "com.opa334") == service_name
        || strstr(service_name, "me.jjolano") == service_name
        || strstr(service_name, "jailbreakd") != NULL
        || strstr(service_name, "xyz.willy") == service_name
        || strstr(service_name, "com.ichitaso") == service_name
        || strstr(service_name, "net.limneos") == service_name
        || strstr(service_name, "com.level3tjg") == service_name
        || strstr(service_name, "org.thebigboss") == service_name
        || strstr(service_name, "amfid") != NULL
        || strstr(service_name, "substrated") != NULL
        || strstr(service_name, "mobilesubstrate") != NULL
        || strstr(service_name, "libhooker") != NULL
        || strstr(service_name, "preferencebundles") != NULL
        || strstr(service_name, "safe.mode") != NULL
        || strstr(service_name, "zygote") != NULL
        || strstr(service_name, "frida") != NULL
        || strstr(service_name, "debugserver") != NULL
        || strstr(service_name, "lldb") != NULL
        || strstr(service_name, "gdb") != NULL
        || strstr(service_name, "pspawn_hook") != NULL
        || strstr(service_name, "org.coolstar.launchd") == service_name)
        {
            return BOOTSTRAP_UNKNOWN_SERVICE;
        }
    }

    return original_bootstrap_look_up(bp, service_name, sp);
}


%ctor
{
  c_hook("bootstrap_check_in", (void *)replaced_bootstrap_check_in, (void **)&original_bootstrap_check_in);
  c_hook("bootstrap_look_up", (void *)replaced_bootstrap_look_up, (void **)&original_bootstrap_look_up);
}
