#!/bin/sh

pid=$(ps -ef | grep java11 | awk '{print $2}' | sed -n '1p')
echo $pid

if [ ! -r "/proc/${pid}/exe" ] ; then
  echo "Ensure pid=${pid} still exists and sudo is used, eg: sudo -u mesos"
  exit
fi

parsed_java_home=`readlink -f /proc/${pid}/exe | perl -lne 'print $pid if /(.*?)(\/jre)?\/bin\/java$/'`
if [ ! -z "${parsed_java_home}" ] ; then
  JAVA_HOME=$parsed_java_home
fi

if [ -z "$JAVA_HOME" ] ; then
  JAVA_HOME=`readlink -f \`which java 2>/dev/null\` 2>/dev/null | sed 's/\/bin\/java//'`
fi

base_dir="`ps -o args -p ${pid} | perl -lne 'print $pid if /\-Djava\.io\.tmpdir=([a-zA-Z-_0-9.\/]+)\/tmp/'`/logs"
if [ -z "${base_dir}" ] ; then
  base_dir="/usr/share/hubspot/tmp"
fi
heap_dump_file="${base_dir}/java_pid${pid}-$(date +%s).hprof"
$JAVA_HOME/bin/jcmd $pid GC.heap_dump $heap_dump_file
ls $heap_dump_file
