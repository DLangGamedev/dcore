dcore
=====
Low level general-purpose library for [D language](https://dlang.org). Partial successor of [dlib 1.x](https://github.com/gecko0307/dlib) and a future base for dlib 2.0.

* `betterC` compliant
* Independent from Phobos for core functionality. Uses only `betterC` parts of Phobos, like `std.traits` and system APIs
* Will become a minimal standard library: include standard I/O, math, data manipulation, etc.
* As much as possible support for bare metal/WebAssembly/ARM
* Extensive unit testing

Progress
--------
* [ ] `dcore.stdio` - standard C I/O for platforms that support it
* [ ] `dcore.stdlib` - `malloc/free` for platforms that support it
* [ ] `dcore.math` - highly portable math functions, using hardware optimizations where possible
* [x] `dcore.random` - presudo-random number generator based on C `rand` + standalone RNG with platform-independent enthropy source
* [x] `dcore.sys` - retrieve system information
* [ ] `dcore.process` - cross-platform process API
* [x] `dcore.time` - cross-platform date and time API
* [ ] `dcore.thread` - cross-platform multithreading API
* [x] `dcore.mutex` - cross-platform thread synchronization primitive
* [ ] `dcore.linker` - cross-platform dynamic library linker
* [ ] `dcore.text` - string processing, UTF-8 decoder

License
-------
Copyright (c) 2025 Timur Gafarov. Distributed under the Boost Software License, Version 1.0 (see accompanying file COPYING or at https://www.boost.org/LICENSE_1_0.txt).
