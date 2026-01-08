//
//  debug.mm
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

#define PT_DENY_ATTACH 31

static pid_t (*original_getppid)();
pid_t my_getppid()
{
    if (is_caller_tweak())
    {
        return original_getppid();
    }

    return 1;
}


static int (*original_sysctl)(int *name, u_int namelen, void *old, size_t *oldlenp, void *newp, size_t newlen);
int my_sysctl(int *name, u_int namelen, void *old, size_t *oldlenp, void *newp, size_t newlen)
{

    if (is_caller_tweak())
    {
        return original_sysctl(name, namelen, old, oldlenp, newp, newlen);
    }

    int result = original_sysctl(name, namelen, old, oldlenp,newp,newlen);

    if (namelen >= 4 && name[0] == CTL_KERN && name[1] == KERN_PROC && name[2] == KERN_PROC_PID && old && oldlenp) 
    {
        struct kinfo_proc *info = (struct kinfo_proc *)old;
        if (*oldlenp >= sizeof(struct kinfo_proc)) 
        {
            if(info->kp_proc.p_flag  & P_TRACED) 
            {
                info->kp_proc.p_flag &= ~P_TRACED;
            }

            if(info->kp_proc.p_flag & P_SELECT) 
            {
                info->kp_proc.p_flag &= ~P_SELECT;
            }
        }
    }

    return result;
}

static int (*original_ptrace)(int _request, pid_t _pid, caddr_t _addr, int _data);
static int replaced_ptrace(int _request, pid_t _pid, caddr_t _addr, int _data) 
{
    if(_request == PT_DENY_ATTACH) 
    {
        return 0;
    }

    return original_ptrace(_request, _pid, _addr, _data);
}

__attribute__((constructor))
static void hook()
{
    //HOOK_C(my_getppid, getppid)
    //HOOK_C(my_sysctl, sysctl)


    c_hook("getppid", (void *)my_getppid, (void **)&original_getppid);
    c_hook("sysctl", (void *)my_sysctl, (void **)&original_sysctl);
    c_hook("ptrace", (void *)replaced_ptrace, (void **) &original_ptrace);
}
