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

%hook NSDictionary
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

- (id)initWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable *)error 
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

+ (id)dictionaryWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (id)dictionaryWithContentsOfURL:(NSURL *)url error:(NSError * _Nullable *)error 
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

+ (id)dictionaryWithContentsOfURL:(NSURL *)url 
{
    NSString *urlString = [url absoluteString];  
    const char *path = [urlString UTF8String];   

    if(!is_caller_tweak() && is_hidden_file(path)) 
    {
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

%hook NSMutableDictionary
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

+ (NSMutableDictionary *)dictionaryWithContentsOfFile:(NSString *)path 
{
    if(!is_caller_tweak() && is_hidden_file(path.UTF8String)) 
    {
        return nil;
    }

    return %orig;
}

+ (NSMutableDictionary *)dictionaryWithContentsOfURL:(NSURL *)url 
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
