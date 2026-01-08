#import <Foundation/Foundation.h>

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

#import <mach-o/dyld.h>
#include <mach/mach.h>

#import "fishhook.h"

#include <dlfcn.h>

static const char* MY_TWEAK_NAME = "copsik";
static const char* MY_APP_NAME = "CriticalOps";
static const char* MY_BUNDLEID_APP = "com.criticalforceentertainment.criticalops";

#define IS_JAIL 1
/*
#define is_caller_tweak() ({ \
    void *ret_addr = __builtin_extract_return_addr(__builtin_return_address(0)); \
    Dl_info info = {0}; \
    if (ret_addrs[i] && dladdr(ret_addrs[i], &info)) { \
        if (strstr(info.dli_fname, MY_TWEAK_NAME) != NULL) { \
            result = 1; \
            break; \
        } \
    } \
    result; \
})
*/

bool is_hidden_file(const char* name);
bool is_hidden_dyld(const char* charName);
bool is_hidden_sym(const char* sym);
bool is_addr_in_my_lib(const void* addr);
const char* find_dylib_for_addr(const void* addr);


#define is_caller_tweak() ({ \
    void *ret_addr = __builtin_extract_return_addr(__builtin_return_address(0)); \
    is_addr_in_my_lib(ret_addr); \
})


#define isCallerTweak() is_caller_tweak()


inline uintptr_t getRealOffset(uintptr_t addr)
{
  uint dylds_count = _dyld_image_count();
  for (int i = 0; i < dylds_count; i++)
  {
    const char* name = _dyld_get_image_name(i);
    if (!name) return 0;
    if (strstr(name, "UnityFramework"))
    {
        return _dyld_get_image_vmaddr_slide(i) + addr;
    }
  }
  return 0;
}



template <typename T>
struct monoArray
{
        void* klass;
        void* monitor;
        void* bounds;
        int   max_length;
        T vector[65535];

        T &operator [] (int i)
        {
            return vector[i];
        }

        const T &operator [] (int i) const
        {
            return vector[i];
        }

        bool Contains(T item)
        {
            for (int i = 0; i < max_length; i++)
            {
                    if(vector[i] == item) return true;
            }
            return false;
        }
};

template<typename T>
using Array = monoArray<T>;

typedef struct _monoString
{
    void* klass;
    void* monitor;
    int length;
    char chars[1];
    int getLength()
    {
      return length;
    }
    char* getChars()
    {
        return chars;
    }
    NSString* toNSString()
    {
      return [[NSString alloc] initWithBytes:(const void *)(chars)
                     length:(NSUInteger)(length * 2)
                     encoding:(NSStringEncoding)NSUTF16LittleEndianStringEncoding];
    }

    char* toCString()
    {
      NSString* v1 = toNSString();
      return (char*)([v1 UTF8String]);
    }
    std::string toCPPString()
    {
      return std::string(toCString());
    }
}monoString;

template<typename TKey, typename TValue>
struct Dictionary
{
    struct KeysCollection;
    struct ValueCollection;

    struct Entry
    {
        int hashCode;
        int next;
        TKey key;
        TValue value;
    };

    void *kass;
    void *monitor;
    Array<int> *buckets;
    Array<Entry> *entries;
    int count;
    int version;
    int freeList;
    int freeCount;
    void* comparer;
    KeysCollection *keys;
    ValueCollection *values;
    void *_syncRoot;

    void* get_Comparer()
    {
        return comparer;
    }

    int get_Count()
    {
        return count;
    }

    KeysCollection get_Keys()
    {
        if(!keys) keys = new KeysCollection(this);
        return (*keys);
    }

    ValueCollection get_Values()
    {
        if(!values) values = new ValueCollection(this);
        return (*values);
    }

    TValue operator [] (TKey key)
    {
        int i = FindEntry(key);
        if (i >= 0) return (*entries)[i].value;
        return TValue();
    }

    const TValue operator [] (TKey key) const
    {
        int i = FindEntry(key);
        if (i >= 0) return (*entries)[i].value;
        return TValue();
    }
    
    int FindEntry(TKey key)
    {
        for (int i = 0; i < count; i++)
        {
            if((*entries)[i].key == key) return i;
        }
        return -1;
    }
    
    bool ContainsKey(TKey key)
    {
        return FindEntry(key) >= 0;
    }
    
    bool ContainsValue(TValue value)
    {
        for (int i = 0; i < count; i++)
        {
            if((*entries)[i].hashCode >= 0 &&
                    (*entries)[i].value == value) return true;
        }
        return false;
    }

    bool TryGetValue(TKey key, TValue *value)
    {
        int i = FindEntry(key);
        if (i >= 0) {
            *value = (*entries)[i].value;
            return true;
        }
        *value = TValue();
        return false;
    }

    TValue GetValueOrDefault(TKey key)
    {
        int i = FindEntry(key);
        if (i >= 0) {
            return (*entries)[i].value;
        }
        return TValue();
    }

    struct KeysCollection
    {
        Dictionary *dictionary;

        KeysCollection(Dictionary *dictionary)
        {
            this->dictionary = dictionary;
        }

        TKey operator [] (int i)
        {
            auto entries = dictionary->entries;
            if(!entries) return TKey();
            return (*entries)[i].key;
        }

        const TKey operator [] (int i) const
        {
            auto entries = dictionary->entries;
            if(!entries) return TKey();
            return (*entries)[i].key;
        }

        int get_Count()
        {
            return dictionary->get_Count();
        }
    };

    struct ValueCollection
    {
        Dictionary *dictionary;

        ValueCollection(Dictionary *dictionary)
        {
            this->dictionary = dictionary;
        }

        TValue operator [] (int i)
        {
            auto entries = dictionary->entries;
            if(!entries) return TValue();
            return (*entries)[i].value;
        }

        const TValue operator [] (int i) const
        {
            auto entries = dictionary->entries;
            if(!entries) return TValue();
            return (*entries)[i].value;
        }

        int get_Count()
        {
            return dictionary->get_Count();
        }
    };
};
