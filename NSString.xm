#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

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

%hook NSString

- (instancetype)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError * _Nullable *)error
{
    if (!is_caller_tweak() && is_hidden_file(path.UTF8String))
    {
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

- (instancetype)initWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable *)error
{
    if (!is_caller_tweak() && is_hidden_file(path.UTF8String))
    {
        if (error) {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

+ (instancetype)stringWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)enc error:(NSError * _Nullable *)error
{
    if (!is_caller_tweak() && is_hidden_file(path.UTF8String))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

+ (instancetype)stringWithContentsOfFile:(NSString *)path usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable *)error
{
    if (!is_caller_tweak() && is_hidden_file(path.UTF8String))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileNoSuchFileError userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

+ (instancetype)stringWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError * _Nullable *)error
{
    NSString *urlString = [url path];
    const char *path = [urlString UTF8String];
    
    if (!is_caller_tweak() && is_hidden_file(path))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)enc error:(NSError * _Nullable *)error
{
    NSString *urlString = [url path];
    const char *path = [urlString UTF8String];
    
    if (!is_caller_tweak() && is_hidden_file(path))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

+ (instancetype)stringWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable *)error
{
    NSString *urlString = [url path];
    const char *path = [urlString UTF8String];
    
    if (!is_caller_tweak() && is_hidden_file(path))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

- (instancetype)initWithContentsOfURL:(NSURL *)url usedEncoding:(NSStringEncoding *)enc error:(NSError * _Nullable *)error
{
    NSString *urlString = [url path];
    const char *path = [urlString UTF8String];
    
    if (!is_caller_tweak() && is_hidden_file(path))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }
    return %orig;
}

- (NSUInteger)completePathIntoString:(NSString * _Nullable *)outputName caseSensitive:(BOOL)flag matchesIntoArray:(NSArray<NSString *> * _Nullable *)outputArray filterTypes:(NSArray<NSString *> *)filterTypes
{
    if (!is_caller_tweak() || !is_hidden_file(self.UTF8String))
    {
        return %orig;
    }

    NSUInteger result = %orig;

    if (result && (is_hidden_file(self.UTF8String) || (outputName && *outputName && is_hidden_file((*outputName).UTF8String))))
    {
        if (outputName) {
            *outputName = nil;
        }

        if (outputArray) {
            *outputArray = nil;
        }
        return 0;
    }

    return result;
}

- (NSString *)stringByResolvingSymlinksInPath
{
    NSString* result = %orig;

    if (!is_caller_tweak() && is_hidden_file(result.UTF8String))
    {
        return self;
    }

    return result;
}

- (NSString *)stringByStandardizingPath
{
    NSString* result = %orig;

    if (!is_caller_tweak() && is_hidden_file(result.UTF8String))
    {
        return self;
    }

    return result;
}

- (NSString *)stringByExpandingTildeInPath
{
    NSString *result = %orig;

    if (!is_caller_tweak() && is_hidden_file(result.UTF8String))
    {
        return self;
    }

    return result;
}

%end


%hook NSAttributedString

- (instancetype)initWithHTML:(NSData *)data baseURL:(NSURL *)base documentAttributes:(NSDictionary<NSAttributedStringDocumentAttributeKey, id> * _Nullable *)dict
{
    if (!is_caller_tweak() && is_hidden_file([base path].UTF8String))
    {
        return nil;
    }

    return %orig;
}

- (instancetype)initWithURL:(NSURL *)url options:(NSDictionary<NSAttributedStringDocumentReadingOptionKey, id> *)options documentAttributes:(NSDictionary<NSAttributedStringDocumentAttributeKey, id> * _Nullable *)dict error:(NSError * _Nullable *)error
{
    NSString *urlString = [url path];
    const char *path = [urlString UTF8String];

    if (!is_caller_tweak() && is_hidden_file(path))
    {
        if (error)
        {
            *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
        }
        return nil;
    }

    return %orig;
}

+ (void)loadFromHTMLWithFileURL:(NSURL *)fileURL options:(NSDictionary<NSAttributedStringDocumentReadingOptionKey, id> *)options completionHandler:(void (^)(NSAttributedString * _Nullable, NSDictionary<NSAttributedStringDocumentAttributeKey, id> * _Nullable, NSError * _Nullable))completionHandler
{
    NSString *urlString = [fileURL path];
    const char *path = [urlString UTF8String];

    if (!is_caller_tweak() && is_hidden_file(path))
    {
        if (completionHandler)
        {
            completionHandler(nil, nil, nil);
        }
        return;
    }

    %orig;
}

%end


%hook NSCharacterSet
+ (NSCharacterSet *)characterSetWithContentsOfFile:(NSString *)fName
{
    if(!is_caller_tweak() && is_hidden_file(fName.UTF8String))
    {
        return nil;
    }

    return %orig;
}
%end
