#!/bin/bash +x
# Version: 1.0
# Requirements: bash >= 4.0
# check many running processes vs. submitted arguments
# needs:
# /etc/snmp/snmpd.conf: extend check-proc ./check_many_proc.sh proc1 proc2 proc3 ...

export LC_ALL=C

LIST_OF_PROCS=$@
LIST_OF_RUNNING_PROCS=""
LIST_OF_NONRUNNING_PROCS=""
PROC_RUNNING=0
PROC_NOT_RUNNING=0

if [[ "$#" -lt 1 ]]; then
        echo "Please pass at least one process name as argument."
        exit 3
fi

for proc_name in $LIST_OF_PROCS ; do
        proc_num=0
        proc_num=$(pgrep -c $proc_name)

        # bash vars do not allow hyphens ('-'); lets translate them to underscores ('_')
        proc_name="$(echo $proc_name | sed 's/-/_/')"

        if [[ "$proc_num" == "0" ]] ; then
                let "PROC_NOT_RUNNING++"
                LIST_OF_NONRUNNING_PROCS="$LIST_OF_NONRUNNING_PROCS $proc_name"
        else
                declare NUMPROC_RUNNING_"${proc_name}"="${proc_num}"
                LIST_OF_RUNNING_PROCS="$LIST_OF_RUNNING_PROCS $proc_name"
                let "PROC_RUNNING++"
        fi
done

if [ "$PROC_NOT_RUNNING" != "0" ] && [ "$PROC_RUNNING" != "0" ] ; then
        echo "WARNING: Number of NOT running processes: $PROC_NOT_RUNNING"
        echo "Not running processes: $LIST_OF_NONRUNNING_PROCS"

        # print running processes as well
        if [ "$PROC_RUNNING" != "0" ] ; then
                echo ""
                echo "Running processes:"
                for proc_name in $LIST_OF_RUNNING_PROCS ; do
                        proc_num=NUMPROC_RUNNING_${proc_name}
                        echo "${proc_name}: ${!proc_num}"
                done
        fi

        exit 1

elif [ "$PROC_RUNNING" == "0" ] ; then
        echo "CRITICAL: Number of NOT running processes: $PROC_NOT_RUNNING"
        echo "Not running processes: $LIST_OF_NONRUNNING_PROCS"
        exit 2

else
        echo "OK: All processes in list '$LIST_OF_PROCS' are running"
        exit 0
fi

echo "UNKNOWN: Configuration is set wrong"
exit 3
