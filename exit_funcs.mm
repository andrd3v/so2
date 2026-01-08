#import "helper.h"
#import <dlfcn.h>
#import <sys/sysctl.h>
#import <stdlib.h>
#import <mach-o/dyld.h>
#import <Foundation/Foundation.h>
#include <typeinfo>

// MARK: exit functions bypass

static void (*orig_abort)(void);
static void (*orig_exit)(int);
static void (*orig__exit)(int);
static void (*orig__Exit)(int);
static int (*orig_raise)(int);
static void (*orig_pthread_exit)(void *);
static void (*orig_objc_exception_throw)(id, SEL, id);
static void (*orig_cxa_throw)(void *, std::type_info *, void (*)(void *));


void my_abort(void) {}
void my_exit(int code) {}
void my__exit(int code) {}
void my__Exit(int code) {}
int my_raise(int sig) { return 0; }
void my_pthread_exit(void *value_ptr) {}
void my_objc_exception_throw(id self, SEL _cmd, id exception) {}
void my_cxa_throw(void *thrown_exception, std::type_info *tinfo, void (*dest)(void *)) {}


__attribute__((constructor))
static void init_hooks()
{
    c_hook("abort", (void *)my_abort, (void **)&orig_abort);
    c_hook("exit", (void *)my_exit, (void **)&orig_exit);
    c_hook("_exit", (void *)my__exit, (void **)&orig__exit);
    c_hook("raise", (void *)my_raise, (void **)&orig_raise);
    
    c_hook("pthread_exit", (void *)my_pthread_exit, (void **)&orig_pthread_exit);
    c_hook("objc_exception_throw", (void *)my_objc_exception_throw, (void **)&orig_objc_exception_throw);
    c_hook("__cxa_throw", (void *)my_cxa_throw, (void **)&orig_cxa_throw);

    signal(SIGABRT, SIG_IGN);
    signal(SIGSEGV, SIG_IGN);
    signal(SIGBUS,  SIG_IGN);
    signal(SIGILL,  SIG_IGN);
    signal(SIGFPE,  SIG_IGN);
    signal(SIGPIPE, SIG_IGN);
}
