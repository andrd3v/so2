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


%hook NSURL
- (BOOL)checkResourceIsReachableAndReturnError:(NSError * _Nullable *)error
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        if(error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}



- (BOOL)checkPromisedItemIsReachableAndReturnError:(NSError * _Nullable *)error
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        if(error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (BOOL)getPromisedItemResourceValue:(id  _Nullable *)value forKey:(NSURLResourceKey)key error:(NSError * _Nullable *)error
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        if(error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return NO;
    }

    return %orig;
}

- (NSDictionary<NSURLResourceKey, id> *)promisedItemResourceValuesForKeys:(NSArray<NSURLResourceKey> *)keys error:(NSError * _Nullable *)error
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))    {
        if(error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

- (NSURL *)fileReferenceURL
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

- (NSURL *)filePathURL
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

- (NSURL *)URLByResolvingSymlinksInPath
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

- (NSURL *)URLByStandardizingPath
{
    NSString *urlString = [self absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))
    {
        return nil;
    }

    return %orig;
}

+ (NSData *)bookmarkDataWithContentsOfURL:(NSURL *)bookmarkFileURL error:(NSError * _Nullable *)error
{
    NSString *urlString = [bookmarkFileURL absoluteString];
    const char *path = [urlString UTF8String];
    
    if(!is_caller_tweak() && is_hidden_file(path))    {
        if(error) {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}


%end
