#!/bin/sh
# skript to hash current sudoers config and chech against it
# needs:
# /etc/snmp/snmpd.conf: extend check-sudoers ./check_changes_sudoers.sh

ICINGA_OK="OK"
ICINGA_OK_NUM=0
ICINGA_OK_TXT="sudo is unchanged."
ICINGA_WARNING="WARNING"
ICINGA_WARNING_NUM=1
ICINGA_CRITICAL="CRITICAL"
ICINGA_CRITICAL_NUM=2
ICINGA_UNKNOWN="UNKNOWN"
ICINGA_UNKNOWN_NUM=3

CACHE_DIR="/var/tmp/.`basename "$0"`"
CHECKSUM_FILE="${CACHE_DIR}/sum"

CHECK="/etc/sudoers /etc/sudoers.d"

REPL_FROM="/"
REPL_TO="_"

# replace / with $2
repl_path() {
        echo "$1" | tr "$REPL_FROM" "$2"
}

# md5sum content
md5sum_con() {
        for item in $CHECK
        do
                if [ -f "$item" ]
                then
                        md5sum "$item"
                elif [ -d "$item" ]
                then
                        find "$item" -type f | while read f
                        do
                                md5sum "$f"
                        done
                fi
        done
}

# check sums loop files
check_sums () {
        md5sum_con | diff -y "$CHECKSUM_FILE" - | tr -s " \t" "\t" | cut -f2 | while read f
        do
                if [ -f "$f" ]
                then
                        # Files readable
                        if [ -r "${CACHE_DIR}/$(repl_path "$f" "$REPL_TO")" -a -r "$f" ]
                        then
                                n="`diff "${CACHE_DIR}/$(repl_path "$f" "$REPL_TO")" "$f" | head -n 1 | cut -dc -f1`"
                        else
                                printf "%s:\n" "$ICINGA_UNKNOWN" >&2
                                exit $ICINGA_UNKNOWN_NUM
                                break
                        fi

                        # $n not empty
                        if [ ! -z "$n" ]
                        then
                                printf "Difference in file %s, line %s.\n" "$f" "$n"
                        fi
                fi
        done
}

# Reset
if [ $# -eq 1 -a `echo "$1" | grep -ic "reset"` -eq 1 ]
then
        find "$CACHE_DIR" -type f -print | xargs /bin/rm -f
        echo "reseted ..." >&2
fi

# Create cachedir if not exists.
mkdir -p "$CACHE_DIR"

# Create checksum file if not exists.
if [ ! -f "$CHECKSUM_FILE" ]
then
        list="`md5sum_con`"

        # md5sums (checksum file)
        echo "$list" > "$CHECKSUM_FILE"

        # cache files
        echo "$list" | while read line
        do
                file="`echo "$line" | tr -s " " " " | cut -d' ' -f2`"
                cp "$file" "$CACHE_DIR/`repl_path "$file" "$REPL_TO"`"
        done
        exit $ICINGA_UNKNOWN_NUM
else
        txt="`check_sums`"
        if [ $? -eq $ICINGA_UNKNOWN_NUM ]
        then
                exit $ICINGA_UNKNOWN_NUM
        elif [ -z "$txt" ]
        then
                printf "%s: %s\n" "$ICINGA_OK" "$ICINGA_OK_TXT" >&2
                exit $ICINGA_OK_NUM
        else
                printf "%s: %s\n" "$ICINGA_WARNING" "$txt" >&2
                exit $ICINGA_WARNING_NUM
        fi
fi

printf "%s:\n" "$ICINGA_UNKNOWN" >&2
exit $ICINGA_UNKNOWN_NUM
