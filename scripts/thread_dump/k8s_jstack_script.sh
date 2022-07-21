#!/bin/bash
set -e

pid=$(ps -ef | grep java11 | awk '{print $2}' | sed -n '1p')
echo $pid
pwd

for i in {1..3}
do
   filename="jstack$i"
   echo $filename
   jstack $pid > $filename
   sleep 5
done

tar vcfz archive.tar jstack1 jstack2 jstack3

