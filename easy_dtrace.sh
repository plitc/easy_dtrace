#!/bin/sh

### LICENSE - (BSD 2-Clause) // ###
#
# Copyright (c) 2015, Daniel Plominski (Plominski IT Consulting)
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
# * Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# * Redistributions in binary form must reproduce the above copyright notice, this
# list of conditions and the following disclaimer in the documentation and/or
# other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR
# ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
### // LICENSE - (BSD 2-Clause) ###

### ### ### PLITC // ### ### ###

### stage0 // ###
OSVERSION=$(uname)
FREENAS=$(uname -a | grep -c "ixsystems.com")
JAILED=$(sysctl -a | grep -c "security.jail.jailed: 1")
MYNAME=$(whoami)
DATE=$(date +%Y%m%d-%H%M)
HOSTMACHINE=$(hostname)
#
PRG="$0"
#// need this for relative symlinks
while [ -h "$PRG" ] ;
do
   PRG=$(readlink "$PRG")
done
DIR=$(dirname "$PRG")
#
ADIR="$PWD"
#
#// spinner
spinner()
{
   local pid=$1
   local delay=0.01
   local spinstr='|/-\'
   while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
         local temp=${spinstr#?}
         printf " [%c]  " "$spinstr"
         local spinstr=$temp${spinstr%"$temp"}
         sleep $delay
         printf "\b\b\b\b\b\b"
   done
   printf "    \b\b\b\b"
}
#
#// function: cleanup tmp
cleanup(){
   rm -rf /tmp/easy_dtrace*
}
#
#// function: pkg installation
pkginstall(){
   #/ check package
   CHECKPKG=$(pkg info | grep -c "$@")
   if [ "$CHECKPKG" = "0" ]
   then
      #/ check ports
      CHECKPORTS=$(find /usr/ports -name "$@" | grep -c "$@")
      if [ "$CHECKPORTS" = "0" ]
      then
         pkg update
         pkg install -y "$@"
         if [ $? -eq 0 ]
         then
            : # dummy
         else
            echo "[ERROR] something went wrong, can't install the package"
            exit 1
         fi
      else
         portsnap update
         if [ $? -eq 0 ]
         then
            : # dummy
         else
            echo "[ERROR] something went wrong, can't install the package"
            exit 1
         fi
         GETPATH=$(find /usr/ports -maxdepth 2 -mindepth 2 -name "$@" | tail -n 1)
         cd "$GETPATH" && make install clean
         if [ $? -eq 0 ]
         then
            : # dummy
         else
            echo "[ERROR] something went wrong, can't install the package"
            exit 1
         fi
      fi
   else
      : # dummy
   fi
}
#
### // stage0 ###

case "$1" in
'freebsd')
### stage1 // ###
case $OSVERSION in
FreeBSD)
### stage2 // ###
#
### // stage2 ###

### stage3 // ###
if [ "$MYNAME" = "root" ]
then
   : # dummy
else
   echo "[ERROR] You must be root to run this script"
   exit 1
fi
if [ "$JAILED" = "0" ]
then
   : # dummy
else
   echo "[ERROR] Run this script on the FreeBSD HOST"
   exit 1
fi
if [ "$FREENAS" = "1" ]
then
   echo "[ERROR] FreeBSD only support"
   exit 1
else
   : # dummy
fi
### stage4 // ###
#
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###

#/ pkg install: ksh93
(pkginstall ksh93) & spinner $!

#/ pkg install: DTraceToolkit
(pkginstall DTraceToolkit) & spinner $!

#/ DTrace Kernel Support
CHECKDTRACE=$(kldstat | grep -c "dtraceall")
if [ "$CHECKDTRACE" = "0" ]
then
   kldload dtraceall
fi

#/ FlameGraph
mkdir -p "$ADIR"/tmp
if [ -e "$ADIR"/tmp/FlameGraph ]
then
   echo "--- update FlameGraph // --->"
   (cd "$ADIR"/tmp; git pull) & spinner $!
else
   echo "--- fetch FlameGraph // --->"
   (cd "$ADIR"/tmp; git clone https://github.com/brendangregg/FlameGraph.git) & spinner $!
   if [ $? -eq 0 ]
   then
      : # dummy
   else
      echo "[ERROR] can't fetch brendangregg/FlameGraph from github!"
      exit 1
   fi
fi

#/ DTrace & More Functions
echo "" # dummy
echo "Choose the (dtrace) function:"
echo "1)  pmcstat -TS instructions              13) DTraceTool: errinfo                                 |  #"
echo "2)  DTrace: Listing Probes                14) DTraceTool: cpu/cpuwalk                             |  #"
echo "3)  DTrace: File Opens                    15) FlameGraph: DTrace stacks - capture 60 seconds      |  #"
echo "4)  DTrace: Syscall Counts By Process     16) FlameGraph: pmcstat -G stacks - capture 60 seconds  |  #"
echo "5)  DTrace: Distribution of read() Bytes  |  #"
echo "6)  DTrace: Timing read() Syscall         |  #"
echo "7)  DTrace: Measuring CPU Time in read()  |  #"
echo "8)  DTrace: Count Process-Level Events    |  #"
echo "9)  DTrace: Profile On-CPU Kernel Stacks  |  #"
echo "10) DTrace: Scheduler Tracing             |  #"
echo "11) DTrace: TCP Inbound Connections       |  #"
echo "12) DTrace: Raw Kernel Tracing            |  #"
echo "" # dummy

read -r FUNCTION;
if [ -z "$FUNCTION" ]; then
   echo "[ERROR] nothing selected"
   exit 1
fi

case $FUNCTION in
   1) echo "(select) pmcstat -TS instructions"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      CHECKHWPMC=$(kldstat | grep -c "hwpmc")
      if [ "$CHECKHWPMC" = "0" ]
      then
         kldload hwpmc
      fi
      #/ RUN
      pmcstat -TS instructions -w 1
   ;;
   2) echo "(select) DTrace: Listing Probes"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -l | grep 'syscall.*read'
   ;;
   3) echo "(select) DTrace: File Opens"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall::open*:entry { printf("%s %s", execname, copyinstr(arg0)); }'
   ;;
   4) echo "(select) DTrace: Syscall Counts By Process"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall:::entry { @[execname, probefunc] = count(); }'
   ;;
   5) echo "(select) DTrace: Distribution of read() Bytes"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      echo "Please enter the process name:"
      read -r PROCESSNAME;
      if [ -z "$PROCESSNAME" ]
      then
         echo "[ERROR] empty name"
         exit 1
      fi
      #/ RUN
      dtrace -n 'syscall::read:return /execname == "'$PROCESSNAME'"/ { @ = quantize(arg0); }'
   ;;
   6) echo "(select) DTrace: Timing read() Syscall"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall::read:entry { self->ts = timestamp; } syscall::read:return /self->ts/ {
      @ = quantize(timestamp - self->ts); self->ts = 0; }'
   ;;
   7) echo "(select) DTrace: Measuring CPU Time in read()"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall::read:entry { self->vts = vtimestamp; } syscall::read:return /self->vts/ {
      @["On-CPU us:"] = lquantize((vtimestamp - self->vts) / 1000, 0, 10000, 10); self->vts = 0; }'
   ;;
   8) echo "(select) DTrace: Count Process-Level Events"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'proc::: { @[probename] = count(); } tick-5s { exit(0); }'
   ;;
   9) echo "(select) DTrace: Profile On-CPU Kernel Stacks"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -x stackframes=100 -n 'profile-99 /arg0/ { @[stack()] = count(); }'
   ;;
  10) echo "(select) DTrace: Scheduler Tracing"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'sched:::off-cpu { @[stack(8)] = count(); }'
   ;;
  11) echo "(select) DTrace: TCP Inbound Connections"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'tcp:::accept-established { @[args[3]->tcps_raddr] = count(); }'
   ;;
  12) echo "(select) DTrace: Raw Kernel Tracing"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'fbt::vmem_alloc:entry { @[curthread->td_name, args[0]->vm_name] = sum(arg1); }'
   ;;
  13) echo "(select) DTraceTool: errinfo"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' /usr/local/share/DTraceToolkit/errinfo > /usr/local/share/DTraceToolkit/errinfo_freebsd) & spinner $!
      (chmod 0755 /usr/local/share/DTraceToolkit/errinfo_freebsd) & spinner $!
      /usr/local/share/DTraceToolkit/errinfo_freebsd
   ;;
  14) echo "(select) DTraceTool: cpu/cpuwalk"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d > /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d_freebsd) & spinner $!
      (chmod 0755 /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d_freebsd) & spinner $!
      /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d_freebsd
   ;;
  15) echo "(select) FlameGraph: DTrace stacks - capture 60 seconds"
      echo "" # dummy
      echo "(info) Using DTrace to capture 60 seconds of kernel stacks at 997 Hertz"
      echo "(info) Hit Ctrl-C to abort"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      (dtrace -x stackframes=100 -n 'profile-997 /arg0/ { @[stack()] = count(); } tick-60s { exit(0); }' -o "$ADIR"/tmp/out.kern_stacks) & spinner $!
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' "$ADIR"/tmp/FlameGraph/stackcollapse.pl > "$ADIR"/tmp/FlameGraph/stackcollapse_freebsd.pl) & spinner $!
      (chmod 0755 "$ADIR"/tmp/FlameGraph/stackcollapse_freebsd.pl) & spinner $!
      ("$ADIR"/tmp/FlameGraph/stackcollapse_freebsd.pl "$ADIR"/tmp/out.kern_stacks > "$ADIR"/tmp/out.kern_folded) & spinner $!
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' "$ADIR"/tmp/FlameGraph/flamegraph.pl > "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      (chmod 0755 "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      ("$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl "$ADIR"/tmp/out.kern_folded > "$ADIR"/tmp/"$HOSTMACHINE"_kernel.svg) & spinner $!
      echo "" # dummy
      printf "\033[1;32m look at $ADIR/tmp/%s_kernel.svg\033[0m\n" "$HOSTMACHINE"
   ;;
  16) echo "(select) FlameGraph: pmcstat -G stacks - capture 60 seconds"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to abort"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      #/ (pmcstat -l 60 -S unhalted-cycles -O "$ADIR"/tmp/pmc.out; if [ $? -eq 0 ]; then export PMCSTAT="0"; else export PMCSTAT="1"; exit 71; fi) & spinner $!
      #/ CHECKPMCSTAT=$(echo $PMCSTAT | grep -c "1")
      #/ if [ "$CHECKPMCSTAT" = "1" ]
      #/ then
      #/    echo "[ERROR] something went wrong"
      #/    exit 1
      #/ fi
      pmcstat -l 60 -S unhalted-cycles -O "$ADIR"/tmp/pmc.out
      if [ $? -eq 0 ]
      then
         : # dummy
      else
         echo "[ERROR] something went wrong"
         exit 1
      fi
      (pmcstat -R "$ADIR"/tmp/pmc.out -z16 -G "$ADIR"/tmp/pmc.graph) & spinner $!
      ("$ADIR"/tmp/FlameGraph/stackcollapse-pmc.pl "$ADIR"/tmp/pmc.graph > "$ADIR"/tmp/pmc.stack) & spinner $!
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' "$ADIR"/tmp/FlameGraph/flamegraph.pl > "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      (chmod 0755 "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      ("$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl "$ADIR"/tmp/pmc.stack > "$ADIR"/tmp/"$HOSTMACHINE"_pmc.svg) & spinner $!
      echo "" # dummy
      printf "\033[1;32m look at $ADIR/tmp/%s_pmc.svg\033[0m\n" "$HOSTMACHINE"
   ;;
esac



### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
cleanup
### ### ### ### ### ### ### ### ###
echo "" # printf
printf "\033[1;31measy_dtrace for FreeBSD finished.\033[0m\n"
### ### ### ### ### ### ### ### ###
#
### // stage4 ###
#
### // stage3 ###
#
### // stage2 ###
   ;;
*)
   # error 1
   : # dummy
   : # dummy
   echo "[ERROR] Plattform = unknown"
   exit 1
   ;;
esac
#
### // stage1 ###
;;
'freenas')
### stage1 // ###
case $OSVERSION in
FreeBSD)
### stage2 // ###
#
### // stage2 ###

### stage3 // ###
if [ "$MYNAME" = "root" ]
then
   : # dummy
else
   echo "[ERROR] You must be root to run this script"
   exit 1
fi
if [ "$JAILED" = "0" ]
then
   : # dummy
else
   echo "[ERROR] Run this script on the FreeBSD HOST"
   exit 1
fi
if [ "$FREENAS" = "1" ]
then
   : # dummy
else
   echo "[ERROR] FreeNAS only support"
   exit 1
fi
### stage4 // ###
#
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###

#/ DTrace Kernel Support
CHECKDTRACE=$(kldstat | grep -c "dtraceall")
if [ "$CHECKDTRACE" = "0" ]
then
   kldload dtraceall
fi

#/ FlameGraph
mkdir -p "$ADIR"/tmp
if [ -e "$ADIR"/tmp/FlameGraph ]
then
   echo "--- update FlameGraph // --->"
   (cd "$ADIR"/tmp; git pull) & spinner $!
else
   echo "--- fetch FlameGraph // --->"
   (cd "$ADIR"/tmp; git clone https://github.com/brendangregg/FlameGraph.git) & spinner $!
   if [ $? -eq 0 ]
   then
      : # dummy
   else
      echo "[ERROR] can't fetch brendangregg/FlameGraph from github!"
      exit 1
   fi
fi

#/ DTrace & More Functions
echo "" # dummy
echo "Choose the (dtrace) function:"
echo "1)  pmcstat -TS instructions (load hwpmc.ko!)  13) ***                                                                  |  #"
echo "2)  DTrace: Listing Probes                     14) ***                                                                  |  #"
echo "3)  DTrace: File Opens                         15) FlameGraph: DTrace stacks - capture 60 seconds                       |  #"
echo "4)  DTrace: Syscall Counts By Process          16) FlameGraph: pmcstat -G stacks - capture 60 seconds (load hwpmc.ko!)  |  #"
echo "5)  DTrace: Distribution of read() Bytes       |  #"
echo "6)  DTrace: Timing read() Syscall              |  #"
echo "7)  DTrace: Measuring CPU Time in read()       |  #"
echo "8)  DTrace: Count Process-Level Events         |  #"
echo "9)  DTrace: Profile On-CPU Kernel Stacks       |  #"
echo "10) DTrace: Scheduler Tracing                  |  #"
echo "11) DTrace: TCP Inbound Connections            |  #"
echo "12) DTrace: Raw Kernel Tracing                 |  #"
echo "" # dummy

read -r FUNCTION;
if [ -z "$FUNCTION" ]; then
   echo "[ERROR] nothing selected"
   exit 1
fi

case $FUNCTION in
   1) echo "(select) pmcstat -TS instructions"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      CHECKFREENASVERSION=$(uname -a | grep -c "9.3")
      if [ "$CHECKFREENASVERSION" = "1" ]
      then
         CHECKKERNELMHASH=$(sha256 -q "$ADIR"/freenas_9.3p26_amd64/hwpmc.ko)
         if [ "$CHECKKERNELMHASH" = "089f19141b1c95d9187e6f269b3508b749471fbad8781872de2733b7f238e372" ]
         then
            CHECKHWPMC=$(kldstat | grep -c "hwpmc")
            if [ "$CHECKHWPMC" = "0" ]
            then
               printf "\033[1;33m load hwpmc.ko!\033[0m\n"
               kldload "$ADIR"/freenas_9.3p26_amd64/hwpmc.ko
               echo "" # dummy
               sleep 1
            fi
         else
            echo "[ERROR] hwpmc.ko Kernel Module mismatch!"
            exit 1
         fi
      else
         echo "[ERROR] only for FreeNAS 9.3"
         exit 1
      fi
      #/ RUN
      pmcstat -TS instructions -w 1
      if [ "$CHECKHWPMC" = "1" ]
      then
         echo "" # dummy
         printf "\033[1;33m unload hwpmc.ko!\033[0m\n"
         kldunload hwpmc.ko
      fi
   ;;
   2) echo "(select) DTrace: Listing Probes"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -l | grep 'syscall.*read'
   ;;
   3) echo "(select) DTrace: File Opens"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall::open*:entry { printf("%s %s", execname, copyinstr(arg0)); }'
   ;;
   4) echo "(select) DTrace: Syscall Counts By Process"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall:::entry { @[execname, probefunc] = count(); }'
   ;;
   5) echo "(select) DTrace: Distribution of read() Bytes"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      echo "Please enter the process name:"
      read -r PROCESSNAME;
      if [ -z "$PROCESSNAME" ]
      then
         echo "[ERROR] empty name"
         exit 1
      fi
      #/ RUN
      dtrace -n 'syscall::read:return /execname == "'$PROCESSNAME'"/ { @ = quantize(arg0); }'
   ;;
   6) echo "(select) DTrace: Timing read() Syscall"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall::read:entry { self->ts = timestamp; } syscall::read:return /self->ts/ {
      @ = quantize(timestamp - self->ts); self->ts = 0; }'
   ;;
   7) echo "(select) DTrace: Measuring CPU Time in read()"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'syscall::read:entry { self->vts = vtimestamp; } syscall::read:return /self->vts/ {
      @["On-CPU us:"] = lquantize((vtimestamp - self->vts) / 1000, 0, 10000, 10); self->vts = 0; }'
   ;;
   8) echo "(select) DTrace: Count Process-Level Events"
      echo "" # dummy
      echo "(info) "
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'proc::: { @[probename] = count(); } tick-5s { exit(0); }'
   ;;
   9) echo "(select) DTrace: Profile On-CPU Kernel Stacks"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -x stackframes=100 -n 'profile-99 /arg0/ { @[stack()] = count(); }'
   ;;
  10) echo "(select) DTrace: Scheduler Tracing"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'sched:::off-cpu { @[stack(8)] = count(); }'
   ;;
  11) echo "(select) DTrace: TCP Inbound Connections"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'tcp:::accept-established { @[args[3]->tcps_raddr] = count(); }'
   ;;
  12) echo "(select) DTrace: Raw Kernel Tracing"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to end"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      dtrace -n 'fbt::vmem_alloc:entry { @[curthread->td_name, args[0]->vm_name] = sum(arg1); }'
   ;;
  13) #/ echo "(select) DTraceTool: errinfo"
      #/ echo "" # dummy
      #/ echo "(info) Hit Ctrl-C to end"
      #/ echo "" # dummy
      #/ echo "(starting)"
      #/ echo "" # dummy
      #/ sleep 2
      #/ : # dummy
      #/ #/ RUN
      #/ (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' /usr/local/share/DTraceToolkit/errinfo > /usr/local/share/DTraceToolkit/errinfo_freebsd) & spinner $!
      #/ (chmod 0755 /usr/local/share/DTraceToolkit/errinfo_freebsd) & spinner $!
      #/ /usr/local/share/DTraceToolkit/errinfo_freebsd
      : # dummy
   ;;
  14) #/ echo "(select) DTraceTool: cpu/cpuwalk"
      #/ echo "" # dummy
      #/ echo "(info) Hit Ctrl-C to end"
      #/ echo "" # dummy
      #/ echo "(starting)"
      #/ echo "" # dummy
      #/ sleep 2
      #/ : # dummy
      #/ #/ RUN
      #/ (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d > /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d_freebsd) & spinner $!
      #/ (chmod 0755 /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d_freebsd) & spinner $!
      #/ /usr/local/share/DTraceToolkit/Cpu/cpuwalk.d_freebsd
      : # dummy
   ;;
  15) echo "(select) FlameGraph: DTrace stacks - capture 60 seconds"
      echo "" # dummy
      echo "(info) Using DTrace to capture 60 seconds of kernel stacks at 997 Hertz"
      echo "(info) Hit Ctrl-C to abort"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      #/ RUN
      (dtrace -x stackframes=100 -n 'profile-997 /arg0/ { @[stack()] = count(); } tick-60s { exit(0); }' -o "$ADIR"/tmp/out.kern_stacks) & spinner $!
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' "$ADIR"/tmp/FlameGraph/stackcollapse.pl > "$ADIR"/tmp/FlameGraph/stackcollapse_freebsd.pl) & spinner $!
      (chmod 0755 "$ADIR"/tmp/FlameGraph/stackcollapse_freebsd.pl) & spinner $!
      ("$ADIR"/tmp/FlameGraph/stackcollapse_freebsd.pl "$ADIR"/tmp/out.kern_stacks > "$ADIR"/tmp/out.kern_folded) & spinner $!
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' "$ADIR"/tmp/FlameGraph/flamegraph.pl > "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      (chmod 0755 "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      ("$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl "$ADIR"/tmp/out.kern_folded > "$ADIR"/tmp/"$HOSTMACHINE"_kernel.svg) & spinner $!
      echo "" # dummy
      printf "\033[1;32m look at $ADIR/tmp/%s_kernel.svg\033[0m\n" "$HOSTMACHINE"
   ;;
  16) echo "(select) FlameGraph: pmcstat -G stacks - capture 60 seconds"
      echo "" # dummy
      echo "(info) Hit Ctrl-C to abort"
      echo "" # dummy
      echo "(starting)"
      echo "" # dummy
      sleep 2
      : # dummy
      CHECKFREENASVERSION=$(uname -a | grep -c "9.3")
      if [ "$CHECKFREENASVERSION" = "1" ]
      then
         CHECKKERNELMHASH=$(sha256 -q "$ADIR"/freenas_9.3p26_amd64/hwpmc.ko)
         if [ "$CHECKKERNELMHASH" = "089f19141b1c95d9187e6f269b3508b749471fbad8781872de2733b7f238e372" ]
         then
            CHECKHWPMC=$(kldstat | grep -c "hwpmc")
            if [ "$CHECKHWPMC" = "0" ]
            then
               printf "\033[1;33m load hwpmc.ko!\033[0m\n"
               kldload "$ADIR"/freenas_9.3p26_amd64/hwpmc.ko
               echo "" # dummy
            fi
         else
            echo "[ERROR] hwpmc.ko Kernel Module mismatch!"
            exit 1
         fi
      else
         echo "[ERROR] only for FreeNAS 9.3"
         exit 1
      fi
      #/ RUN
      (pmcstat -l 60 -S unhalted-cycles -O "$ADIR"/tmp/pmc.out) & spinner $!
      (pmcstat -R "$ADIR"/tmp/pmc.out -z16 -G "$ADIR"/tmp/pmc.graph) & spinner $!
      ("$ADIR"/tmp/FlameGraph/stackcollapse-pmc.pl "$ADIR"/tmp/pmc.graph > "$ADIR"/tmp/pmc.stack) & spinner $!
      (sed 's/\/usr\/bin\/perl/\/usr\/local\/bin\/perl/g' "$ADIR"/tmp/FlameGraph/flamegraph.pl > "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      (chmod 0755 "$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl) & spinner $!
      ("$ADIR"/tmp/FlameGraph/flamegraph_freebsd.pl "$ADIR"/tmp/pmc.stack > "$ADIR"/tmp/"$HOSTMACHINE"_pmc.svg) & spinner $!
      echo "" # dummy
      printf "\033[1;32m look at $ADIR/tmp/%s_pmc.svg\033[0m\n" "$HOSTMACHINE"
      CHECKHWPMC=$(kldstat | grep -c "hwpmc")
      if [ "$CHECKHWPMC" = "1" ]
      then
         echo "" # dummy
         printf "\033[1;33m unload hwpmc.ko!\033[0m\n"
         kldunload hwpmc.ko
      fi
   ;;
esac



### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
### ### ### ### ### ### ### ### ###
cleanup
### ### ### ### ### ### ### ### ###
echo "" # printf
printf "\033[1;31measy_dtrace for FreeNAS finished.\033[0m\n"
### ### ### ### ### ### ### ### ###
#
### // stage4 ###
#
### // stage3 ###
#
### // stage2 ###
   ;;
*)
   # error 1
   : # dummy
   : # dummy
   echo "[ERROR] Plattform = unknown"
   exit 1
   ;;
esac
#
### // stage1 ###
;;
*)
printf "\033[1;31mWARNING: easy_dtrace is experimental and its not ready for production. Do it at your own risk.\033[0m\n"
echo "" # usage
echo "usage: $0 { freebsd | freenas }"
;;
esac
exit 0
### ### ### PLITC ### ### ###
# EOF
