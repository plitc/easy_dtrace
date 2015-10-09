
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
  * DTraceTool: cpu/cpuwalk
  * FlameGraph: DTrace stacks - capture 60 seconds

* FreeNAS
  * ...

Platform
========
* FreeBSD 10+
* FreeNAS 9.3+ (currently not supported)

Usage
=====
```
    # ./easy_dtrace.sh freebsd

Choose the (dtrace) function:
1)  pmcstat -TS instructions              13) DTraceTool: errinfo                                 |  #
2)  DTrace: Listing Probes                14) DTraceTool: cpu/cpuwalk                             |  #
3)  DTrace: File Opens                    15) FlameGraph: DTrace stacks - capture 60 seconds      |  #
4)  DTrace: Syscall Counts By Process     16) FlameGraph: pmcstat -G stacks - capture 60 seconds  |  #
5)  DTrace: Distribution of read() Bytes  |  #
6)  DTrace: Timing read() Syscall         |  #
7)  DTrace: Measuring CPU Time in read()  |  #
8)  DTrace: Count Process-Level Events    |  #
9)  DTrace: Profile On-CPU Kernel Stacks  |  #
10) DTrace: Scheduler Tracing             |  #
11) DTrace: TCP Inbound Connections       |  #
12) DTrace: Raw Kernel Tracing            |  #

```

Screencast
==========

Errata
======
* 28.08.2015:

