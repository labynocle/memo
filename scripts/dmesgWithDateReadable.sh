#!/bin/bash

# You want a human readable date in your dmesg?
# not the most efficient way... but it works :)

COMMAND_TO_LAUNCH="dmesg"

while read line; do
	DMESG_DATE=`echo -e "${line}" | sed -e "s/^\[ *\([0-9]*\.[0-9]*\)\] .*$/\1/g"`
	DMESG_MESG=`echo -e "${line}" | sed -e "s/^\[ *[0-9]*\.[0-9]*\] \(.*\)$/\1/g"`
	TIMESTAMP=`date +%s`
	UPTIME=`cut -d' ' -f1 < /proc/uptime`
	HUMAN_DATE=`date -d"70-1-1 + $TIMESTAMP sec - $UPTIME sec + $DMESG_DATE sec" +"%F %T"`
	echo "[$HUMAN_DATE] $DMESG_MESG"
done < <($COMMAND_TO_LAUNCH)

exit 0
