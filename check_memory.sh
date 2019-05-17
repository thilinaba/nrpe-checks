#!/bin/bash

# This script checks the memory "Usage" (not how much left)
# Add the "used memory" percentage in Warn and Critical levels
# Eg: 
# check_memory.sh -w 70 -c 90
#
#    "-w 70" means it will warn you when Used memory goes ABOVE 70%
#    "-c 90" means it will give you a critical alert when Used memory goes Above 90%

USAGE_MSG="`basename $0` [-w|--warning]<percent used> [-c|--critical]<percent used>"
USAGE_EXAMPLE_MSG="`basename $0` -w 75 -c 90"
THRESHOLD_USAGE_MSG="WARNING threshold must be less than CRITICAL threshold"


STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# print usage
if [[ $# -lt 4 ]]
then
    echo "Wrong Syntax: `basename $0` $*"
    echo "Usage: $USAGE_MSG"
    echo "Example: $USAGE_EXAMPLE_MSG"
    exit 0
fi

# read input
while [[ $# -gt 0 ]]
  do
    case "$1" in
            -w|--warning)
            shift
            WARNING_PERCENTAGE=$1
    ;;
            -c|--critical)
            shift
            CRITICAL_PERCENTAGE=$1
    ;;
    esac
    shift
  done

# verify input
if [[ $WARNING_PERCENTAGE -ge $CRITICAL_PERCENTAGE ]]
then
    echo "$THRESHOLD_USAGE_MSG"
    echo "Usage: $USAGE_MSG"
    echo "Example: $USAGE_EXAMPLE_MSG"
    exit 0
fi

MEM_TOTAL=$(cat /proc/meminfo | grep "MemTotal" | awk '{print $2}')
MEM_AVAILABLE=$(cat /proc/meminfo | grep "MemAvailable" | awk '{print $2}')
MEM_USED=$(($MEM_TOTAL-$MEM_AVAILABLE))
MEM_USED_PERCENTAGE=$(($MEM_USED*100/$MEM_TOTAL))

# Debug echos
# echo Tot: $MEM_TOTAL
# echo Avl: $MEM_AVAILABLE
# echo used: $MEM_USED
# echo used pcnt: $MEM_USED_PERCENTAGE

if [[ $MEM_USED_PERCENTAGE -ge  $CRITICAL_PERCENTAGE ]]
    then
        echo "CRITICAL - $(($MEM_USED/1000)) MB ($MEM_USED_PERCENTAGE%) Used Memory"
        exit $STATE_CRITICAL
elif [[ $MEM_USED_PERCENTAGE -ge  $WARNING_PERCENTAGE ]]
then
    echo "WARNING - $(($MEM_USED/1000)) MB ($MEM_USED_PERCENTAGE%) Used Memory"
    exit $STATE_WARNING
else
    echo "OK - $(($MEM_USED/1000)) MB ($MEM_USED_PERCENTAGE%) Used Memory"
    exit $STATE_OK
fi