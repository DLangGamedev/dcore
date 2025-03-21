/*
Copyright (c) 2022-2025 Timur Gafarov

Boost Software License - Version 1.0 - August 17th, 2003

Permission is hereby granted, free of charge, to any person or organization
obtaining a copy of the software and accompanying documentation covered by
this license (the "Software") to use, reproduce, display, distribute,
execute, and transmit the Software, and to prepare derivative works of the
Software, and to permit third-parties to whom the Software is furnished to
do so, all subject to the following:

The copyright notices in the Software and this entire statement, including
the above license grant, this restriction and the following disclaimer,
must be included in all copies of the Software, in whole or in part, and
all derivative works of the Software, unless such copies or derivative
works are solely in the form of machine-executable object code generated by
a source language processor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE, TITLE AND NON-INFRINGEMENT. IN NO EVENT
SHALL THE COPYRIGHT HOLDERS OR ANYONE DISTRIBUTING THE SOFTWARE BE LIABLE
FOR ANY DAMAGES OR OTHER LIABILITY, WHETHER IN CONTRACT, TORT OR OTHERWISE,
ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
DEALINGS IN THE SOFTWARE.
*/
module dcore.sys;

version(Windows) { version = _TP_Windows; }
version(linux) { version = _TP_Unix_sysconf; }
version(Solaris) { version = _TP_Unix_sysconf; }
version(AIX) { version = _TP_Unix_sysconf; }
version(OSX) { version = _TP_Unix_sysctl; }
version(FreeBSD) { version = _TP_Unix_sysctl; }
version(OpenBSD) { version = _TP_Unix_sysctl; }
version(NetBSD) { version = _TP_Unix_sysctl; }
version(DragonFlyBSD) { version = _TP_Unix_sysctl; }
version(BSD) { version = _TP_Unix_sysctl; }

enum ProcessorArchitecture
{
    Unknown,
    x86,
    x64,
    ARM,
    ARM64,
    IA64,
    MIPS32,
    MIPS64,
    SPARC7,
    SPARC8,
    SPARC9,
    PPC32,
    PPC64
}

struct SysInfo
{
    ulong totalMemory;
    ProcessorArchitecture architecture;
    uint numProcessors;
    string osName;
    string osVersion;
}

version(Windows)
{
    private __gshared char[32] __windows_osversion;
}
version(Posix)
{
    import core.sys.posix.sys.utsname;

    private __gshared utsname __posix_utsname;
    
    struct ArchitectureMapping
    {
        string unameStr;
        ProcessorArchitecture architecture;
    }
    
    private static immutable ArchitectureMapping[] archTable = [
        { "x86_64", ProcessorArchitecture.x64 },
        { "i386", ProcessorArchitecture.x86 },
        { "armv7l", ProcessorArchitecture.ARM },
        { "aarch64", ProcessorArchitecture.ARM64 },
        { "iPhone", ProcessorArchitecture.ARM64 },
        { "iPad", ProcessorArchitecture.ARM64 },
        { "ia64", ProcessorArchitecture.IA64 },
        { "mips", ProcessorArchitecture.MIPS32 },
        { "mips64", ProcessorArchitecture.MIPS64 },
        { "sparc", ProcessorArchitecture.SPARC8 },
        { "ppc", ProcessorArchitecture.PPC32 },
        { "ppc64", ProcessorArchitecture.PPC64 }
    ];
}

/*
 * sysInfo works on Windows, Unix/sysconf (Linux-like)
 * and Unix/sysctl (BSD-like) systems.
 * Under other systems it returns false, meaning that 
 * it's not possible to retrieve system information.
 */
bool sysInfo(SysInfo* info) nothrow @nogc
{
    bool result = false;

    version(_TP_Windows)
    {
        import core.stdc.stdio;
        import core.stdc.string;
        import core.sys.windows.windows;

        SYSTEM_INFO sysinfo;
        GetSystemInfo(&sysinfo);
        info.numProcessors = sysinfo.dwNumberOfProcessors;
        
        auto procArch = sysinfo.wProcessorArchitecture;
        
        if (procArch == PROCESSOR_ARCHITECTURE_INTEL) info.architecture = ProcessorArchitecture.x86;
        else if (procArch == PROCESSOR_ARCHITECTURE_AMD64) info.architecture = ProcessorArchitecture.x64;
        else if (procArch == PROCESSOR_ARCHITECTURE_ARM) info.architecture = ProcessorArchitecture.ARM;
        else if (procArch == 12) info.architecture = ProcessorArchitecture.ARM64;
        else if (procArch == PROCESSOR_ARCHITECTURE_IA64) info.architecture = ProcessorArchitecture.IA64;
        else if (procArch == PROCESSOR_ARCHITECTURE_UNKNOWN) info.architecture = ProcessorArchitecture.Unknown;
        
        MEMORYSTATUSEX status;
        status.dwLength = status.sizeof;
        GlobalMemoryStatusEx(&status);
        info.totalMemory = status.ullTotalPhys;
        
        OSVERSIONINFOEXA osvi;
        osvi.dwOSVersionInfoSize = osvi.sizeof;
        if (GetVersionExA(cast(LPOSVERSIONINFOA)&osvi) != 0)
        {
            switch (osvi.dwPlatformId)
            {
                case VER_PLATFORM_WIN32s:
                    info.osName = "Windows 3.x";
                    break;
                case VER_PLATFORM_WIN32_WINDOWS:
                    info.osName = (osvi.dwMinorVersion == 0) ? "Windows 95" : "Windows 98";
                    break;
                case VER_PLATFORM_WIN32_NT:
                    info.osName = "Windows NT";
                    break;
                default:
                    info.osName = "Windows";
                    break;
            }
            
            snprintf(__windows_osversion.ptr, __windows_osversion.length, "%d.%d", osvi.dwMajorVersion, osvi.dwMinorVersion);
            info.osVersion = cast(string)__windows_osversion[0..strlen(__windows_osversion.ptr)];
        }
        
        result = true;
    }
    else version(Posix)
    {
        import core.stdc.string;
        
        info.architecture = ProcessorArchitecture.Unknown;
        info.osName = "Unix/unknown";
        info.osVersion = "";

        if (uname(&__posix_utsname) == 0)
        {
            auto osNameLen = strlen(__posix_utsname.sysname.ptr);
            info.osName = cast(string)__posix_utsname.sysname[0..osNameLen];

            auto osReleaseLen = strlen(__posix_utsname.release.ptr);
            info.osVersion = cast(string)__posix_utsname.release[0..osReleaseLen];
            
            foreach (mapping; archTable)
            {
                if (strncmp(__posix_utsname.machine.ptr, mapping.unameStr.ptr, mapping.unameStr.length) == 0)
                {
                    info.architecture = mapping.architecture;
                    break;
                }
            }
        }

        version(_TP_Unix_sysconf)
        {
            import core.sys.posix.unistd;

            info.numProcessors = cast(uint)sysconf(_SC_NPROCESSORS_ONLN);
            
            long pages = sysconf(_SC_PHYS_PAGES);
            long pageSize = sysconf(_SC_PAGE_SIZE);
            info.totalMemory = pages * pageSize;
            
            result = true;
        }
        else version(_TP_Unix_sysctl)
        {
            import core.sys.posix.sys.sysctl;
            import core.sys.posix.sys.types;
            
            size_t len;
            int[4] mib;
            
            len = numCPU.sizeof;
            mib[0] = CTL_HW;
            mib[1] = HW_AVAILCPU;
            int numCPU;
            sysctl(mib, 2, &numCPU, &len, null, 0);
            if (numCPU < 1)
            {
                mib[1] = HW_NCPU;
                sysctl(mib, 2, &numCPU, &len, null, 0);
                if (numCPU < 1)
                    numCPU = 1;
            }
            info.numProcessors = numCPU;
            
            len = ulong.sizeof;
            mib[0] = CTL_HW;
            mib[1] = HW_MEMSIZE;
            ulong totalMemory = 0;
            if (sysctl(mib.ptr, 2, &totalMemory, &len, null, 0) == 0)
            {
                info.totalMemory = totalMemory;
            }
            
            result = true;
        }
    }

    return result;
}
