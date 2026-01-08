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

#include <stdlib.h>
#include <unistd.h>
#include <limits.h>

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>

static int (*orig_connect)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
int my_connect(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (addr && addr->sa_family == AF_INET)
    {
        const struct sockaddr_in *addr_in = (const struct sockaddr_in *)addr;
        uint32_t ip = ntohl(addr_in->sin_addr.s_addr);
        uint16_t port = ntohs(addr_in->sin_port);

        if (ip == 0x7f000001)
        {
            if (port == 1234 || port == 8080 || port == 2222 || port == 22 || port == 27042 || port == 4444 || port == 44)
            {
                errno = ECONNREFUSED;
                return -1;
            }
        }
    }

    return orig_connect(sockfd, addr, addrlen);
}

static int (*orig_bind)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
int my_bind(int sockfd, const struct sockaddr *addr, socklen_t addrlen)
{
    if (addr && addr->sa_family == AF_INET)
    {
        const struct sockaddr_in *addr_in = (const struct sockaddr_in *)addr;
        uint32_t ip = ntohl(addr_in->sin_addr.s_addr);
        uint16_t port = ntohs(addr_in->sin_port);

        if (ip == 0x7f000001 && (port == 1234 || port == 8080 || port == 2222 || port == 22 || port == 27042 || port == 4444 || port == 44))
        {
            errno = EADDRINUSE;
            return -1;
        }
    }
    return orig_bind(sockfd, addr, addrlen);
}


static int (*orig_getaddrinfo)(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res);
static int my_getaddrinfo(const char *node, const char *service, const struct addrinfo *hints, struct addrinfo **res)
{
    if (node && (strcmp(node, "localhost") == 0 || strcmp(node, "127.0.0.1") == 0))
    {
        return EAI_NONAME;
    }
    return orig_getaddrinfo(node, service, hints, res);
}

static struct hostent *(*orig_gethostbyaddr)(const void *addr, socklen_t len, int type);
static struct hostent *my_gethostbyaddr(const void *addr, socklen_t len, int type)
{
    if (addr && type == AF_INET)
    {
        const struct in_addr *in = (const struct in_addr *)addr;
        if (ntohl(in->s_addr) == 0x7f000001)
        {
            h_errno = HOST_NOT_FOUND;
            return NULL;
        }
    }
    return orig_gethostbyaddr(addr, len, type);
}

static int (*orig_getnameinfo)(const struct sockaddr *sa, socklen_t salen, char *host,
                               size_t hostlen, char *serv, size_t servlen, int flags);
static int my_getnameinfo(const struct sockaddr *sa, socklen_t salen, char *host,
                          size_t hostlen, char *serv, size_t servlen, int flags)
{
    if (sa && sa->sa_family == AF_INET)
    {
        const struct sockaddr_in *addr_in = (const struct sockaddr_in *)sa;
        uint32_t ip = ntohl(addr_in->sin_addr.s_addr);
        if (ip == 0x7f000001)
        {
            return EAI_FAIL;
        }
    }
    return orig_getnameinfo(sa, salen, host, hostlen, serv, servlen, flags);
}

__attribute__((constructor))
static void hook()
{
    c_hook("connect", (void *)my_connect, (void **)&orig_connect);
    c_hook("bind", (void *)my_bind, (void **)&orig_bind);
    c_hook("getaddrinfo", (void *)my_getaddrinfo, (void **)&orig_getaddrinfo);
    c_hook("gethostbyaddr", (void *)my_gethostbyaddr, (void **)&orig_gethostbyaddr);
    c_hook("getnameinfo", (void *)my_getnameinfo, (void **)&orig_getnameinfo);
}
