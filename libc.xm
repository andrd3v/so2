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

#include <sys/mount.h>
#include <sys/statvfs.h>
#include <dirent.h>

static int (*original_access)(const char* pathname, int mode);
static int replaced_access(const char* pathname, int mode) 
{
    int result = original_access(pathname, mode);

    if(result != -1 && !isCallerTweak() && is_hidden_file(pathname)) 
    {
        errno = ENOENT;
        return -1;
    }

    return result;
}

static ssize_t (*original_readlink)(const char* pathname, char* buf, size_t bufsize);
static ssize_t replaced_readlink(const char* pathname, char* buf, size_t bufsize) 
{
    ssize_t result = original_readlink(pathname, buf, bufsize);

    if(result != -1 && !isCallerTweak() && is_hidden_file(pathname)) 
    {
        errno = ENOENT;
        return -1;
    }

    return result;
}

static ssize_t (*original_readlinkat)(int dirfd, const char* pathname, char* buf, size_t bufsize);
static ssize_t replaced_readlinkat(int dirfd, const char* pathname, char* buf, size_t bufsize) 
{
    if (isCallerTweak()) 
    {
        return original_readlinkat(dirfd, pathname, buf, bufsize);
    }

    if (pathname != NULL) 
    {
        char fullPath[PATH_MAX];
        if (dirfd == AT_FDCWD) 
        {
            realpath(pathname, fullPath);
        } else {
            char dirPath[PATH_MAX];
            if (fcntl(dirfd, F_GETPATH, dirPath) != -1) 
            {
                snprintf(fullPath, sizeof(fullPath), "%s/%s", dirPath, pathname);
                realpath(fullPath, fullPath);
            } else {
                strncpy(fullPath, pathname, sizeof(fullPath));
                fullPath[sizeof(fullPath) - 1] = '\0';
            }
        }

        if (is_hidden_file(fullPath)) 
        {
            errno = ENOENT;
            return -1;
        }
    }

    return original_readlinkat(dirfd, pathname, buf, bufsize);
}

static int (*original_chdir)(const char* pathname);
static int replaced_chdir(const char* pathname) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_chdir(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_fchdir)(int fd);
static int replaced_fchdir(int fd) 
{
    if(isCallerTweak()) 
    {
        return original_fchdir(fd);
    }

    // Get file descriptor path.
    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && is_hidden_file(pathname)) 
        {
            errno = EBADF;
            return -1;
        }
    }

    return original_fchdir(fd);
}

static int (*original_chroot)(const char* pathname);
static int replaced_chroot(const char* pathname) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_chroot(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_creat)(const char* pathname, mode_t mode);
static int replaced_creat(const char* pathname, mode_t mode) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_creat(pathname, mode);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_getfsstat)(struct statfs* buf, int bufsize, int flags);
static int replaced_getfsstat(struct statfs* buf, int bufsize, int flags) 
{
    if(isCallerTweak()) 
    {
        return original_getfsstat(buf, bufsize, flags);
    }

    int result = original_getfsstat(buf, bufsize, flags);

    if(result != -1 && buf) 
    {
        struct statfs* buf_ptr = buf;
        struct statfs* buf_end = buf + sizeof(struct statfs) * result;

        while(buf_ptr < buf_end) 
        {

            if(is_hidden_file(buf_ptr->f_mntonname)) 
            {
                // handle bindfs/chroot
                strcpy(buf_ptr->f_mntonname, "/");
            }

            if(strcmp(buf_ptr->f_mntonname, "/") == 0) 
            {
                // Mark rootfs read-only
                buf_ptr->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
                break;
            }

            buf_ptr++;
        }
    }

    return result;
}

static int (*original_getmntinfo)(struct statfs** mntbufp, int flags);
static int replaced_getmntinfo(struct statfs** mntbufp, int flags) 
{
    if(isCallerTweak()) 
    {
        return original_getmntinfo(mntbufp, flags);
    }

    int result = original_getmntinfo(mntbufp, flags);

    if(result > 0) 
    {
        struct statfs** buf_ptr = mntbufp;
        struct statfs** buf_end = mntbufp + sizeof(struct statfs *) * result;

        while(buf_ptr < buf_end) 
        {

            if(is_hidden_file((*buf_ptr)->f_mntonname)) 
            {
                // handle bindfs/chroot
                strcpy((*buf_ptr)->f_mntonname, "/");
            }

            if(strcmp((*buf_ptr)->f_mntonname, "/") == 0) 
            {
                // Mark rootfs read-only
                (*buf_ptr)->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
                break;
            }

            buf_ptr++;
        }
    }

    return result;
}

static int (*original_statfs)(const char* pathname, struct statfs* buf);
static int replaced_statfs(const char* pathname, struct statfs* buf) 
{
    if(isCallerTweak()) 
    {
        return original_statfs(pathname, buf);
    }
    if(is_hidden_file(pathname)) 
    {
        errno = ENOENT;
        return -1;
    }

    int result = original_statfs(pathname, buf);


    if(result == 0) 
    {
        // Modify flags
        if(buf) {
            if(is_hidden_file(buf->f_mntonname)) 
            {
                // handle bindfs/chroot
                strcpy(buf->f_mntonname, "/");
            }

            if(strcmp(buf->f_mntonname, "/") == 0) 
            {
                // Mark rootfs read-only
                buf->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
            }
        }
    }

    return result;
}

static int (*original_fstatfs)(int fd, struct statfs* buf);
static int replaced_fstatfs(int fd, struct statfs* buf) 
{
    if(isCallerTweak()) 
    {
        return original_fstatfs(fd, buf);
    }

    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && is_hidden_file(pathname)) 
        {
            errno = EBADF;
            return -1;
        }
    }

    int result = original_fstatfs(fd, buf);

    if(result == 0) 
    {
        // Modify flags
        if(buf) 
        {
            if(is_hidden_file(buf->f_mntonname)) 
            {
                // handle bindfs/chroot
                strcpy(buf->f_mntonname, "/");
            }

            if(strcmp(buf->f_mntonname, "/") == 0) 
            {
                // Mark rootfs read-only
                buf->f_flags |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
            }
        }
    }

    return result;
}

static int (*original_statvfs)(const char* pathname, struct statvfs* buf);
static int replaced_statvfs(const char* pathname, struct statvfs* buf) 
{
    if(isCallerTweak()) 
    {
        return original_statvfs(pathname, buf);
    }

    if(is_hidden_file(pathname)) 
    {
        errno = ENOENT;
        return -1;
    }

    // use statfs to get f_mntonname
    struct statfs st;
    if(statfs(pathname, &st) == -1) 
    {
        memset(buf, 0, sizeof(struct statvfs));
        errno = ENOENT;
        return -1;
    }

    int result = original_statvfs(pathname, buf);

    if(result == 0) 
    {
        if(is_hidden_file(st.f_mntonname)) 
        {
            // handle bindfs/chroot
            strcpy(st.f_mntonname, "/");
        }
        
        if(strcmp(st.f_mntonname, "/") == 0) 
        {
            // Mark rootfs read-only
            buf->f_flag |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
        }
    }

    return result;
}

static int (*original_fstatvfs)(int fd, struct statvfs* buf);
static int replaced_fstatvfs(int fd, struct statvfs* buf) 
{
    if(isCallerTweak()) 
    {
        return original_fstatvfs(fd, buf);
    }

    // use fstatfs to get f_mntonname, replaced version for path checking
    struct statfs st;
    if(replaced_fstatfs(fd, &st) == -1) 
    {
        memset(buf, 0, sizeof(struct statvfs));
        errno = EBADF;
        return -1;
    }

    int result = original_fstatvfs(fd, buf);

    if(result == 0) 
    {
        if(is_hidden_file(st.f_mntonname)) 
        {
            // handle bindfs/chroot
            strcpy(st.f_mntonname, "/");
        }

        if(strcmp(st.f_mntonname, "/") == 0) 
        {
            // Mark rootfs read-only
            buf->f_flag |= MNT_RDONLY | MNT_ROOTFS | MNT_SNAPSHOT;
        }
    }

    return result;
}

static int (*original_stat)(const char* pathname, struct stat* buf);
static int replaced_stat(const char* pathname, struct stat* buf) 
{
    int result = original_stat(pathname, buf);

    if(result != -1 && !isCallerTweak() && is_hidden_file(pathname)) 
    {
        if(buf) 
        {
            memset(buf, 0, sizeof(struct stat));
        }
        
        errno = ENOENT;
        return -1;
    }

    return result;
}

static int (*original_lstat)(const char* pathname, struct stat* buf);
static int replaced_lstat(const char* pathname, struct stat* buf) 
{
    if(isCallerTweak()) 
    {
        return original_lstat(pathname, buf);
    }

    struct stat _buf;
    int result = original_lstat(pathname, &_buf);

    if(result == 0) 
    {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Only use resolve flag if target is not a symlink.
        if(is_hidden_file(pathname)) 
        {
            errno = ENOENT;
            return -1;
        }
    }

    if(buf) 
    {
        memcpy(buf, &_buf, sizeof(struct stat));
    }

    return result;
}

static int (*original_fstat)(int fd, struct stat* buf);
static int replaced_fstat(int fd, struct stat* buf) 
{
    if(isCallerTweak()) 
    {
        return original_fstat(fd, buf);
    }

    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && is_hidden_file(pathname)) 
        {
            errno = EBADF;
            return -1;
        }
    }

    return original_fstat(fd, buf);
}

static int (*original_fstatat)(int dirfd, const char* pathname, struct stat* buf, int flags);
static int replaced_fstatat(int dirfd, const char* pathname, struct stat* buf, int flags) 
{
    if(isCallerTweak()) 
    {
        return original_fstatat(dirfd, pathname, buf, flags);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) 
    {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) 
        {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }

        if(is_hidden_file(pathname)) 
        {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return original_fstatat(dirfd, pathname, buf, flags);
}

static int (*original_faccessat)(int dirfd, const char* pathname, int mode, int flags);
static int replaced_faccessat(int dirfd, const char* pathname, int mode, int flags) 
{
    if(isCallerTweak()) 
    {
        return original_faccessat(dirfd, pathname, mode, flags);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) 
    {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }

        if(is_hidden_file(pathname)) 
        {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return original_faccessat(dirfd, pathname, mode, flags);
}

// static int (*original_scandir)(const char* dirname, struct dirent*** namelist, int (*select)(struct dirent *), int (*compar)(const void *, const void *));
// static int replaced_scandir(const char* dirname, struct dirent*** namelist, int (*select)(struct dirent *), int (*compar)(const void *, const void *)) {
//     int result = original_scandir(dirname, namelist, select, compar);

//     return result;
// }

static int (*original_readdir_r)(DIR* dirp, struct dirent* entry, struct dirent** oresult);
static int replaced_readdir_r(DIR* dirp, struct dirent* entry, struct dirent** oresult) 
{
    if(isCallerTweak()) 
    {
        return original_readdir_r(dirp, entry, oresult);
    }

    int result = original_readdir_r(dirp, entry, oresult);
    
    if(result == 0 && *oresult) 
    {
        int fd = dirfd(dirp);

        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1) 
        {
            NSString* pathParent = [NSString stringWithUTF8String:pathname];

            do {
                if(is_hidden_file((*oresult)->d_name)) 
                {
                    // call readdir again to skip ahead
                    result = original_readdir_r(dirp, entry, oresult);
                } else {
                    break;
                }
            } while(result == 0 && *oresult);
        }
    }

    return result;
}

static struct dirent* (*original_readdir)(DIR* dirp);
static struct dirent* replaced_readdir(DIR* dirp) 
{
    if(isCallerTweak()) 
    {
        return original_readdir(dirp);
    }

    struct dirent* result = original_readdir(dirp);
    
    if(result) 
    {
        int fd = dirfd(dirp);

        // Get file descriptor path.
        char pathname[PATH_MAX];
        
        if(fcntl(fd, F_GETPATH, pathname) != -1) 
        {
            NSString* pathParent = [NSString stringWithUTF8String:pathname];

            do {
                if(is_hidden_file((result->d_name))) 
                {
                    // call readdir again to skip ahead
                    result = original_readdir(dirp);
                } else {
                    break;
                }
            } while(result);
        }
    }

    return result;
}

static FILE* (*original_fopen)(const char* pathname, const char* mode);
static FILE* replaced_fopen(const char* pathname, const char* mode) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_fopen(pathname, mode);
    }

    errno = ENOENT;
    return NULL;
}

static FILE* (*original_freopen)(const char* pathname, const char* mode, FILE* stream);
static FILE* replaced_freopen(const char* pathname, const char* mode, FILE* stream) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_freopen(pathname, mode, stream);
    }

    errno = ENOENT;
    return NULL;
}

static char* (*original_realpath)(const char* pathname, char* resolved_path);
static char* replaced_realpath(const char* pathname, char* resolved_path) 
{
    char* result = original_realpath(pathname, resolved_path);

    if(result && !isCallerTweak() && is_hidden_file(pathname)) 
    {
        errno = ENOENT;
        return NULL;
    }

    return result;
}

static int (*original_getattrlist)(const char* path, struct attrlist* attrList, void* attrBuf, size_t attrBufSize, unsigned long options);
static int replaced_getattrlist(const char* path, struct attrlist* attrList, void* attrBuf, size_t attrBufSize, unsigned long options) {
    int result = original_getattrlist(path, attrList, attrBuf, attrBufSize, options);

    if(result != -1 && !isCallerTweak() && is_hidden_file(path)) 
    {
        errno = ENOENT;
        return -1;
    }

    return result;
}

static int (*original_symlink)(const char* path1, const char* path2);
static int replaced_symlink(const char* path1, const char* path2) 
{
    if(isCallerTweak() || !(is_hidden_file(path2) || is_hidden_file(path1)))
    {
        return original_symlink(path1, path2);
    }

    errno = EACCES;
    return -1;
}

static int (*original_link)(const char* path1, const char* path2);
static int replaced_link(const char* path1, const char* path2) 
{
    if(isCallerTweak() || !(is_hidden_file(path2) || is_hidden_file(path1))) 
    {
        return original_link(path1, path2);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_rename)(const char* old, const char* new_path);
static int replaced_rename(const char* old, const char* new_path) 
{

    if(isCallerTweak() || !(is_hidden_file(old) || is_hidden_file(new_path))) 
    {
        return original_rename(old, new_path);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_remove)(const char* pathname);
static int replaced_remove(const char* pathname) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_remove(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_unlink)(const char* pathname);
static int replaced_unlink(const char* pathname) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_unlink(pathname);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_unlinkat)(int dirfd, const char* pathname, int flags);
static int replaced_unlinkat(int dirfd, const char* pathname, int flags) 
{
    if(isCallerTweak()) 
    {
        return original_unlinkat(dirfd, pathname, flags);
    }

    if(pathname
    && dirfd != fileno(stderr)
    && dirfd != fileno(stdout)
    && dirfd != fileno(stdin)) 
    {
        NSString* path = [NSString stringWithUTF8String:pathname];

        // Get file descriptor path.
        char pathnameParent[PATH_MAX];
        NSString* pathParent = nil;

        if(dirfd == AT_FDCWD) {
            pathParent = [[NSFileManager defaultManager] currentDirectoryPath];
        } else if(fcntl(dirfd, F_GETPATH, pathnameParent) != -1) {
            pathParent = [NSString stringWithUTF8String:pathnameParent];
        }

        if(is_hidden_file(pathname)) 
        {
            errno = [path isAbsolutePath] ? ENOENT : EBADF;
            return -1;
        }
    }

    return original_unlinkat(dirfd, pathname, flags);
}

static int (*original_rmdir)(const char* pathname);
static int replaced_rmdir(const char* pathname) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_rmdir(pathname);
    }

    errno = ENOENT;
    return -1;
}

static long (*original_pathconf)(const char* pathname, int name);
static long replaced_pathconf(const char* pathname, int name) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_pathconf(pathname, name);
    }

    errno = ENOENT;
    return -1;
}

static long (*original_fpathconf)(int fd, int name);
static long replaced_fpathconf(int fd, int name) 
{
    if(isCallerTweak()) 
    {
        return original_fpathconf(fd, name);
    }
    
    
    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) 
    {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && is_hidden_file(pathname)) 
        {
            errno = EBADF;
            return -1;
        }
    }

    return original_fpathconf(fd, name);
}

static int (*original_utimes)(const char* pathname, const struct timeval times[2]);
static int replaced_utimes(const char* pathname, const struct timeval times[2]) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original_utimes(pathname, times);
    }

    errno = ENOENT;
    return -1;
}

static int (*original_futimes)(int fd, const struct timeval times[2]);
static int replaced_futimes(int fd, const struct timeval times[2]) 
{
    if(isCallerTweak()) 
    {
        return original_futimes(fd, times);
    }
    
    if(fd != fileno(stderr)
    && fd != fileno(stdout)
    && fd != fileno(stdin)) 
    {
        // Get file descriptor path.
        char pathname[PATH_MAX];

        if(fcntl(fd, F_GETPATH, pathname) != -1 && is_hidden_file(pathname)) 
        {
            errno = EBADF;
            return -1;
        }
    }

    return original_futimes(fd, times);
}

static char* (*original_getenv)(const char* name);
static char* replaced_getenv(const char* name) 
{
    if(isCallerTweak()) 
    {
        return original_getenv(name);
    }

    char* result = original_getenv(name);

    // if(result && name) {
    //     if(strcmp(name, "DYLD_INSERT_LIBRARIES") == 0
    //     || strcmp(name, "_MSSafeMode") == 0
    //     || strcmp(name, "_SafeMode") == 0
    //     || strcmp(name, "_SubstituteSafeMode") == 0) {
    //         return NULL;
    //     }

    //     if(strcmp(name, "SHELL") == 0) {
    //         return "/bin/sh";
    //     }
    // }

    return result;
}

static DIR* (*original___opendir2)(const char* pathname, size_t bufsize);
static DIR* replaced___opendir2(const char* pathname, size_t bufsize) 
{
    if(isCallerTweak() || !is_hidden_file(pathname)) 
    {
        return original___opendir2(pathname, bufsize);
    }

    errno = ENOENT;
    return NULL;
}

__attribute__((constructor))
static void hook()
{
    //c_hook("access", (void *)replaced_access, (void **) &original_access);
    c_hook("chdir", (void *)replaced_chdir, (void **) &original_chdir);
    c_hook("chroot", (void *)replaced_chroot, (void **) &original_chroot);
    c_hook("creat", (void *)replaced_creat, (void **) &original_creat);
    c_hook("statfs", (void *)replaced_statfs, (void **) &original_statfs);
    c_hook("fstatfs", (void *)replaced_fstatfs, (void **) &original_fstatfs);
    c_hook("statvfs", (void *)replaced_statvfs, (void **) &original_statvfs);
    c_hook("fstatvfs", (void *)replaced_fstatvfs, (void **) &original_fstatvfs);
    c_hook("stat", (void *)replaced_stat, (void **) &original_stat);
    c_hook("lstat", (void *)replaced_lstat, (void **) &original_lstat);
    c_hook("faccessat", (void *)replaced_faccessat, (void **) &original_faccessat);
    c_hook("readdir_r", (void *)replaced_readdir_r, (void **) &original_readdir_r);
    c_hook("readdir", (void *)replaced_readdir, (void **) &original_readdir);
    c_hook("realpath", (void *)replaced_realpath, (void **) &original_realpath);
    c_hook("readlink", (void *)replaced_readlink, (void **) &original_readlink);
    c_hook("readlinkat", (void *)replaced_readlinkat, (void **) &original_readlinkat);
    c_hook("link", (void *)replaced_link, (void **) &original_link);
    // c_hook("scandir", (void *)replaced_scandir, (void **) &original_scandir);
    c_hook("getmntinfo", (void *)replaced_getmntinfo, (void **) &original_getmntinfo);
    c_hook("getattrlist", (void *)replaced_getattrlist, (void **) &original_getattrlist);
    c_hook("symlink", (void *)replaced_symlink, (void **) &original_symlink);
    c_hook("rename", (void *)replaced_rename, (void **) &original_rename);
    c_hook("remove", (void *)replaced_remove, (void **) &original_remove);
    c_hook("unlink", (void *)replaced_unlink, (void **) &original_unlink);
    c_hook("unlinkat", (void *)replaced_unlinkat, (void **) &original_unlinkat);
    c_hook("rmdir", (void *)replaced_rmdir, (void **) &original_rmdir);
    c_hook("pathconf", (void *)replaced_pathconf, (void **) &original_pathconf);
    c_hook("fpathconf", (void *)replaced_fpathconf, (void **) &original_fpathconf);
    c_hook("utimes", (void *)replaced_utimes, (void **) &original_utimes);
    c_hook("futimes", (void *)replaced_futimes, (void **) &original_futimes);
    c_hook("fchdir", (void *)replaced_fchdir, (void **) &original_fchdir);
    c_hook("getfsstat", (void *)replaced_getfsstat, (void **) &original_getfsstat);
    c_hook("fstat", (void *)replaced_fstat, (void **) &original_fstat);
    c_hook("fstatat", (void *)replaced_fstatat, (void **) &original_fstatat);

    c_hook("__opendir2", (void *)replaced___opendir2, (void **) &original___opendir2);
}