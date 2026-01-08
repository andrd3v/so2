#import "helper.h"

NSArray *files_to_check() {
    return @[
            @"/.bootstrapped_electra",
            @"/.cydia_no_stash",
            @"/.installed_unc0ver",
            @"/Applications/Cydia.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/Icy.app",
            @"/Applications/IntelliScreen.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/SBSettings.app",
            @"/Applications/Sileo.app",
            @"/Applications/Snoop-itConfig.app",
            @"/Applications/WinterBoard.app",
            @"/Applications/blackra1n.app",
            @"/Library/MobileSubstrate/CydiaSubstrate.dylib",
            @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            @"/Library/MobileSubstrate/MobileSubstrate.dylib",
            @"/Library/PreferenceBundles/ABypassPrefs.bundle",
            @"/Library/PreferenceBundles/FlyJBPrefs.bundle",
            @"/Library/PreferenceBundles/LibertyPref.bundle",
            @"/Library/PreferenceBundles/ShadowPreferences.bundle",
            @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            @"/bin/bash",
            @"/bin/sh",
            @"/etc/apt",
            @"CydiaSubstrate"
            @"/etc/apt/sources.list.d/electra.list",
            @"/etc/apt/sources.list.d/sileo.sources",
            @"/etc/apt/undecimus/undecimus.list",
            @"/etc/ssh/sshd_config",
            @"/jb/amfid_payload.dylib",
            @"/jb/jailbreakd.plist",
            @"/jb/libjailbreak.dylib",
            @"/jb/lzma",
            @"/jb/offsets.plist",
            @"/private/etc/apt",
            @"/private/etc/dpkg/origins/debian",
            @"/private/etc/ssh/sshd_config",
            @"/private/var/Users/",
            @"/private/var/cache/apt/",
            @"/private/var/lib/apt",
            @"/private/var/lib/cydia",
            @"/private/var/log/syslog",
            @"/private/var/mobile/Library/SBSettings/Themes",
            @"/private/var/stash",
            @"/private/var/tmp/cydia.log",
            @"/var/tmp/cydia.log",
            @"/usr/bin/cycript",
            @"/usr/bin/sshd",
            @"/usr/lib/libcycript.dylib",
            @"/usr/lib/libhooker.dylib",
            @"/usr/lib/libjailbreak.dylib",
            @"/usr/lib/libsubstitute.dylib",
            @"/usr/lib/substrate",
            @"/usr/lib/TweakInject",
            @"/usr/libexec/cydia",
            @"/usr/libexec/cydia/firmware.sh",
            @"/usr/libexec/sftp-server",
            @"/usr/libexec/ssh-keysign",
            @"/usr/local/bin/cycript",
            @"/usr/sbin/frida-server",
            @"/usr/sbin/sshd",
            @"/usr/share/jailbreak/injectme.plist",
            @"/var/binpack",
            @"/var/cache/apt",
            @"/var/checkra1n.dmg",
            @"/var/lib/apt",
            @"/var/lib/cydia",
            @"/var/lib/dpkg/info/mobilesubstrate.md5sums",
            @"/var/log/apt",
            @"/usr/sbin/frida-server",
            @"/etc/apt/sources.list.d/electra.list",
            @"/etc/apt/sources.list.d/sileo.sources",
            @"/.bootstrapped_electra",
            @"/usr/lib/libjailbreak.dylib",
            @"/jb/lzma",
            @"/.cydia_no_stash",
            @"/.installed_unc0ver",
            @"/jb/offsets.plist",
            @"/usr/share/jailbreak/injectme.plist",
            @"/etc/apt/undecimus/undecimus.list",
            @"/var/lib/dpkg/info/mobilesubstrate.md5sums",
            @"/Library/MobileSubstrate/MobileSubstrate.dylib",
            @"/jb/jailbreakd.plist",
            @"/jb/amfid_payload.dylib",
            @"/jb/libjailbreak.dylib",
            @"/usr/libexec/cydia/firmware.sh",
            @"/var/lib/cydia",
            @"/etc/apt",
            @"/private/var/lib/apt",
            @"/private/var/Users/",
            @"/var/log/apt",
            @"/Applications/Cydia.app",
            @"/private/var/stash",
            @"/private/var/lib/apt/",
            @"/private/var/lib/cydia",
            @"/private/var/cache/apt/",
            @"/private/var/log/syslog",
            @"/private/var/tmp/cydia.log",
            @"/Applications/Icy.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/blackra1n.app",
            @"/Applications/SBSettings.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/WinterBoard.app",
            @"/Applications/IntelliScreen.app",
            @"/private/var/mobile/Library/SBSettings/Themes",
            @"/Library/MobileSubstrate/CydiaSubstrate.dylib",
            @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            @"/Applications/Cydia.app",
            @"/Applications/blackra1n.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/Icy.app",
            @"/Applications/IntelliScreen.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/SBSettings.app",
            @"/Applications/WinterBoard.app",
            @"/Applications/blackra1n.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/Icy.app",
            @"/Applications/IntelliScreen.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/SBSettings.app",
            @"/Applications/WinterBoard.app",
            @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/Veency.plis",
            @"/private/var/lib/apt",
            @"/private/var/lib/cydia",
            @"/private/var/mobile/Library/SBSettings/Themes",
            @"/private/var/stash",
            @"/private/var/tmp/cydia.log",
            @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            @"/usr/bin/sshd",
            @"/usr/libexec/sftp-server",
            @"/usr/sbin/sshd",
            @"substitute",
            @"libsubstrate",
            @"copsbp", 
            @"libsubstrate.dylib",
            @"copsbp.dylib", 
            @"TweakInject",
            @"FontBoard.dylib",
            @"FLEXList.dylib",
            @"Shadow.dylib", 
            @"Sandy",
            @"libellekit.dylib",
            @"bpcopsik.dylib",
            @"embedded.mobileprovision", 
            @"blackra1n.app", 
            @"FakeCarrier.app", 
            @"Icy.app", 
            @"IntelliScreen.app", 
            @"MxTube.app", 
            @"RockApp.app", 
            @"SBSettings.app", 
            @"WinterBoard.app", 
            @"LiveClock.plist", 
            @"Veency.plis", 
            @"apt", 
            @"cydia",
            @"Themes", 
            @"stash", 
            @"cydia.log", 
            @"com.ikey.bbot.plist", 
            @"com.saurik.Cydia.Startup.plist", 
            @"sshd", 
            @"sftp-server", 
            @"bp.dylib", 
            @"SignedByEsign", 
            @"_TrollStore",
            @"/private/var/lib/apt/",
            @"/private/var/jb/",
            @"/private/var/lib/cydia",
            @"/private/var/cache/apt/",
            @"/private/var/log/syslog",
            @"/private/var/tmp/cydia.log",
            @"/Applications/Icy.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/blackra1n.app",
            @"/Applications/SBSettings.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/WinterBoard.app",
            @"/Applications/IntelliScreen.app",
            @"/private/var/mobile/Library/SBSettings/Themes",
            @"/Library/MobileSubstrate/CydiaSubstrate.dylib",
            @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            @"/Applications/Cydia.app",
            @"/usr/bin/sshd",
            @"/usr/libexec/sftp-server",
            @"/usr/sbin/sshd",
            @"/Applications/Cydia.app",
            @"/Applications/blackra1n.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/Icy.app",
            @"/Applications/IntelliScreen.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/SBSettings.app",
            @"/Applications/WinterBoard.app",
            @"/Library/MobileSubstrate/MobileSubstrate.dylib",
            @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            @"/Library/TweakInject/TweakInject.dylib",
            @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            @"/private/var/tmp/cydia.log",
            @"/bin/bash",
            @"/bin/su",
            @"/bin/bzip2",
            @"/bin/cat",
            @"/bin/chmod",
            @"/bin/mv",
            @"/bin/ls",
            @"/usr/sbin/sshd",
            @"/etc/apt",
            @"/usr/bin/ssh",
            @"embedded.mobileprovision",
            @"/private/jailbreak.txt",
            @"substrate",
            @"/var/lib/undecimus/apt",
            @"/Applications",
            @"/Library/Ringtones",
            @"/Library/Wallpaper",
            @"/usr/arm-apple-darwin9",
            @"/usr/include",
            @"/usr/libexec",
            @"/usr/share",
            @"CydiaSubstrate",
            @"cycc",
            @"cynject",
            @"SubstrateBootstrap",
            @"SubstrateInjection",
            @"SubstrateLauncher",
            @"SubstrateLoader",
            @"libhelper",
            @"/usr/sbin/sshd",
            @"/private/var/lib/apt/",
            @"/private/var/lib/apt/",
            @"/bin/bash",
            @"/usr/sbin/sshd",
            @"/Applications/Cydia.app",
            @"/Applications/blackra1n.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/Icy.app",
            @"/Applications/IntelliScreen.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/SBSettings.app",
            @"/Applications/WinterBoard.app",
            @"/etc/apt",
            @"/Library/MobileSubstrate/MobileSubstrate.dylib",
            @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            @"/private/var/lib/cydia",
            @"/private/var/lib/apt/",
            @"/private/var/mobile/Library/SBSettings/Themes",
            @"/private/var/stash",
            @"/private/var/tmp/cr",
            @"/private/var/tmp/crw",
            @"/private/var/tmp/cydia.log",
            @"/private/var/tmp/st_data",
            @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            @"/var/root/test.app",
            @"/bin/bash",
            @"/Applications/Cydia.app",
            @"/Applications/blackra1n.app",
            @"/Applications/FakeCarrier.app",
            @"/Applications/Icy.app",
            @"/Applications/IntelliScreen.app",
            @"/Applications/MxTube.app",
            @"/Applications/RockApp.app",
            @"/Applications/SBSettings.app",
            @"/Applications/WinterBoard.app",
            @"/Library/MobileSubstrate/MobileSubstrate.dylib",
            @"/Library/MobileSubstrate/DynamicLibraries/LiveClock.plist",
            @"/Library/MobileSubstrate/DynamicLibraries/Veency.plist",
            @"/Library/TweakInject/TweakInject.dylib",
            @"/System/Library/LaunchDaemons/com.ikey.bbot.plist",
            @"/System/Library/LaunchDaemons/com.saurik.Cydia.Startup.plist",
            @"/private/var/tmp/cydia.log",
            @"/bin/su",
            @"/bin/bzip2",
            @"/bin/cat",
            @"/bin/chmod",
            @"/bin/mv",
            @"/bin/ls",
            @"/usr/sbin/sshd",
            @"/etc/apt",
            @"/usr/bin/ssh",
            @"/.bootstrapped_electra",
            @"/.cydia_no_stash",
            @"/.installed_unc0ver",
            @"/Applications/Snoop-itConfig.app",
            @"/etc/apt/sources.list.d/electra.list",
            @"/etc/apt/sources.list.d/sileo.sources",
            @"/etc/apt/undecimus/undecimus.list",
            @"/etc/clutch_cracked.plist",
            @"/etc/clutch.conf",
            @"/etc/dropbear",
            @"/jb/amfid_payload.dylib",
            @"/jb/jailbreakd.plist",
            @"/jb/libjailbreak.dylib",
            @"/jb/lzma",
            @"/jb/offsets.plist",
            @"/Library/MobileSubstrate/CydiaSubstrate.dylib",
            @"/Library/MobileSubstrate/DynamicLibraries/LocalIAPStore.dylib",
            @"/pguntether",
            @"/private/var/cache/apt",
            @"/private/var/lib/apt",
            @"/private/var/lib/cydia",
            @"/private/var/log/syslog",
            @"/private/var/mobile/Library/SBSettings/Themes",
            @"/private/var/stash",
            @"/private/var/Users/",
            [NSString stringWithCString:MY_TWEAK_NAME encoding:NSUTF8StringEncoding]
            ];
}



NSArray *dylds_to_check()
{
    return @[
        @"...!@#",
        @"/.file",
        @"Cephei",
        @"0Shadow.dylib",
        @"ABypass",
        @"Cephei",
        @"CustomWidgetIcons",
        @"CydiaSubstrate",
        @"Electra",
        @"FlyJB",
        @"FridaGadget",
        @"MobileSubstrate.dylib",
        @"PreferenceLoader",
        @"RocketBootstrap",
        @"SSLKillSwitch.dylib",
        @"SSLKillSwitch2.dylib",
        @"Substitute",
        @"SubstrateBootstrap",
        @"SubstrateInserter",
        @"SubstrateInserter.dylib",
        @"SubstrateLoader.dylib",
        @"TweakInject.dylib",
        @"WeeLoader",
        @"cyinject",
        @"libcycript",
        @"libhooker",
        @"libsparkapplist.dylib",
        @"zzzzLiberty.dylib",
        @"zzzzzzUnSub.dylib",
        @"frida",
        @"flex",
        @"colorpicker",
        @"rocketbootstrap",
        @"substitute",
        @"substrate",
        @"cephei",
        @"tweakinject",
        @"systemhook",
        @"libinjector",
        @"copsbp",
        @"bpcopsik.dylib",
        @"libellekit.dylib",
        @"Sandy",
        @"Shadow.dylib",
        @"FLEXList.dylib",
        @"FontBoard.dylib",
        @"TweakInject",
        @"tweakinject",
        @"cephei",
        @"substrate",
        @"substitute",
        @"applist",
        @"rocketbootstrap",
        @"colorpicker",
        @"frida",
        @"libhack",
        @"libhack.dylib"
        @"CydiaSubstrate",
        @"cycc",
        @"cynject",
        @"SubstrateBootstrap",
        @"SubstrateInjection",
        @"SubstrateLauncher",
        @"SubstrateLoader",
        @"libhelper",
        [NSString stringWithCString:MY_TWEAK_NAME encoding:NSUTF8StringEncoding]
    ];
}

NSArray *syms_to_check()
{
    return @[
        @"MSHookFunction",
        @"MSHookMessageEx",
        @"_MSHookFunction",
        @"MSFindSymbol",
        @"MSHookMemory",
        @"MSGetImageByName",
        @"substrate_safe_call",
        @"SubstrateBootstrap",
        @"_substrate",
        @"rebind_symbols",
        @"rebind_symbols_image",
        @"class_replaceMethod",
        @"method_exchangeImplementations",
        @"frida_agent_main",
        @"frida_trampoline",
        @"_gum_exec_ctx_get_current",
        @"gum_interceptor_attach",
        @"gumjs_runtime_create",
        @"_cycript",
        @"cycript",
        @"JBDetectBypass",
        @"MobileLoader",
        @"substitute_hook_functions",
        @"substitute_hook_objc_messageSend",
        @"substitute_find_private_syms",
        @"substitute_library_init",
        @"substitute_premain",
    ];
}


void to_lowercase(const char *input, char *output)
{
    size_t len = strlen(input);
    for (size_t i = 0; i < len; i++)
    {
        output[i] = (char)tolower((unsigned char)input[i]);
    }
    output[len] = '\0';
}


bool is_hidden_file(const char* charName)
{
    if (!charName) return false;
    
    
    NSString* mainExecutablePath = [[NSBundle mainBundle] executablePath];
    NSString* ll = [NSString stringWithUTF8String: charName];
    if ([mainExecutablePath containsString:ll])
    {
        return false;
    }
    
    if ([ll containsString:@"/var/mobile/Containers/Data/Application/"])
    {
        return false;
    }
    
    if ([ll containsString:@".bak"])
    {
        return true;
    }
    
    NSString *name = [NSString stringWithUTF8String: charName];
    NSString *lowerpath = [name lowercaseString];
    NSString *lastComponent = [[lowerpath lastPathComponent] stringByDeletingPathExtension];
    
    NSArray* restrictedPaths = files_to_check();
    
    for (NSString* restrictedPath in restrictedPaths)
    {
        NSString *lowerrestrictedPath = [restrictedPath lowercaseString];
        
        if ([lowerpath containsString:lowerrestrictedPath] /*|| [lowerrestrictedPath containsString:lastComponent]*/)
        {
            return true;
        }
    }
    
    restrictedPaths = dylds_to_check();
    
    for (NSString* restrictedPath in restrictedPaths)
    {
        NSString *lowerrestrictedPath = [restrictedPath lowercaseString];
        
        if ([lowerpath containsString:lowerrestrictedPath] /*|| [lowerrestrictedPath containsString:lastComponent]*/)
        {
            return true;
        }
    }
    
    char lowerName[256];
    to_lowercase(charName, lowerName);
    if (strstr(lowerName, "tweak") || strstr(lowerName, "/var/jb"))
    {
        return true;
    }
    
    return false;
}


bool is_hidden_dyld(const char* charName)
{
    if (!charName) return false;
    
    if (strstr(charName, "systemhook"))
    {
        return true;
    }
    
    NSString* mainExecutablePath = [[NSBundle mainBundle] executablePath];
    NSString* ll = [NSString stringWithUTF8String: charName];
    if ([mainExecutablePath containsString:ll])
    {
        return false;
    }
    
    
    if ([ll containsString:@"/var/mobile/Containers/Data/Application/"])
    {
        return false;
    }
    
    if ([ll containsString:@"BiomeFlexibleStorage.framework"] || [ll containsString:@"FlexMusicKit.framework"])
    {
        return false;
    }
    
    
    
    NSString *name = [NSString stringWithUTF8String: charName];
    NSString *lowerpath = [name lowercaseString];
    NSString *lastComponent = [[lowerpath lastPathComponent] stringByDeletingPathExtension];

    
    NSArray* restrictedPaths = dylds_to_check();
    
    
    for (NSString* restrictedPath in restrictedPaths)
    {
        NSString *lowerrestrictedPath = [restrictedPath lowercaseString];
        
        if ([lowerpath containsString:lowerrestrictedPath] /*|| [lowerrestrictedPath containsString:lastComponent]*/)
        {
            return true;
        }
    }
    
    char lowerName[256];
    to_lowercase(charName, lowerName);
    if (strstr(lowerName, "tweak") || strstr(lowerName, "/var/jb"))
    {
        return true;
    }
    
    return false;
}

bool is_hidden_sym(const char* sym)
{
    if (!sym) return false;

    
    NSString *name = [NSString stringWithUTF8String: sym];
    NSString *lower = [name lowercaseString];

    NSArray* restrictedPaths = syms_to_check();

    for (NSString* restrictedPath in restrictedPaths)
    {
        NSString *lowerrestrictedPath = [restrictedPath lowercaseString];
        
        if ([lower containsString:lowerrestrictedPath] || [lowerrestrictedPath containsString:lower])
        {
            return true;
        }
    }
    
    return false;
}
bool is_addr_in_my_lib(const void* addr)
{
    if (!addr) return false;
    uintptr_t a = (uintptr_t)addr;
    uint32_t image_count = _dyld_image_count();

    for (uint32_t i = 0; i < image_count; i++)
    {
        const char* image_name = _dyld_get_image_name(i);
        if (!image_name || strstr(image_name, MY_TWEAK_NAME) == NULL)
            continue;

        const struct mach_header* header = _dyld_get_image_header(i);
        intptr_t slide = _dyld_get_image_vmaddr_slide(i);
        if (!header)
            continue;

        bool is64 = (header->magic == MH_MAGIC_64);
        const uint8_t* cmd_ptr = (const uint8_t*)header + (is64
            ? sizeof(struct mach_header_64)
            : sizeof(struct mach_header));

        for (uint32_t cmd_idx = 0; cmd_idx < header->ncmds; cmd_idx++)
        {
            const struct load_command* lc = (const struct load_command*)cmd_ptr;

            if (lc->cmd == LC_SEGMENT_64 && is64)
            {
                const struct segment_command_64* seg = (const struct segment_command_64*)lc;

                uintptr_t seg_start = (uintptr_t)seg->vmaddr + slide;
                uintptr_t seg_end   = seg_start + seg->vmsize;
                if (a >= seg_start && a < seg_end)
                    return true;
            }
            else if (lc->cmd == LC_SEGMENT && !is64)
            {
                const struct segment_command_64* seg = (const struct segment_command_64*)lc;

                uintptr_t seg_start = (uintptr_t)seg->vmaddr + slide;
                uintptr_t seg_end   = seg_start + seg->vmsize;
                if (a >= seg_start && a < seg_end)
                    return true;
            }

            cmd_ptr += lc->cmdsize;
        }
    }

    return false;
}

const char* find_dylib_for_addr(const void* addr)
{
    if (!addr) return NULL;
    uintptr_t a = (uintptr_t)addr;
    uint32_t image_count = _dyld_image_count();

    for (uint32_t i = 0; i < image_count; i++)
    {
        const char* image_name = _dyld_get_image_name(i);
        const struct mach_header* header = _dyld_get_image_header(i);
        intptr_t slide = _dyld_get_image_vmaddr_slide(i);

        if (!header || !image_name) continue;

        bool is64 = (header->magic == MH_MAGIC_64);
        const uint8_t* cmd_ptr = (const uint8_t*)header + (is64
            ? sizeof(struct mach_header_64)
            : sizeof(struct mach_header));

        for (uint32_t cmd_idx = 0; cmd_idx < header->ncmds; cmd_idx++)
        {
            const struct load_command* lc = (const struct load_command*)cmd_ptr;

            if ((lc->cmd == LC_SEGMENT_64 && is64) || (lc->cmd == LC_SEGMENT && !is64))
            {
                const struct segment_command_64* seg = (const struct segment_command_64*)lc;

                uintptr_t seg_start = (uintptr_t)seg->vmaddr + slide;
                uintptr_t seg_end = seg_start + seg->vmsize;

                if (a >= seg_start && a < seg_end)
                {
                    return image_name;
                }
            }

            cmd_ptr += lc->cmdsize;
        }
    }

    return NULL;
}
