#!/bin/bash +x
# Version: 1.0
# Requirements: bash >= 4.0
# quick check to monitor import/export directories
# needs:
# /etc/snmp/snmpd.conf: extend file-olderthan ./check_file_olderthan.sh

export LC_ALL=C

MAX_AGE="5"     # maximum file age in minutes
MAX_FILES="30"  # maximum number of files
PARENT_DIRS="/path/to/dir1 /path/to/dir2"

UNKNOWN="0"
CRITICAL="0"
WARNING="0"

for DIR in ${PARENT_DIRS}
do
        DIR_NOACCESS="0"
        #test -d ${DIR} || echo "UNKNOWN: ${DIR} is not accessible!" && DIR_NOACCESS="1" && UNKNOWN="1"
        #test -d ${DIR} || echo "UNKNOWN: ${DIR} is not accessible!" && DIR_NOACCESS="1" && UNKNOWN="1"
        if [ ! -d ${DIR} ] ; then
                echo "UNKNOWN: ${DIR} is not accessible!"
                DIR_NOACCESS="1"
                UNKNOWN="1"
        fi

        # do checks
        if [[ "$DIR_NOACCESS" == "0" ]] ; then
                # find all files in $DIR older then $MAX_AGE ending in '.extensionl', '*.extension2' or '*.extension3'
                OLD_FILES=`find ${DIR} \( -iname '*.extensionl' -o -iname '*.extension2' -o -iname '*.extension3' \) -type f -mmin +${MAX_AGE} | sed 's/^/\t  /'`
                NUM_OLDFILES=`echo ${OLD_FILES} | tr ' ' '\n' | wc -l`

                if [[ "${NUM_OLDFILES}" -gt "${MAX_FILES}" ]] ; then
                        echo "CRITICAL: ${DIR} holds ${NUM_OLDFILES} files (>${MAX_FILES}) older than ${MAX_AGE} minutes!"
                        CRITICAL="1"
                elif test "${OLD_FILES}" ; then
                        echo -e "WARNING: The following files are older than ${MAX_AGE} minutes: \n${OLD_FILES}"
                        WARNING="1"
                else
                        echo "OK: ${DIR} contains no files older than ${MAX_AGE} minutes."
                fi
        fi
done

if [[ "$UNKNOWN" == "1" ]] ; then
        exit 3
elif [[ "$CRITICAL" == "1" ]] ; then
        exit 2
elif [[ "$WARNING" == "1" ]] ; then
        exit 1
else
        exit 0
fi
