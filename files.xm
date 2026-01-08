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

static char* _NSDirectoryEnumerator_shdw_key = "shdw";



@interface HidingDirectoryEnumerator : NSEnumerator
@property (nonatomic, strong) NSDirectoryEnumerator *originalEnumerator;
@property (nonatomic, copy) NSString *basePath;
@end

@implementation HidingDirectoryEnumerator

- (id)nextObject
{
    id obj = nil;

    while ((obj = [self.originalEnumerator nextObject]))
    {
        NSString *fullPath;

        if ([obj isKindOfClass:[NSString class]])
        {
            fullPath = [self.basePath stringByAppendingPathComponent:(NSString *)obj];
        } else if ([obj isKindOfClass:[NSURL class]])
        {
            fullPath = [(NSURL *)obj path];
        } else {
            continue;
        }

        if (!is_hidden_file(fullPath.UTF8String))
        {
            return obj;
        }
    }

    return nil;
}

- (NSDictionary *)fileAttributes
{
    return [self.originalEnumerator fileAttributes];
}

- (NSDictionary *)directoryAttributes
{
    return [self.originalEnumerator directoryAttributes];
}

@end

%hook NSFileHandle

+ (instancetype)fileHandleForReadingAtPath:(NSString *)path 
{

    if (is_caller_tweak())
    {
        return %orig;
    }

    if (is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }
    return %orig;
}

+ (instancetype)fileHandleForReadingFromURL:(NSURL *)url error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String];   

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        
        return nil;
    }
    
    return %orig;
}

+ (instancetype)fileHandleForWritingAtPath:(NSString *)path 
{

    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }
    
    return %orig;
}

+ (instancetype)fileHandleForWritingToURL:(NSURL *)url error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }


    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String];   

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        
        return nil;
    }
    
    return %orig;
}

+ (instancetype)fileHandleForUpdatingAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }
    
    return %orig;
}

+ (instancetype)fileHandleForUpdatingURL:(NSURL *)url error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String];   

    if(is_hidden_file(path)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        
        return nil;
    }
    
    return %orig;
}

%end

%hook NSData
+ (instancetype)dataWithContentsOfFile:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (instancetype)dataWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError * _Nullable *)errorPtr 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        if(errorPtr) 
        {
            *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

+ (instancetype)dataWithContentsOfURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path)) 
    {
        return nil;
    }

    return %orig;
}

+ (instancetype)dataWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError * _Nullable *)errorPtr 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path)) 
    {
        if(errorPtr) 
        {
            *errorPtr = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

- (instancetype)initWithContentsOfFile:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

- (instancetype)initWithContentsOfFile:(NSString *)path options:(NSDataReadingOptions)readOptionsMask error:(NSError * _Nullable *)errorPtr 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        if(errorPtr) 
        {
            *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    { 
        return nil;
    }

    return %orig;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url options:(NSDataReadingOptions)readOptionsMask error:(NSError * _Nullable *)errorPtr 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(errorPtr) 
        {
            *errorPtr = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

- (id)initWithContentsOfMappedFile:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (id)dataWithContentsOfMappedFile:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)writeToFile:(NSString *)path options:(NSDataWritingOptions)writeOptionsMask error:(NSError * _Nullable *)errorPtr 
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if(is_hidden_file(path.UTF8String)) 
    {
        if(errorPtr) 
        {
            *errorPtr = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileWriteUnknownError userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)writeToURL:(NSURL *)url options:(NSDataWritingOptions)writeOptionsMask error:(NSError * _Nullable *)errorPtr 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path)) 
    {
        if(errorPtr) 
        {
            *errorPtr = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

%end

%hook NSDirectoryEnumerator

- (NSArray *)allObjects 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *base = objc_getAssociatedObject(self, _NSDirectoryEnumerator_shdw_key);
    
    if (!base) 
    {
        base = @"";
    }
    
    NSArray *result = %orig;
    
    if (result) 
    {
        result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *filePath, NSDictionary *bindings) {
            return !is_hidden_file(filePath.UTF8String);
        }]];
    }
    
    return result;
}


- (id)nextObject 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString* base = objc_getAssociatedObject(self, _NSDirectoryEnumerator_shdw_key);

    if (!base) {
        base = @"";
    }

    id result = %orig; 

    while (result) 
    {
        NSString* path = nil;

        if ([result isKindOfClass:[NSURL class]]) 
        {
            path = [result path];
        } 
        else if ([result isKindOfClass:[NSString class]])
        {
            path = result; 
        }

        if (is_hidden_file(path.UTF8String)) 
        {
            result = %orig;
        } 
        else 
        {
            break;
        }
    }

    return result; 
}

%end

%hook NSFileManager

- (BOOL)fileExistsAtPath:(NSString *)path
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    BOOL result = %orig;

    if(result && is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return result;
}

- (BOOL)fileExistsAtPath:(NSString *)path isDirectory:(BOOL *)isDirectory 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    BOOL result = %orig;

    if(result && is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return result;
}

- (BOOL)isReadableFileAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    BOOL result = %orig;

    if(result && is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return result;
}

- (BOOL)isWritableFileAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    BOOL result = %orig;

    if(result && is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return result;
}

- (BOOL)isDeletableFileAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    BOOL result = %orig;

    if(result && is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return result;
}

- (BOOL)isExecutableFileAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    BOOL result = %orig;

    if(result && is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return result;
}

- (NSData *)contentsAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSData* result = %orig;

    if(result && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return result;
}

- (BOOL)contentsEqualAtPath:(NSString *)path1 andPath:(NSString *)path2 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if((is_hidden_file(path1.UTF8String) || is_hidden_file(path2.UTF8String))) 
    {
        return NO;
    }

    return %orig;
}

- (NSArray<NSURL *> *)contentsOfDirectoryAtURL:(NSURL *)url includingPropertiesForKeys:(NSArray<NSURLResourceKey> *)keys options:(NSDirectoryEnumerationOptions)mask error:(NSError * _Nullable *)error
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];
    const char *path = [urlString UTF8String];

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }
    
    NSArray* result = %orig;
    
    if (result) 
    {
        result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURL *fileURL, NSDictionary *bindings)
        {
            return !is_hidden_file(fileURL.path.UTF8String); 
        }]];
    }

    return result;
}

 - (NSArray<NSString *> *)contentsOfDirectoryAtPath:(NSString *)path error:(NSError * _Nullable *)error
 {
     if (is_caller_tweak())
     {
         return %orig;
     }

     if (is_hidden_file(path.UTF8String))
     {
         if (error)
         {
             *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
         }

         return nil;
     }

     NSArray<NSString *> *result = %orig;

     if (result)
     {
         result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *fileName, NSDictionary *bindings) {
             NSString *fullPath = [path stringByAppendingPathComponent:fileName];
             return !is_hidden_file(fullPath.UTF8String);
         }]];
     }

     return result;
 }
 
/*
- (NSDirectoryEnumerator<NSString *> *)enumeratorAtPath:(NSString *)path
{
    NSDirectoryEnumerator *origEnum = %orig;
    
    if (origEnum)
    {
        HidingDirectoryEnumerator *wrapper = [HidingDirectoryEnumerator new];
        wrapper.originalEnumerator = origEnum;
        wrapper.basePath = path;
        return (NSDirectoryEnumerator<NSString *> *)wrapper;
    }

    return nil;
}


- (NSDirectoryEnumerator<NSURL *> *)enumeratorAtURL:(NSURL *)url
                       includingPropertiesForKeys:(NSArray<NSURLResourceKey> *)keys
                                          options:(NSDirectoryEnumerationOptions)mask
                                     errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler
{
    NSDirectoryEnumerator *origEnum = %orig;

    if (origEnum)
    {
        HidingDirectoryEnumerator *wrapper = [HidingDirectoryEnumerator new];
        wrapper.originalEnumerator = origEnum;
        wrapper.basePath = url.path;
        return (NSDirectoryEnumerator<NSURL *> *)wrapper;
    }

    return nil;
}
*/
/*
//переписаны выше
- (NSDirectoryEnumerator<NSURL *> *)enumeratorAtURL:(NSURL *)url
                       includingPropertiesForKeys:(NSArray<NSURLResourceKey> *)keys
                                          options:(NSDirectoryEnumerationOptions)mask
                                     errorHandler:(BOOL (^)(NSURL *url, NSError *error))handler {
    NSDirectoryEnumerator *origEnum = %orig;
    if (origEnum) {

    }
    return origEnum;
}

- (NSDirectoryEnumerator<NSString *> *)enumeratorAtPath:(NSString *)path {
    NSDirectoryEnumerator* result = %orig;

    if(result) {
        objc_setAssociatedObject(result, _NSDirectoryEnumerator_shdw_key, path, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        NSLog(@"%@: %@", @"enumeratorAtPath", path);
    }
    
    return result;
}
 */

 - (NSArray<NSString *> *)subpathsOfDirectoryAtPath:(NSString *)path error:(NSError * _Nullable *)error
 {
     if (is_caller_tweak())
     {
         return %orig;
     }

     if (is_hidden_file(path.UTF8String))
     {
         if (error)
         {
             *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
         }

         return nil;
     }

     NSArray<NSString *> *result = %orig;

     if (result)
     {
         result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *relativePath, NSDictionary *bindings) {
             NSString *fullPath = [path stringByAppendingPathComponent:relativePath];
             return !is_hidden_file(fullPath.UTF8String);
         }]];
     }

     return result;
 }

- (NSArray<NSString *> *)subpathsAtPath:(NSString *)path
{
    if (is_caller_tweak())
    {
        return %orig;
    }

    if (is_hidden_file(path.UTF8String))
    {
        return nil;
    }

    NSArray<NSString *> *result = %orig;

    if (result)
    {
        result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSString *relativePath, NSDictionary *bindings) {
            NSString *fullPath = [path stringByAppendingPathComponent:relativePath];
            return !is_hidden_file(fullPath.UTF8String);
        }]];
    }

    return result;
}

- (void)getFileProviderServicesForItemAtURL:(NSURL *)url completionHandler:(void (^)(NSDictionary *services, NSError *error))completionHandler 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(completionHandler) 
        {
            completionHandler(nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]);
        }

        return;
    }

    %orig;
}
//-----------------------------------------
- (NSString *)destinationOfSymbolicLinkAtPath:(NSString *)path error:(NSError * _Nullable *)error
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    if (is_hidden_file(path.UTF8String)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        
        return nil;
    }

    NSArray *symlinksToCheck = @[
        @"/var/lib/undecimus/apt",
        @"/Applications",
        @"/Library/Ringtones",
        @"/Library/Wallpaper",
        @"/usr/arm-apple-darwin9",
        @"/usr/include",
        @"/usr/libexec",
        @"/usr/share"
    ];

    if ([symlinksToCheck containsObject:path]) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        
        return nil;
    }
    

    return %orig;
}

- (NSArray<NSString *> *)componentsToDisplayForPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

- (NSString *)displayNameAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString* result = %orig;

    if (is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return result;
}

- (NSDictionary<NSFileAttributeKey, id> *)attributesOfItemAtPath:(NSString *)path error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    if (is_hidden_file(path.UTF8String)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        
        return nil;
    }

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ----- Make sure rootfs is marked read-only -----
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    NSDictionary<NSFileAttributeKey, id>* result = %orig;

    if(result && (
        [path hasPrefix:@"/private/preboot"]
        || [path hasPrefix:@"/private/var"]
        || [path hasPrefix:@"/var"]
    )) 
    {
        NSMutableDictionary<NSFileAttributeKey, id>* result_filtered = [result mutableCopy];
        [result_filtered setObject:@(YES) forKey:NSFileAppendOnly];
        result = [result_filtered copy];
    }

    return result;
}

- (NSDictionary<NSFileAttributeKey, id> *)attributesOfFileSystemForPath:(NSString *)path error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        
        return nil;
    }

    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    // ----- Make sure rootfs is marked read-only -----
    //!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    NSDictionary<NSFileAttributeKey, id>* result = %orig;

    if(result && (
        [path hasPrefix:@"/private/preboot"]
        || [path hasPrefix:@"/private/var"]
        || [path hasPrefix:@"/var"]
    )) 
    {
        NSMutableDictionary<NSFileAttributeKey, id>* result_filtered = [result mutableCopy];
        [result_filtered setObject:@(YES) forKey:NSFileAppendOnly];
        result = [result_filtered copy];
    }

    return result;
}
//--------------------------------------
- (BOOL)getRelationship:(NSURLRelationship *)outRelationship ofDirectoryAtURL:(NSURL *)directoryURL toItemAtURL:(NSURL *)otherURL error:(NSError * _Nullable *)error
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [directoryURL absoluteString];  
    const char *path = [urlString UTF8String]; 

    NSString *urlString2 = [otherURL absoluteString];  
    const char *path2 = [urlString2 UTF8String]; 

    if(is_hidden_file(path) || is_hidden_file(path2))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        
        return NO;
    }

    return %orig;
}

- (BOOL)getRelationship:(NSURLRelationship *)outRelationship ofDirectory:(NSSearchPathDirectory)directory inDomain:(NSSearchPathDomainMask)domainMask toItemAtURL:(NSURL *)url error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        
        return NO;
    }

    return %orig;
}

- (BOOL)changeCurrentDirectoryPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (NSDictionary *)fileAttributesAtPath:(NSString *)path traverseLink:(BOOL)yorn 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

- (NSDictionary *)fileSystemAttributesAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    NSDictionary<NSFileAttributeKey, id>* result = %orig;

    if(result && (
        [path hasPrefix:@"/private/preboot"]
        || [path hasPrefix:@"/private/var"]
        || [path hasPrefix:@"/var"]
    )) 
    {
        NSMutableDictionary<NSFileAttributeKey, id>* result_filtered = [result mutableCopy];
        [result_filtered setObject:@(YES) forKey:NSFileAppendOnly];
        result = [result_filtered copy];
    }

    return result;
}

- (NSArray *)directoryContentsAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }
    
    NSArray* result = %orig;
    
    if (result) 
    {
        result = [result filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(NSURL *fileURL, NSDictionary *bindings)
        {
            return !is_hidden_file(fileURL.path.UTF8String); 
        }]];
    }

    return result;
}

- (NSString *)pathContentOfSymbolicLinkAtPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }
    
    return %orig;
}
//-------------------------------
- (BOOL)replaceItemAtURL:(NSURL *)originalItemURL withItemAtURL:(NSURL *)newItemURL backupItemName:(NSString *)backupItemName options:(NSFileManagerItemReplacementOptions)options resultingItemURL:(NSURL * _Nullable *)resultingURL error:(NSError * _Nullable *)error
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    NSString *urlString1 = [originalItemURL absoluteString];  
    const char *path1 = [urlString1 UTF8String]; 

    NSString *urlString2 = [newItemURL absoluteString];  
    const char *path2 = [urlString2 UTF8String]; 


    if (is_hidden_file(path1) || is_hidden_file(path2)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)copyItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    NSString *urlString1 = [srcURL absoluteString];  
    const char *path1 = [urlString1 UTF8String]; 

    NSString *urlString2 = [dstURL absoluteString];  
    const char *path2 = [urlString2 UTF8String]; 

    if (is_hidden_file(path1) || is_hidden_file(path2)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)copyItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    if (is_hidden_file(srcPath.UTF8String) || is_hidden_file(dstPath.UTF8String)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)moveItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString1 = [srcURL absoluteString];  
    const char *path1 = [urlString1 UTF8String]; 

    NSString *urlString2 = [dstURL absoluteString];  
    const char *path2 = [urlString2 UTF8String]; 

    if (is_hidden_file(path1) || is_hidden_file(path2)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)moveItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(srcPath.UTF8String) || is_hidden_file(dstPath.UTF8String)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)isUbiquitousItemAtURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    BOOL result = %orig;

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(result && is_hidden_file(path))
    {
        return NO;      
    }

    return result;
}

- (BOOL)setUbiquitous:(BOOL)flag itemAtURL:(NSURL *)url destinationURL:(NSURL *)destinationURL error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString1 = [url absoluteString];  
    const char *path1 = [urlString1 UTF8String]; 

    NSString *urlString2 = [destinationURL absoluteString];  
    const char *path2 = [urlString2 UTF8String]; 

    if (is_hidden_file(path1) || is_hidden_file(path2)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)startDownloadingUbiquitousItemAtURL:(NSURL *)url error:(NSError * _Nullable *)error
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)evictUbiquitousItemAtURL:(NSURL *)url error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (NSURL *)URLForPublishingUbiquitousItemAtURL:(NSURL *)url expirationDate:(NSDate * _Nullable *)outDate error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}
//------------------------------
- (BOOL)createSymbolicLinkAtURL:(NSURL *)url withDestinationURL:(NSURL *)destURL error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)createSymbolicLinkAtPath:(NSString *)path withDestinationPath:(NSString *)destPath error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)linkItemAtURL:(NSURL *)srcURL toURL:(NSURL *)dstURL error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString1 = [srcURL absoluteString];  
    const char *path1 = [urlString1 UTF8String]; 

    NSString *urlString2 = [dstURL absoluteString];  
    const char *path2 = [urlString2 UTF8String]; 

    if (is_hidden_file(path1) || is_hidden_file(path2)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)linkItemAtPath:(NSString *)srcPath toPath:(NSString *)dstPath error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(srcPath.UTF8String) || is_hidden_file(dstPath.UTF8String)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)copyPath:(NSString *)src toPath:(NSString *)dest handler:(id)handler 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(src.UTF8String) || is_hidden_file(dest.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)movePath:(NSString *)src toPath:(NSString *)dest handler:(id)handler 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(src.UTF8String) || is_hidden_file(dest.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)removeFileAtPath:(NSString *)path handler:(id)handler 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)changeFileAttributes:(NSDictionary *)attributes atPath:(NSString *)path 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)linkPath:(NSString *)src toPath:(NSString *)dest handler:(id)handler 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if (is_hidden_file(src.UTF8String) || is_hidden_file(dest.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)createDirectoryAtURL:(NSURL *)url withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary<NSFileAttributeKey, id> *)attributes error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)createDirectoryAtPath:(NSString *)path withIntermediateDirectories:(BOOL)createIntermediates attributes:(NSDictionary<NSFileAttributeKey, id> *)attributes error:(NSError * _Nullable *)error
{

    if (is_caller_tweak())
    {
        return %orig;
    }
    

    if(is_hidden_file(path.UTF8String))
    {

        if(error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)createFileAtPath:(NSString *)path contents:(NSData *)data attributes:(NSDictionary<NSFileAttributeKey, id> *)attr
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if(is_hidden_file(path.UTF8String))
    {
        return NO;
    }


    return %orig;
}

- (BOOL)removeItemAtURL:(NSURL *)URL error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [URL absoluteString];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)removeItemAtPath:(NSString *)path error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    if(is_hidden_file(path.UTF8String))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)trashItemAtURL:(NSURL *)url resultingItemURL:(NSURL * _Nullable *)outResultingURL error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}
%end

%hook NSFileVersion
+ (NSFileVersion *)currentVersionOfItemAtURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

+ (NSArray<NSFileVersion *> *)otherVersionsOfItemAtURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

+ (NSFileVersion *)versionOfItemAtURL:(NSURL *)url forPersistentIdentifier:(id)persistentIdentifier 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

+ (NSURL *)temporaryDirectoryURLForNewVersionOfItemAtURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

+ (NSFileVersion *)addVersionOfItemAtURL:(NSURL *)url withContentsOfURL:(NSURL *)contentsURL options:(NSFileVersionAddingOptions)options error:(NSError * _Nullable *)outError 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString1 = [url absoluteString];  
    const char *path1 = [urlString1 UTF8String]; 

    NSString *urlString2 = [contentsURL absoluteString];  
    const char *path2 = [urlString2 UTF8String]; 

    if (is_hidden_file(path1) || is_hidden_file(path2)) 
    {
        if(outError) 
        {
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

+ (NSArray<NSFileVersion *> *)unresolvedConflictVersionsOfItemAtURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

- (NSURL *)replaceItemAtURL:(NSURL *)url options:(NSFileVersionReplacingOptions)options error:(NSError * _Nullable *)error 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

+ (BOOL)removeOtherVersionsOfItemAtURL:(NSURL *)url error:(NSError * _Nullable *)outError 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return NO;
    }

    return %orig;
}

+ (void)getNonlocalVersionsOfItemAtURL:(NSURL *)url completionHandler:(void (^)(NSArray<NSFileVersion *> *nonlocalFileVersions, NSError *error))completionHandler 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(completionHandler) 
        {
            completionHandler(nil, [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil]);
        }

        return;
    }

    %orig;
}
%end

%hook NSFileWrapper
- (instancetype)initWithURL:(NSURL *)url options:(NSFileWrapperReadingOptions)options error:(NSError * _Nullable *)outError 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    

    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(outError) 
        {
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return 0;
    }

    return %orig;
}

- (instancetype)initSymbolicLinkWithDestinationURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return 0;
    }

    return %orig;
}

- (BOOL)matchesContentsOfURL:(NSURL *)url 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        return NO;
    }

    return %orig;
}

- (BOOL)readFromURL:(NSURL *)url options:(NSFileWrapperReadingOptions)options error:(NSError * _Nullable *)outError 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(outError) 
        {
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)writeToURL:(NSURL *)url options:(NSFileWrapperWritingOptions)options originalContentsURL:(NSURL *)originalContentsURL error:(NSError * _Nullable *)outError 
{
    if (is_caller_tweak())
    {
        return %orig;
    }
    
    NSString *urlString = [url path];  
    const char *path = [urlString UTF8String]; 

    if(is_hidden_file(path))
    {
        if(outError) 
        {
            *outError = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}
%end

int fpath(int fd, char *path, size_t path_size)
{
    char fd_path[64];
    snprintf(fd_path, sizeof(fd_path), "/proc/self/fd/%d", fd);
    
    ssize_t len = readlink(fd_path, path, path_size - 1);
    if (len == -1)
        return -1;

    path[len] = '\0';  
    return 0;
}


static FILE* (*original_fopen)(const char* path, const char* mode);
FILE* my_fopen(const char* path, const char* mode)
{
    if (is_caller_tweak())
    {
        return original_fopen(path, mode);
    }
    
    if (is_hidden_file(path))
        return nullptr;
    return original_fopen(path, mode);
}

static int (*original_open)(const char *path, int flags, mode_t mode);
int my_open(const char *path, int flags, mode_t mode)
{
    if (is_caller_tweak())
    {
    return original_open(path, flags, mode);
    }

    if (is_hidden_file(path))
        return -1;
    return original_open(path, flags, mode);
}

static FILE* (*original_freopen)(const char* path, const char* mode, FILE* stream);
FILE* my_freopen(const char* path, const char* mode, FILE* stream)
{
    if (is_caller_tweak())
    {
        return original_freopen(path, mode, stream);
    }

    if (is_hidden_file(path))
        return nullptr;
    return original_freopen(path, mode, stream);
}

static int (*original_access)(const char* path, int mode);
int my_access(const char* path, int mode)
{
    if (is_caller_tweak())
    {
        return original_access(path, mode);
    }

    if (is_hidden_file(path))
        return -1;
    return original_access(path, mode);
}

static int (*original_openat)(int dirfd, const char *path, int flags, mode_t mode);
int my_openat(int dirfd, const char *path, int flags, mode_t mode)
{
    if (is_caller_tweak())
    {
        return original_openat(dirfd, path, flags, mode);
    }

    if (is_hidden_file(path))
        return -1;
    return original_openat(dirfd, path, flags, mode);
}

static void* (*original_mmap)(void* addr, size_t length, int prot, int flags, int fd, off_t offset);
void* my_mmap(void* addr, size_t length, int prot, int flags, int fd, off_t offset)
{
    if (is_caller_tweak())
    {
        return original_mmap(addr, length, prot, flags, fd, offset);
    }

    if (fd >= 0) {
        char path[256];
        if (fpath(fd, path, sizeof(path)) != -1 && is_hidden_file(path))
            return MAP_FAILED;
    }
    return original_mmap(addr, length, prot, flags, fd, offset);
}

__attribute__((constructor))
static void hook()
{
    /*
    HOOK_C(my_fopen, fopen)
    HOOK_C(my_open, open)
    HOOK_C(my_freopen, freopen)
    HOOK_C(my_access, access)
    HOOK_C(my_openat, openat)
    HOOK_C(my_mmap, mmap)
    */

    c_hook("fopen", (void *)my_fopen, (void **)&original_fopen);
    c_hook("open", (void *)my_open, (void **)&original_open);
    c_hook("freopen", (void *)my_freopen, (void **)&original_freopen);
    c_hook("access", (void *)my_access, (void **)&original_access);
    c_hook("openat", (void *)my_openat, (void **)&original_openat);
    c_hook("mmap", (void *)my_mmap, (void **)&original_mmap);
}
