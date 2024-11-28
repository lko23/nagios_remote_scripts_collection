#!/bin/bash +x
# Version: 1.0
# Requirements: bash >= 4.0
# quick check to monitor files for size and age

export LC_ALL=C

MAX_AGE="600"     # maximum file age in minutes
FILES="/dir/file1 /dir/file2"

UNKNOWN="0"
CRITICAL="0"
WARNING="0"

for FILE in ${FILES}
do
        FILE_NOACCESS="0"
        if [ ! -f ${FILE} ] ; then
                echo "UNKNOWN: ${FILE} is not accessible!"
                FILE_NOACCESS="1"
                UNKNOWN="1"
        fi

        # do checks
        if [[ "$FILE_NOACCESS" == "0" ]] ; then
                OLD_FILE=`find ${FILE} -type f -mmin +${MAX_AGE} | sed 's/^/\t  /'`
                FILE_SIZE=`find ${FILE} -printf %s`

                if [[ "${FILE_SIZE}" -le 0 ]] ; then
                       echo "CRITICAL: The file ${FILE} is empty."
                       CRITICAL="1"
                elif test "${OLD_FILE}" ; then
                        echo -e "WARNING: The file ${FILE} is older than ${MAX_AGE} minutes."
                        WARNING="1"
                else
                        echo "OK: ${FILE} is not older than ${MAX_AGE} minutes and is not empty."
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
