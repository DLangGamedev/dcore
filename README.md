dcore
=====
A low level general-purpose library for D language.

* `betterC` compliant
* Independent from Phobos for core functionality. Uses only `betterC` parts of Phobos, like `std.traits` and system APIs
* Will become a minimal standard library: include standard I/O, math, data manipulation, etc
* Possible support for bare metal/WebAssembly/ARM
* Extensive unit testing

Progress
--------
* [x] `dcore.memory` - memory allocator for D objects (classic `New`/`Delete`)
* [ ] `dcore.stdio` - standard C I/O for platforms that support it
* [ ] `dcore.stdlib` - `malloc/free` for platforms that support it
* [ ] `dcore.math` - highly portable math functions, using hardware optimizations where possible
* [ ] `dcore.random` - presudo-random number generator based on C `rand`
* [x] `dcore.sys` - retrieve system information
* [ ] `dcore.process` - cross-platform process API
* [ ] `dcore.time` - cross-platform date and time API
* [ ] `dcore.thread` - cross-platform multithreading API
* [x] `dcore.mutex` - cross-platform thread synchronization primitive
* [ ] `dcore.linker` - cross-platform dynamic library linker
* [ ] `dcore.text` - string processing, UTF-8 decoder
* [ ] `dcore.container` - `betterC` containers and data structures
