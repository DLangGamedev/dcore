/*
Copyright (c) 2024-2025 Timur Gafarov

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
module dcore.random;

/**
 * Bob Jenkins' 96 bit mix function
 */
ulong mix(ulong a, ulong b, ulong c) pure nothrow @nogc
{
    a=a-b;  a=a-c;  a=a^(c >> 13);
    b=b-c;  b=b-a;  b=b^(a << 8);
    c=c-a;  c=c-b;  c=c^(b >> 13);
    a=a-b;  a=a-c;  a=a^(c >> 12);
    b=b-c;  b=b-a;  b=b^(a << 16);
    c=c-a;  c=c-b;  c=c^(b >> 5);
    a=a-b;  a=a-c;  a=a^(c >> 3);
    b=b-c;  b=b-a;  b=b^(a << 10);
    c=c-a;  c=c-b;  c=c^(b >> 15);
    return c;
}

version(WebAssembly)
{
    // Not implemented
    
    // Fallback
    void init() nothrow @nogc
    {
    }
}
else version(FreeStanding)
{
    // Not implemented
    
    // Fallback
    void init() nothrow @nogc
    {
    }
}
else
{
    import dcore.stdlib;
    import dcore.time;
    import dcore.process;
    
    enum RAND_MAX = 0x7fff;
    
    void init() nothrow @nogc
    {
        srand(cast(uint)seed());
    }
    
    void setSeed(uint s) nothrow @nogc
    {
        srand(s);
    }
    
    ulong seed() nothrow @nogc
    {
        return mix(clock(), time(null), processId());
    }

    /**
     * Returns pseudo-random integer between mi (inclusive) and ma (exclusive)
     */
    int randomInRange(int mi, int ma) nothrow @nogc
    {
        return (rand() % (ma - mi)) + mi;
    }
    
    /**
     * Returns pseudo-random floating-point number in 0..1 range
     */
    T random(T)() nothrow @nogc
    {
        T res = (rand() % RAND_MAX) / cast(T)RAND_MAX;
        return res;
    }
}
