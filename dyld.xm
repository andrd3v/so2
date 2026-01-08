//
//  dyld.mm
//  copsbp
//
//  Created by andr on 30.03.2025.
//

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

uint32_t dyldCount = 0;
char **dyldNames = 0;
struct mach_header **dyldHeaders = 0;
intptr_t *slides = 0;

extern char **environ;
static char **myEnviron = NULL;

struct mach_header* sanitize_header(struct mach_header* header)
{
    if (header == NULL)
        return NULL;

    int is_64 = 0;
    uint32_t magic = header->magic;

    if (magic == MH_MAGIC_64)
    {
        is_64 = 1;
    } else if (magic != MH_MAGIC)
    {
        return NULL;
    }

    uint32_t ncmds;
    uint32_t sizeofcmds;
    size_t header_size;

    if (is_64)
    {
        struct mach_header_64* hdr64 = (struct mach_header_64*)header;
        ncmds = hdr64->ncmds;
        sizeofcmds = hdr64->sizeofcmds;
        header_size = sizeof(struct mach_header_64);
    } else {
        ncmds = header->ncmds;
        sizeofcmds = header->sizeofcmds;
        header_size = sizeof(struct mach_header);
    }

    const uint8_t* start = (const uint8_t*)header + header_size;
    const uint8_t* end = start + sizeofcmds;
    const uint8_t* ptr = start;

    size_t full_size = header_size + sizeofcmds;
    uint8_t* new_memory = (uint8_t*)malloc(full_size);
    if (!new_memory) return NULL;

    memcpy(new_memory, header, header_size);

    uint8_t* dst = new_memory + header_size;
    uint32_t new_ncmds = 0;
    uint32_t new_sizeofcmds = 0;

    for (uint32_t i = 0; i < ncmds && ptr < end; i++)
    {
        if (end - ptr < sizeof(struct load_command))
        {
            break;
        }

        struct load_command* lcmd = (struct load_command*)ptr;
        
        if (lcmd->cmdsize < sizeof(struct load_command) ||
            (ptr + lcmd->cmdsize) > end) {
            break;
        }

        int copy_command = 1;

        switch (lcmd->cmd)
        {
            case LC_LOAD_DYLIB:
            case LC_LOAD_WEAK_DYLIB:
            case LC_REEXPORT_DYLIB:
            case LC_LAZY_LOAD_DYLIB:
            case LC_LOAD_UPWARD_DYLIB:
            {
                struct dylib_command* dylib_cmd = (struct dylib_command*)lcmd;
                
                if (dylib_cmd->dylib.name.offset >= lcmd->cmdsize)
                {
                    copy_command = 0;
                    break;
                }

                const char* name = (const char*)dylib_cmd + dylib_cmd->dylib.name.offset;
                
                size_t max_len = lcmd->cmdsize - dylib_cmd->dylib.name.offset;
                if (name >= (const char*)end || strnlen(name, max_len) >= max_len)
                {
                    copy_command = 0;
                } else if (is_hidden_dyld(name))
                {
                    copy_command = 0;
                }
                break;
            }
        }

        if (copy_command)
        {
            memcpy(dst, ptr, lcmd->cmdsize);
            dst += lcmd->cmdsize;
            new_sizeofcmds += lcmd->cmdsize;
            new_ncmds++;
        }

        ptr += lcmd->cmdsize;
    }

    if (is_64)
    {
        struct mach_header_64* new_hdr = (struct mach_header_64*)new_memory;
        new_hdr->ncmds = new_ncmds;
        new_hdr->sizeofcmds = new_sizeofcmds;
    } else {
        struct mach_header* new_hdr = (struct mach_header*)new_memory;
        new_hdr->ncmds = new_ncmds;
        new_hdr->sizeofcmds = new_sizeofcmds;
    }

    uint8_t* trimmed = (uint8_t*)realloc(new_memory, header_size + new_sizeofcmds);
    return (struct mach_header*)(trimmed ? trimmed : new_memory);
}

void syncDyldArray()
{
    uint32_t count = _dyld_image_count();
    uint32_t counter = 0;
    

    dyldNames = (char **) calloc(count, sizeof(char **));
    dyldHeaders = (struct mach_header **) calloc(count, sizeof(struct mach_header **));
    slides = static_cast<intptr_t *>(calloc(count, sizeof(*slides)));

    for (int i = 0; i < count; i++)
    {
        const char *charName = _dyld_get_image_name(i);
        if (!charName)
        {
            continue;
        }


        NSString *name = [NSString stringWithUTF8String: charName];
        if (!name)
        {
            continue;
        }

        NSString *lower = [name lowercaseString];
        if ([lower containsString:@"tweakinject"] ||
            [lower containsString:@"cephei"] ||
            [lower containsString:@"substrate"] ||
            [lower containsString:@"substitute"] ||
            [lower containsString:@"applist"] ||
            [lower containsString:@"rocketbootstrap"] ||
            [lower containsString:@"colorpicker"] ||
            [lower containsString:@"frida"] ||
            [lower containsString:@"procursus"] ||
            [lower containsString:@"ellekit"] ||
            [lower containsString:@"drugs"]
            )
            {
                continue;
            }

        if (is_hidden_dyld(charName))
        {
            continue;
        }

        uint32_t idx = counter++;
        
        dyldNames[idx] = strdup(charName);
        struct mach_header *orig = (struct mach_header *)_dyld_get_image_header(i);
        dyldHeaders[idx] = (struct mach_header *)sanitize_header(orig);
        //dyldHeaders[idx] = (struct mach_header *) _dyld_get_image_header(i);
        slides[idx] = _dyld_get_image_vmaddr_slide(i);
    }

    dyldCount = counter;
}

static uint32_t (*original_dyld_image_count)();
uint32_t my_dyld_image_count()
{
    if (is_caller_tweak())
    {
        return _dyld_image_count();
    }


    return dyldCount;
}

static const char *(*original_dyld_get_image_name)(uint32_t image_index);
const char *my_dyld_get_image_name(uint32_t image_index)
{
    if (is_caller_tweak())
    {
        return _dyld_get_image_name(image_index);
    }

    return dyldNames[image_index];
}

static struct mach_header *(*original_dyld_get_image_header)(uint32_t image_index);
const struct mach_header *my_dyld_get_image_header(uint32_t image_index)
{
    if (is_caller_tweak())
    {
        return _dyld_get_image_header(image_index);
    }
    
    return dyldHeaders[image_index];
}

static intptr_t (*original_dyld_get_image_vmaddr_slide)(uint32_t index);
intptr_t my_dyld_get_image_vmaddr_slide(uint32_t index)
{
    if (is_caller_tweak())
    {
        return _dyld_get_image_vmaddr_slide(index);
    }

    return slides[index];
}

static bool (*orig_dyld_shared_cache_contains_path)(const char* path);
bool my_dyld_shared_cache_contains_path(const char* path)
{
    
    if (is_caller_tweak())
    {
        return orig_dyld_shared_cache_contains_path(path);
    }
    
    
    if (is_hidden_dyld(path))
        return false;
    
    return orig_dyld_shared_cache_contains_path(path);
}


/*
static void* (*original_dlopen_internal)(const char* path, int mode, void* caller);
static void* replaced_dlopen_internal(const char* path, int mode, void* caller) 
{
    if (is_caller_tweak() || !path)
    {
        return original_dlopen_internal(path, mode, caller);
    }

    if (is_hidden_dyld(path))
    {
        return NULL;
    }

    return original_dlopen_internal(path, mode, caller);
}
*/


static void* (*original_dlsym)(void* handle, const char* symbol);
void* replaced_dlsym(void* handle, const char* symbol)
{
    if (is_caller_tweak())
    {
        return original_dlsym(handle, symbol);
    }


    if (is_hidden_sym(symbol))
    {
        return NULL;
    }
    
    void* addr = original_dlsym(handle, symbol);
    const char* dylib = find_dylib_for_addr(addr);
    if (dylib)
    {
        if (is_hidden_file(dylib))
        {
            return NULL;
        } else {
            return addr;
        }
    }

    return addr;
}


static int (*original_dladdr)(const void* addr, Dl_info* info);
int replaced_dladdr(const void* addr, Dl_info* info)
{
    int result = original_dladdr(addr, info);
    const char* dylib = find_dylib_for_addr(addr);
    if (dylib)
    {
        if (is_hidden_file(dylib))
        {
            if(info)
            {
                void* sym;
                do {
                    sym = dlsym(RTLD_NEXT, info->dli_sname);
                } while(sym && is_hidden_file(find_dylib_for_addr(sym)));
                
                if(sym) {
                    return original_dladdr(sym, info);
                } else {
                    info->dli_fname = _dyld_get_image_name(0);
                }
            }
        }
    }
    
    return result;
}


static void* (*original_dlopen)(const char * path, int mode);
void* my_dlopen(const char * path, int mode)
{

    if (is_caller_tweak())
    {
        return original_dlopen(path, mode);
    }
    
    if (path && is_hidden_dyld(path))
        return NULL;
    
    return original_dlopen(path, mode);
}

static bool (*original_dlopen_preflight)(const char* path);
bool my_dlopen_preflight(const char* path)
{

    if (is_caller_tweak())
    {
        return original_dlopen_preflight(path);
    }
    

    if (path && is_hidden_dyld(path))
        return false;
    
    return original_dlopen_preflight(path);
}



static kern_return_t (*original_task_info)(task_name_t target_task, task_flavor_t flavor, task_info_t task_info_out, mach_msg_type_number_t *task_info_outCnt);

size_t get_hidden_libraries_size()
{
    struct task_dyld_info dyld_info;
    mach_msg_type_number_t count = TASK_DYLD_INFO_COUNT;

    kern_return_t ret = task_info(mach_task_self(), TASK_DYLD_INFO, (task_info_t)&dyld_info, &count);
    if (ret != KERN_SUCCESS) {
        return 0;
    }

    struct dyld_all_image_infos *dyld_info_ptr = (struct dyld_all_image_infos *)dyld_info.all_image_info_addr;
    size_t hidden_libraries_size = 0;

    for (size_t i = 0; i < dyld_info_ptr->infoArrayCount; i++) {
        const char *charName = dyld_info_ptr->infoArray[i].imageFilePath;

        NSString *name = [NSString stringWithUTF8String:charName];
        if (!name) {
            continue;
        }

        NSString *lower = [name lowercaseString];

        if ([lower containsString:@"tweakinject"] ||
            [lower containsString:@"cephei"] ||
            [lower containsString:@"substrate"] ||
            [lower containsString:@"substitute"] ||
            [lower containsString:@"applist"] ||
            [lower containsString:@"rocketbootstrap"] ||
            [lower containsString:@"colorpicker"] ||
            [lower containsString:@"frida"] ||
            [lower containsString:@"flex"] ||
            [lower containsString:@"procursus"] ||
            [lower containsString:@"ellekit"] ||
            is_hidden_dyld(charName))
            {

            struct stat st;
            if (stat(charName, &st) == 0) {
                hidden_libraries_size += st.st_size;
            }
        }
    }

    return hidden_libraries_size;
}

kern_return_t my_task_info(task_name_t target_task, task_flavor_t flavor, task_info_t task_info_out, mach_msg_type_number_t *task_info_outCnt)
{

    if (is_caller_tweak())
    {
        return original_task_info(target_task, flavor, task_info_out, task_info_outCnt);
    }

    if (flavor == TASK_DYLD_INFO)
    {
        kern_return_t ret = original_task_info(target_task, flavor, task_info_out, task_info_outCnt);

        if (ret == KERN_SUCCESS)
        {
            struct task_dyld_info *task_info = (struct task_dyld_info *) task_info_out;
            struct dyld_all_image_infos *dyld_info = (struct dyld_all_image_infos *) task_info->all_image_info_addr;

            struct dyld_image_info *new_infoArray = (struct dyld_image_info *)malloc(dyld_info->infoArrayCount * sizeof(struct dyld_image_info));
            size_t new_info_count = 0;


            for (size_t i = 0; i < dyld_info->infoArrayCount; i++)
            {
                const char *charName = dyld_info->infoArray[i].imageFilePath;


                NSString *name = [NSString stringWithUTF8String: charName];
                if (!name)
                {
                    continue;
                }

                NSString *lower = [name lowercaseString];
                if ([lower containsString:@"tweakinject"] ||
                    [lower containsString:@"cephei"] ||
                    [lower containsString:@"substrate"] ||
                    [lower containsString:@"substitute"] ||
                    [lower containsString:@"applist"] ||
                    [lower containsString:@"rocketbootstrap"] ||
                    [lower containsString:@"colorpicker"] ||
                    [lower containsString:@"frida"] ||
                    [lower containsString:@"flex"] ||
                    [lower containsString:@"procursus"] ||
                    [lower containsString:@"ellekit"] ||
                    [lower containsString:@"drugs"]
                    )
                    {
                        continue;
                    }



                if (is_hidden_dyld(charName))
                    continue;


                new_infoArray[new_info_count++] = dyld_info->infoArray[i];
            }


            dyld_info->infoArray = new_infoArray;
            dyld_info->infoArrayCount = (uint32_t)new_info_count;
        }

        return ret;
    }



    

    
    if (flavor == TASK_BASIC_INFO_64)
    {
        kern_return_t ret = original_task_info(target_task, flavor, task_info_out, task_info_outCnt);

        if (ret == KERN_SUCCESS)
        {
            struct task_basic_info_64* task_info = (struct task_basic_info_64 *) task_info_out;

            vm_size_t hidden = (vm_size_t)get_hidden_libraries_size();
            hidden*=8;
            hidden+=1024*1024*2.1;

            task_info->virtual_size -= hidden;
            task_info->resident_size -= hidden;
        }

        return ret;
    }


    if (flavor == TASK_EXTMOD_INFO)
    {
        kern_return_t ret = original_task_info(target_task, flavor, task_info_out, task_info_outCnt);

        if (ret == KERN_SUCCESS)
        {
            struct task_extmod_info *task_info = (struct task_extmod_info *) task_info_out;
            vm_extmod_statistics_data_t extmod_statistics_;
            extmod_statistics_.task_for_pid_count = 0;
            extmod_statistics_.task_for_pid_caller_count = 0;
            extmod_statistics_.thread_creation_count = 0;
            extmod_statistics_.thread_creation_caller_count = 0;
            extmod_statistics_.thread_set_state_count = 0;
            extmod_statistics_.thread_set_state_caller_count = 0;
            task_info->extmod_statistics = extmod_statistics_;
        }

        return ret;
    }

    kern_return_t result = original_task_info(target_task, flavor, task_info_out, task_info_outCnt);

    return result;
}

pid_t (*orig_vfork)();
pid_t my_vfork()
{

    if (is_caller_tweak())
    {
        return orig_vfork();
    }

    return -1;
}

pid_t (*orig_fork)();
pid_t my_fork()
{

    if (is_caller_tweak())
    {
        return orig_fork();
    }

    return -1;
}

void copy_environ()
{
    int count = 0;
    for (char **e = environ; *e; e++)
    {
        count++;
    }

    myEnviron = (char **)malloc((count + 1) * sizeof(char *));
    if (!myEnviron) {
        perror("malloc");
        exit(EXIT_FAILURE);
    }

    int j = 0;
    for (int i = 0; i < count; i++)
    {
        if (strstr(environ[i], "DYLD_INSERT_LIBRARIES")) continue;
        myEnviron[j++] = strdup(environ[i]);
    }
    myEnviron[j] = NULL;
}

__attribute__((constructor))
static void hook()
{
    syncDyldArray();
    
    HOOK_C(my_dyld_image_count, _dyld_image_count);
    HOOK_C(my_dyld_get_image_name, _dyld_get_image_name);
    HOOK_C(my_dyld_get_image_header, _dyld_get_image_header);
    HOOK_C(my_dyld_get_image_vmaddr_slide, _dyld_get_image_vmaddr_slide);
    
    c_hook("_dyld_shared_cache_contains_path", (void *)my_dyld_shared_cache_contains_path, (void **)&orig_dyld_shared_cache_contains_path);
    c_hook("dlopen", (void *)my_dlopen, (void **)&original_dlopen);
    c_hook("dlopen_preflight", (void *)my_dlopen_preflight, (void **)&original_dlopen_preflight);
    c_hook("task_info", (void *)my_task_info, (void **)&original_task_info);
    c_hook("dlsym", (void *)replaced_dlsym, (void **)&original_dlsym);
    c_hook("dladdr", (void *)replaced_dladdr, (void **)&original_dladdr);
    c_hook("vfork", (void *)my_vfork, (void **)&orig_vfork);
    c_hook("fork", (void *)my_fork, (void **)&orig_fork);
    
    copy_environ();
    HOOK_C(myEnviron, environ);
    
    
    //HOOK_C(my_dyld_shared_cache_contains_path, _dyld_shared_cache_contains_path);
    
    //HOOK_C(my_dlopen, dlopen);
    //HOOK_C(my_dlopen_preflight, dlopen_preflight);
    //HOOK_C(my_task_info, task_info);
    //HOOK_C(replaced_dlsym, dlsym);
    //HOOK_C(replaced_dladdr, dladdr);
    //HOOK_C(my_vfork, vfork);
    //HOOK_C(my_fork, fork);


    
    //ВАЖНО, HOOK_C СРАБОТАЕТ ТОЛЬКО ЕСЛИ БИБЛИОТЕКА ЗАПУСКАЕТСЯ С DYLD_INSERT_LIBRARIES=вашабиблиотка.dylib ИЛИ КОГДА ВЫ ДОБАВИТЕ КОМАНДУ ЗАГРУЗКИ ВАШЕЙ .dylib (LC_LOAD_DYLIB), НАПРИМЕР ЧЕРЕЗ УТИЛИТУ
    //insert_dylib @executable_path/libhook.dylib имя_бинаря имя_бинаря
    
    //c_hook("_dyld_image_count", (void *)my_dyld_image_count, (void **)&original_dyld_image_count);
    //c_hook("_dyld_get_image_name", (void *)my_dyld_get_image_name, (void **)&original_dyld_get_image_name);
    //c_hook("_dyld_get_image_header", (void *)my_dyld_get_image_header, (void **)&original_dyld_get_image_header);
    //c_hook("_dyld_get_image_vmaddr_slide", (void *)my_dyld_get_image_vmaddr_slide, (void **)&original_dyld_get_image_vmaddr_slide);
    //c_hook("_dyld_shared_cache_contains_path", (void *)my_dyld_shared_cache_contains_path, (void **)&orig_dyld_shared_cache_contains_path);
}
