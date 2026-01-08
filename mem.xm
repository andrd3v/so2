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

static kern_return_t (*original_vm_region_64)(vm_map_read_t target_task, vm_address_t* address, vm_size_t* size, vm_region_flavor_t flavor, vm_region_info_t info, mach_msg_type_number_t* infoCnt, mach_port_t* object_name);
static kern_return_t replaced_vm_region_64(vm_map_read_t target_task, vm_address_t* address, vm_size_t* size, vm_region_flavor_t flavor, vm_region_info_t info, mach_msg_type_number_t* infoCnt, mach_port_t* object_name)
{
    kern_return_t result = original_vm_region_64(target_task, address, size, flavor, info, infoCnt, object_name);

    if(!is_caller_tweak() && result == KERN_SUCCESS && flavor != VM_REGION_TOP_INFO)
    {
        vm_region_basic_info_64_t rinfo = (vm_region_basic_info_64_t)info;

        if (rinfo->protection)
        {
            if (rinfo->protection & VM_PROT_EXECUTE)
            {
                rinfo->protection &= ~VM_PROT_WRITE;
            }
        }
    }

    return result;
}

static kern_return_t (*original_vm_region_recurse_64)(vm_map_read_t target_task, vm_address_t* address, vm_size_t* size, natural_t* nesting_depth, vm_region_recurse_info_t info, mach_msg_type_number_t* infoCnt);
static kern_return_t replaced_vm_region_recurse_64(vm_map_read_t target_task, vm_address_t* address, vm_size_t* size, natural_t* nesting_depth, vm_region_recurse_info_t info, mach_msg_type_number_t* infoCnt)
{
    kern_return_t result = original_vm_region_recurse_64(target_task, address, size, nesting_depth, info, infoCnt);

    if(!is_caller_tweak() && result == KERN_SUCCESS)
    {
        vm_region_basic_info_64_t rinfo = (vm_region_basic_info_64_t)info;

        if (rinfo->protection)
        {
            if (rinfo->protection & VM_PROT_EXECUTE)
            {
                rinfo->protection &= ~VM_PROT_WRITE;
            }
        }
        
    }

    return result;
}

__attribute__((constructor))
static void hook()
{
    c_hook("vm_region_64", (void *)replaced_vm_region_64, (void **)&original_vm_region_64);
    c_hook("vm_region_recurse_64", (void *)replaced_vm_region_recurse_64, (void **)&original_vm_region_recurse_64);
}
