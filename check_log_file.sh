#!/bin/bash +x
# Version: 1.0
# check log error
# needs:
# /etc/snmp/snmpd.conf: extend check-log-file ./check_log_file.sh

export LC_ALL=C

date_h=$(date +'%Y-%m-%d %H')

if OUTPUT=$(grep -A 20 "${date_h}" /path/to/file.log | grep "explicit Error message"); then
        echo "CRITICAL: Errors found:"
        echo "$OUTPUT" | uniq
        exit 2
else
        echo "OK: no Error found."
        exit 0
fi             
