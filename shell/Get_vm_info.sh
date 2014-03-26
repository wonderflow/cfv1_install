#!/bin/bash
#puts host 
cat /proc/cpuinfo | grep "processor"|sort|uniq |wc -l
cat /proc/meminfo | grep MemTotal |awk '{print $2}'
df -Ph / | head -3 |tail -1 |awk '{print $1}'
