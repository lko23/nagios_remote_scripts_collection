#!/bin/bash +x
# Version: 1.0
# Requirements: bash >= 4.0
# check to monitor different performance values
# needs:
# /etc/snmp/snmpd.conf: extend check-performance ./check_performance.sh

export LC_ALL=C

HOSTNAME_DB_SERVER="db.domain.tld"
HOSTNAME_APP_SERVER="app.domain.tld"

WARN_CONNECT=600
CRIT_CONNECT=900

WARN_PING=15
CRIT_PING=30

#DB Connect Time
START_TIME=`date +"%s%3N"`
DB_RETURN=`timeout 5 /path/to/dbconnect "select username from USERS where USERNAME='admin'"`
END_TIME=`date +"%s%3N"`
TIME_TO_DB=$((($END_TIME-$START_TIME)/1))

#DB Connect Time Shared Server
START_TIME=`date +"%s%3N"`
DB_RETURN=`timeout 5 /path/to/dbconnect_shared_server "select username from USERS where USERNAME='admin'"`
END_TIME=`date +"%s%3N"`
TIME_TO_DB_SHARED=$((($END_TIME-$START_TIME)/1))

#DB Ping Time
PING_TIME_DB=`ping $HOSTNAME_DB_SERVER -c 1 -i 0.1 | tail -1| awk '{print $4}' | cut -d '/' -f 2`

#SMB Connect Time to App Server
START_TIME=`date +"%s%3N"`
SMB_STATUS=`timeout 5 smbclient //$HOSTNAME_APP_SERVER/share$ -U domain/user%pw<< EOSMB
                cd tools
                ls
                exit
EOSMB`
END_TIME=`date +"%s%3N"`
TIME_TO_SMB=$((($END_TIME-$START_TIME)/1))

#Connect to APP API by HTTPS
TIME_TO_HTTPS=`timeout 5 curl --write-out %{time_total}  --silent --output /dev/null https://$HOSTNAME_APP_SERVER/app/api/version`
TIME_TO_HTTPS=$(expr $TIME_TO_HTTPS*1000/1 | bc)

# App Server Ping Time
PING_TIME_APP=`ping $HOSTNAME_APP_SERVER -c 1 -i 0.1 | tail -1| awk '{print $4}' | cut -d '/' -f 2`

#'label'=value[UOM];[warn];[crit];[min];[max]
PERF_VAL="|time_to_connect_db="$TIME_TO_DB"ms;$WARN_CONNECT;$CRIT_CONNECT;; time_to_connect_db_shared="$TIME_TO_DB_SHARED"ms;$WARN_CONNECT;$CRIT_CONNECT;; time_to_ping_db="$PING_TIME_DB"ms;$WARN_PING;$CRIT_PING;; time_to_smb="$TIME_TO_SMB"ms;$WARN_CONNECT;$CRIT_CONNECT;; time_to_https="$TIME_TO_HTTPS"ms;$WARN_CONNECT;$CRIT_CONNECT;; time_to_ping_app="$PING_TIME_APP"ms;$WARN_PING;$CRIT_PING;;"
#echo "$PERF_VAL"
OUTPUT="Time to connect to DB is $TIME_TO_DB ms, time to connect to DB by shared server is $TIME_TO_DB_SHARED ms, time to ping DB is $PING_TIME_DB ms, time to connect to app server by SMB is $TIME_TO_SMB ms, time to connect to web server by https is $TIME_TO_HTTPS ms and time to ping app server is $PING_TIME_APP ms."

if  [[ -z $ODA_RETURN || -z $TIME_TO_DB || -z $TIME_TO_DB_SHARED || -z $PING_TIME_DB || -z $TIME_TO_SMB || -z $PING_TIME_APP || -z $SMB_STATUS || -z $TIME_TO_HTTPS ]] ; then
        echo "UNKNOWN: something is wrong"
        exit 3
elif [[ "$TIME_TO_DB" -gt "$CRIT_CONNECT" || "$TIME_TO_DB_SHARED" -gt "$CRIT_CONNECT" || `printf -v int %.0f "$PING_TIME_DB"` -gt "$CRIT_PING" || `printf -v int %.0f "$PING_TIME_APP"` -gt "$CRIT_PING" || "$TIME_TO_HTPS" -gt "$CRIT_CONNECT" || "$TIME_TO_SMB" -gt "$CRIT_CONNECT" ]] ; then
        echo "CRITICAL: $OUTPUT$PERF_VAL"
        exit 2
elif [[ "$TIME_TO_DB" -gt "$WARN_CONNECT" || "$TIME_TO_DB_SHARED" -gt "$WARN_CONNECT" || `printf -v int %.0f "$PING_TIME_DB"` -gt "$WARN_PING" || `printf -v int %.0f "$PING_TIME_APP"` -gt "$WARN_PING" || "$TIME_TO_HTTPS" -gt "$WARN_CONNECT" || "$TIME_TO_SMB" -gt "$WARN_CONNECT" ]] ; then
        echo "WARNING: $OUTPUT$PERF_VAL"
        exit 1
else
        echo "OK: $OUTPUT$PERF_VAL"
        exit 0
fi
