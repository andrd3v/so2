#pragma clang diagnostic ignored "-Wdeprecated-declarations"

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
#import "fishhook.h"

#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <string.h>

#include <sys/syscall.h>
#import <sys/sysctl.h>

#define PT_DENY_ATTACH 31

/* code signing attributes of a process */
#define CS_VALID                    0x00000001  /* dynamically valid */
#define CS_ADHOC                    0x00000002  /* ad hoc signed */
#define CS_GET_TASK_ALLOW           0x00000004  /* has get-task-allow entitlement */
#define CS_INSTALLER                0x00000008  /* has installer entitlement */

#define CS_FORCED_LV                0x00000010  /* Library Validation required by Hardened System Policy */
#define CS_INVALID_ALLOWED          0x00000020  /* (macOS Only) Page invalidation allowed by task port policy */

#define CS_HARD                     0x00000100  /* don't load invalid pages */
#define CS_KILL                     0x00000200  /* kill process if it becomes invalid */
#define CS_CHECK_EXPIRATION         0x00000400  /* force expiration checking */
#define CS_RESTRICT                 0x00000800  /* tell dyld to treat restricted */

#define CS_ENFORCEMENT              0x00001000  /* require enforcement */
#define CS_REQUIRE_LV               0x00002000  /* require library validation */
#define CS_ENTITLEMENTS_VALIDATED   0x00004000  /* code signature permits restricted entitlements */
#define CS_NVRAM_UNRESTRICTED       0x00008000  /* has com.apple.rootless.restricted-nvram-variables.heritable entitlement */

#define CS_RUNTIME                  0x00010000  /* Apply hardened runtime policies */
#define CS_LINKER_SIGNED            0x00020000  /* Automatically signed by the linker */

#define CS_ALLOWED_MACHO            (CS_ADHOC | CS_HARD | CS_KILL | CS_CHECK_EXPIRATION | \
                                 CS_RESTRICT | CS_ENFORCEMENT | CS_REQUIRE_LV | CS_RUNTIME | CS_LINKER_SIGNED)

#define CS_EXEC_SET_HARD            0x00100000  /* set CS_HARD on any exec'ed process */
#define CS_EXEC_SET_KILL            0x00200000  /* set CS_KILL on any exec'ed process */
#define CS_EXEC_SET_ENFORCEMENT     0x00400000  /* set CS_ENFORCEMENT on any exec'ed process */
#define CS_EXEC_INHERIT_SIP         0x00800000  /* set CS_INSTALLER on any exec'ed process */

#define CS_KILLED                   0x01000000  /* was killed by kernel for invalidity */
#define CS_NO_UNTRUSTED_HELPERS     0x02000000  /* kernel did not load a non-platform-binary dyld or Rosetta runtime */
#define CS_DYLD_PLATFORM            CS_NO_UNTRUSTED_HELPERS /* old name */
#define CS_PLATFORM_BINARY          0x04000000  /* this is a platform binary */
#define CS_PLATFORM_PATH            0x08000000  /* platform binary by the fact of path (osx only) */

#define CS_DEBUGGED                 0x10000000  /* process is currently or has previously been debugged and allowed to run with invalid pages */
#define CS_SIGNED                   0x20000000  /* process has a signature (may have gone invalid) */
#define CS_DEV_CODE                 0x40000000  /* code is dev signed, cannot be loaded into prod signed code (will go away with rdar://problem/28322552) */
#define CS_DATAVAULT_CONTROLLER     0x80000000  /* has Data Vault controller entitlement */

#define CS_ENTITLEMENT_FLAGS        (CS_GET_TASK_ALLOW | CS_INSTALLER | CS_DATAVAULT_CONTROLLER | CS_NVRAM_UNRESTRICTED)

/* executable segment flags */

#define CS_EXECSEG_MAIN_BINARY          0x1             /* executable segment denotes main binary */
#define CS_EXECSEG_ALLOW_UNSIGNED       0x10            /* allow unsigned pages (for debugging) */
#define CS_EXECSEG_DEBUGGER             0x20            /* main binary is debugger */
#define CS_EXECSEG_JIT                  0x40            /* JIT enabled */
#define CS_EXECSEG_SKIP_LV              0x80            /* OBSOLETE: skip library validation */
#define CS_EXECSEG_CAN_LOAD_CDHASH      0x100           /* can bless cdhash for execution */
#define CS_EXECSEG_CAN_EXEC_CDHASH      0x200           /* can execute blessed cdhash */

#define    CS_VALID        0x0000001    /* dynamically valid */
#define CS_ADHOC        0x0000002    /* ad hoc signed */
#define CS_GET_TASK_ALLOW    0x0000004    /* has get-task-allow entitlement */
#define CS_INSTALLER        0x0000008    /* has installer entitlement */

#define    CS_HARD            0x0000100    /* don't load invalid pages */
#define    CS_KILL            0x0000200    /* kill process if it becomes invalid */
#define CS_CHECK_EXPIRATION    0x0000400    /* force expiration checking */
#define CS_RESTRICT        0x0000800    /* tell dyld to treat restricted */
#define CS_ENFORCEMENT        0x0001000    /* require enforcement */
#define CS_REQUIRE_LV        0x0002000    /* require library validation */
#define CS_ENTITLEMENTS_VALIDATED    0x0004000

#define    CS_ALLOWED_MACHO    0x00ffffe

#define CS_EXEC_SET_HARD    0x0100000    /* set CS_HARD on any exec'ed process */
#define CS_EXEC_SET_KILL    0x0200000    /* set CS_KILL on any exec'ed process */
#define CS_EXEC_SET_ENFORCEMENT    0x0400000    /* set CS_ENFORCEMENT on any exec'ed process */
#define CS_EXEC_SET_INSTALLER    0x0800000    /* set CS_INSTALLER on any exec'ed process */

#define CS_KILLED        0x1000000    /* was killed by kernel for invalidity */
#define CS_DYLD_PLATFORM    0x2000000    /* dyld used to load this is a platform binary */
#define CS_PLATFORM_BINARY    0x4000000    /* this is a platform binary */
#define CS_PLATFORM_PATH    0x8000000    /* platform binary by the fact of path (osx only) */

/* csops  operations */
#define CS_OPS_STATUS       0   /* return status */
#define CS_OPS_MARKINVALID  1   /* invalidate process */
#define CS_OPS_MARKHARD     2   /* set HARD flag */
#define CS_OPS_MARKKILL     3   /* set KILL flag (sticky) */
#define CS_OPS_PIDPATH      4   /* get executable's pathname */
#define CS_OPS_CDHASH       5   /* get code directory hash */
#define CS_OPS_PIDOFFSET    6   /* get offset of active Mach-o slice */
#define CS_OPS_ENTITLEMENTS_BLOB 7  /* get entitlements blob */
#define CS_OPS_MARKRESTRICT 8   /* set RESTRICT flag (sticky) */
#define CS_OPS_SET_STATUS       9       /* set codesign flags */
#define CS_OPS_BLOB             10      /* get codesign blob */
#define CS_OPS_IDENTITY         11      /* get codesign identity */
#define CS_OPS_CLEARINSTALLER   12      /* clear INSTALLER flag */
#define CS_OPS_CLEARPLATFORM 13 /* clear platform binary status (DEVELOPMENT-only) */
#define CS_OPS_TEAMID       14  /* get team id */
#define CS_OPS_CLEAR_LV     15  /* clear the library validation flag */

#define CS_MAX_TEAMID_LEN       64

static int (*original_syscall)(int number, ...);
static int replaced_syscall(int number, ...)
{

	va_list args;
	va_start(args, number);

    void* stack[8];
    memcpy(stack, args, sizeof(stack));

    if(!is_caller_tweak())
    {
        if(number == SYS_open
        || number == SYS_chdir
        || number == SYS_access
        || number == SYS_execve
        || number == SYS_chroot
        || number == SYS_rmdir
        || number == SYS_stat
        || number == SYS_lstat
        || number == SYS_getattrlist
        || number == SYS_open_extended
        || number == SYS_stat_extended
        || number == SYS_lstat_extended
        || number == SYS_access_extended
        || number == SYS_stat64
        || number == SYS_lstat64
        || number == SYS_stat64_extended
        || number == SYS_lstat64_extended
        || number == SYS_readlink
        || number == SYS_pathconf)
        {
            const char* pathname = va_arg(args, const char *);

            if(is_hidden_file(pathname))
            {
                errno = ENOENT;
                return -1;
            }
        }
    }

    // Handle ptrace (anti debug)
    if(number == SYS_ptrace)
    {
        int _request = va_arg(args, int);

        if(_request == PT_DENY_ATTACH)
        {
            return 0;
        }
    }

    va_end(args);

    return original_syscall(number, stack[0], stack[1], stack[2], stack[3], stack[4], stack[5], stack[6], stack[7]);
}

static int (*original_csops)(pid_t pid, unsigned int ops, void* useraddr, size_t usersize);
static int replaced_csops(pid_t pid, unsigned int ops, void* useraddr, size_t usersize)
{
    int ret = original_csops(pid, ops, useraddr, usersize);

    if(!is_caller_tweak() && pid == getpid())
    {
        if(ops == CS_OPS_STATUS)
        {
            // (Un)set some flags
            ret &= ~CS_PLATFORM_BINARY;
            ret &= ~CS_GET_TASK_ALLOW;
            ret &= ~CS_INSTALLER;
            ret &= ~CS_ENTITLEMENTS_VALIDATED;
            ret |= 0x0000300; /* CS_JIT_ALLOW */
            ret |= CS_REQUIRE_LV;
        }

        /*
        if(ops == CS_OPS_CDHASH)
        {
            // Hide CDHASH for trustcache checks
            errno = EBADEXEC;
            return -1;
        }*/

        if(ops == CS_OPS_MARKKILL)
        {
            errno = EBADEXEC;
            return -1;
        }
        /*
        if (ops == CS_OPS_IDENTITY) {
            NSLog(@"andrdevv [csops] CS_OPS_IDENTITY: usersize=%zu", usersize);
            
            if (useraddr && usersize > 0) {
                char buf[512] = {0};
                size_t copy_len = MIN(usersize, sizeof(buf) - 1);
                memcpy(buf, useraddr, copy_len);
                NSLog(@"andrdevv [csops] identity content: %s", buf);
            }
        }

        if (ops == CS_OPS_TEAMID) {
            NSLog(@"andrdevv [csops] CS_OPS_TEAMID: usersize=%zu", usersize);

            if (useraddr && usersize > 0) {
                char buf[128] = {0};
                size_t copy_len = MIN(usersize, sizeof(buf) - 1);
                memcpy(buf, useraddr, copy_len);
                NSLog(@"andrdevv [csops] teamid content: %s", buf);
            }
        }
        
        */
    }

    return ret;
}

// todo: research on "supervised syscalls"
__attribute__((constructor))
static void hook()
{
    
    c_hook("csops", (void *)replaced_csops, (void **)&original_csops);
    c_hook("syscall", (void *)replaced_syscall, (void **)&original_syscall);

    // d4001001
    // const uint8_t bytes_svc80[] = {
    //     0x01, 0x10, 0x00, 0xd4
    // };

    // const uint8_t bytes_ret[] = {
    //     0xc0, 0x03, 0x5f, 0xd6
    // };
}
