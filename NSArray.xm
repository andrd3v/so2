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


%hook NSArray
- (id)initWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfURL:(NSURL *)url 
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String];   


    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
        return nil;
    }

    return %orig;
}

- (NSArray *)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable *)error 
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String];   

    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

+ (NSArray *)arrayWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable *)error 
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String]; 

    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }

        return nil;
    }

    return %orig;
}

- (BOOL)writeToFile:(NSString *)path atomically:(BOOL)useAuxiliaryFile 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)writeToURL:(NSURL *)url atomically:(BOOL)atomically 
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String]; 

    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
        return NO;
    }

    return %orig;
}

- (BOOL)writeToURL:(NSURL *)url error:(NSError * _Nullable *)error
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String]; 

    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
        if(error) 
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorUnknown userInfo:nil];
        }

        return NO;
    }

    return %orig;
}
%end

%hook NSMutableArray
- (id)initWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

- (id)initWithContentsOfURL:(NSURL *)url 
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String]; 

    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (id)arrayWithContentsOfURL:(NSURL *)url 
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String]; 

    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
        return nil;
    }

    return %orig;
}
%end
