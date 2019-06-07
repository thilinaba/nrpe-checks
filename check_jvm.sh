#!/bin/bash

JAVA_HOME=/opt/jdk
PID_FILE=/opt/wso2/wso2am-analytics-2.1.0/wso2carbon.pid

PID=$(cat $PID_FILE)

POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"
case $key in
   -c|--critical)
   CRITICAL="$2"
   shift # past argument
   shift # past value
   ;;
   -w|--warning)
   WARNING="$2"
   shift # past argument
   shift # past value
   ;;
   --default)
   DEFAULT=YES
   shift # past argument
   ;;
   *)  # unknown option
   POSITIONAL+=("$1") # save it in an array for later
   shift # past argument
   ;;
esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters


currentHeapUsage=$($JAVA_HOME/bin/jstat -gc $PID | tail -n 1 | /usr/bin/awk '{split($0,a," "); sum=(a[3]+a[4]+a[6]+a[8]+a[10]+a[12])/1024; print sum" MB"}' | /usr/bin/cut -d " " -f 1 | /usr/bin/cut -d "." -f 1)
totalAllocatedHeap=$($JAVA_HOME/bin/jps -lvm | grep Xmx | /usr/bin/cut -d " " -f 5 | /usr/bin/cut -d "x" -f 2 | /usr/bin/cut -d "m" -f 1 | /usr/bin/cut -d "." -f 1)

currentHeapUsagex100=$(($currentHeapUsage * 100))
HeapUsagePrecentage=$(($currentHeapUsagex100/$totalAllocatedHeap))

if [ $HeapUsagePrecentage -gt $CRITICAL ]; then
       printf "CRITICAL - JVM HEAP usage %s Mb ; Total allocated memory for JVM is %s Mb; Used memory as a presentage of Total allocated memory is %s" "$currentHeapUsage" "$totalAllocatedHeap" "$HeapUsagePrecentage"
       exit 2
fi
if [ $HeapUsagePrecentage -gt $WARNING ]; then
       printf "WARNING - JVM HEAP usage %s Mb ; Total allocated memory for JVM is %s Mb; Used memory as a presentage of Total allocated memory is %s" "$currentHeapUsage" "$totalAllocatedHeap" "$HeapUsagePrecentage"
       exit 1
fi
if [ $HeapUsagePrecentage -lt $WARNING ]; then
       printf "OK - JVM HEAP usage %s Mb ; Total allocated memory for JVM is %s Mb; Used memory as a presentage of Total allocated memory is %s" "$currentHeapUsage" "$totalAllocatedHeap" "$HeapUsagePrecentage"
       exit 0
fi