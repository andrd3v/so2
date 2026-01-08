#if !defined(_DYLD_INTERPOSING_H_)
#define _DYLD_INTERPOSING_H_


#include <stdio.h>
#include <mach-o/dyld.h>
#include <stdlib.h>
#include "include/dyld_priv.h"

#define HOOK_C(_replacement,_replacee) \
__attribute__((used)) static struct{ const void* replacement; const void* replacee; } _interpose_##_replacee \
__attribute__ ((section ("__DATA_CONST,__interpose"))) = { (const void*)(unsigned long)&_replacement, (const void*)(unsigned long)&_replacee };


#endif

/*
#if !defined(_DYLD_INTERPOSING_H_)
#define _DYLD_INTERPOSING_H_


 
 #define HOOK_C(_replacement, _replacee) do { \
     static struct dyld_interpose_tuple interpose_tuple = { (const void*)(_replacement), (const void*)(_replacee) }; \
         dyld_dynamic_interpose(NULL, &interpose_tuple, 1); \
 } while(0)

 
#endif
*/
