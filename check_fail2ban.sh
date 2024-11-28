#!/bin/bash +x
#
# needs:
# /etc/sudoers: Debian-snmp ALL= NOPASSWD:/usr/bin/fail2ban-client
# /etc/snmp/snmpd.conf: extend check-fail2ban ./check_fail2ban_status.sh

CRIT=100
WARN=1

OUTPUT=`sudo /usr/bin/fail2ban-client status sshd`

BAN_NUM=`echo "$OUTPUT" | sed -nE 's/.*Currently banned:(.*)/\1/p' | bc `

if  [[ -z $BAN_NUM ]] ; then
        echo "UNKNOWN: something is wrong"
        exit 3
elif [[ "$BAN_NUM" -ge "$CRIT" ]] ; then
        echo "CRITICAL: $OUTPUT"
        exit 2
elif [[ "$BAN_NUM" -ge "$WARN" ]] ; then
        echo "WARNING: $OUTPUT"
        exit 1
else
        echo "OK: $OUTPUT"
        exit 0
fi
