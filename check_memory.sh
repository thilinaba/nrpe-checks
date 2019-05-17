USAGE_MSG="`basename $0` [-w|--warning]<percent free> [-c|--critical]<percent free>"
THRESHOLD_USAGE_MSG="WARNING threshold must be greater than CRITICAL: `basename $0` $*"

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3

# print usage
if [[ $# -lt 4 ]]
then
    echo "Wrong Syntax: `basename $0` $*"
    echo "Usage: $USAGE"
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
if [[ $WARNING_PERCENTAGE -le $CRITICAL_PERCENTAGE ]]
then
    echo "$THRESHOLD_USAGE"
    echo "Usage: $USAGE"
    exit 0
fi

MEM_TOTAL=`cat /proc/meminfo | grep "MemTotal" | awk '{print $2}'`
MEM_AVAILABLE=`cat /proc/meminfo | grep "MemAvailable" | awk '{print $2}'`
MEM_AVAILABLE_PERCENTAGE=`expr ($MEMORY_AVAILABLE / $MEM_TOTAL) * 100`

echo Total: $MEM_TOTAL
echo Available: $MEM_AVAILABLE
echo Avl Pcnt: $MEM_AVAILABLE_PERCENTAGE

if [[ $MEM_AVAILABLE_PERCENTAGE -le  $CRITICAL_PERCENTAGE ]]
    then
        echo "CRITICAL - $free MB ($percent%) Free Memory"
        exit 2
elif [[ $MEM_AVAILABLE_PERCENTAGE -le  $WARNING_PERCENTAGE ]]
    echo "WARNING - $free MB ($percent%) Free Memory"
    exit 1
else
    echo "OK - $free MB ($percent%) Free Memory"
    exit 0
fi