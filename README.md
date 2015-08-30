
Background
==========
Wrapper script for a collection of DTrace scripts

read:
* [freebsd.org/doc/handbook/dtrace.html](https://www.freebsd.org/doc/handbook/dtrace.html)
* [wiki.freebsd.org/DTrace](https://wiki.freebsd.org/DTrace)
* [github.com/brendangregg/DTrace-tools](https://github.com/brendangregg/DTrace-tools)
* [github.com/brendangregg/DTrace-book-scripts](https://github.com/brendangregg/DTrace-book-scripts)

WARNING
=======

Dependencies
============
* FreeBSD
   * [shells/ksh93](https://www.freshports.org/shells/ksh93/)
   * [sysutils/DTraceToolkit](https://www.freshports.org/sysutils/DTraceToolkit/)

Features
========
* FreeBSD
  * pmcstat -TS instructions
  * DTrace: Listing Probes
  * DTrace: File Opens
  * DTrace: Syscall Counts By Process
  * DTrace: Distribution of read() Bytes
  * DTrace: Timing read() Syscall
  * DTrace: Measuring CPU Time in read()
  * DTrace: Count Process-Level Events
  * DTrace: Profile On-CPU Kernel Stacks
  * DTrace: Scheduler Tracing
  * DTrace: TCP Inbound Connections
  * DTrace: Raw Kernel Tracing
  * DTraceTool: errinfo

* FreeNAS
  * #

Platform
========
* FreeBSD 10+
* FreeNAS 9.3+ (currently not supported)

Usage
=====
```
    # ./easy_dtrace.sh
```

Screencast
==========

Errata
======
* 28.08.2015:

