#!/bin/bash +x
# Version: 1.0
# Requirements: bash >= 4.0
# check to monitor events table queue
# needs:
# /etc/snmp/snmpd.conf: extend check-event-table ./check_event_table.sh

export LC_ALL=C

WARN_OPEN_EVENTS=5000
CRIT_OPEN_EVENTS=10000

#START_TIME=`date +"%s%3N"`
OPEN_EVENTS=`timeout 5 /path/to/dbconnect "select count(*) from event-table where done=0"`
PERF_DATA=`timeout 5 /path/to/dbconnect "select RECEPIENT, count(*) from  event-table where done=0 GROUP BY MODULES" | sed 's/ //g' | sed 's/\t/=/' | sed 's/\t//g' | sed 's/$/;;;;/' | sed ':a;N;$!ba;s/\n/ /g'`
OPEN_EVENTS=$(($OPEN_EVENTS/1))
#END_TIME=`date +"%s%3N"`
#TIME_TO_CONNECT=$((($END_TIME-$START_TIME)/2))

#'label'=value[UOM];[warn];[crit];[min];[max]
PERF_VAL="|TOTAL=$OPEN_EVENTS;$WARN_OPEN_EVENTS;$CRIT_OPEN_EVENTS;; $PERF_DATA"
#echo "$PERF_VAL"
OUTPUT="there are $OPEN_EVENTS open events in the event-table."

if  [[ -z $OPEN_EVENTS ]] ; then
        echo "UNKNOWN: something is wrong"
        exit 3
elif [[ "$OPEN_EVENTS" -gt "$CRIT_OPEN_EVENTS" ]] ; then
        echo "CRITICAL: $OUTPUT$PERF_VAL"
        exit 2
elif [[ "$OPEN_EVENTS" -gt "$WARN_OPEN_EVENTS" ]] ; then
        echo "WARNING: $OUTPUT$PERF_VAL"
        exit 1
else
        echo "OK: $OUTPUT$PERF_VAL"
        exit 0
fi
