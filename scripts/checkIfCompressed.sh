#!/bin/bash

# This script is just a basic check: it checks if all PNG or JPG are "lossless" compressed
# The script sends you a report mail with all the details: the command to launch, the gain in %...

# It's really simple to adapt it as a pre-commit hook to commit only "lossless" compressed images

# Requirements:
#######################################
# install Jpegtran (http://en.wikipedia.org/wiki/Jpegtran)
# apt-get install libjpeg-progs

# install Pngcrush (http://en.wikipedia.org/wiki/Pngcrush)
# apt-get install pngcrush

# Cron sample: 
#######################################
#42 3 * * *	/path/to/checkIfCompressed.sh /data/vhost/ JPG > /data/tmp/compressor/JPG.log 2>&1
#42 4 * * *	/path/to/checkIfCompressed.sh /data/vhost/ PNG > /data/tmp/compressor/PNG.log 2>&1


DIR_TO_PARSE="$1"
TYPE_TO_CHECK="$2"

# define a mail command to recieve the reporting
SENDMAIL_BIN='/usr/sbin/sendmail'
FROM_MAIL_ADDRESS='noreply@aleikoum.net'
RECIPIENT_ADDRESSES="erwan@aleikoum.net"
FROM_MAIL_DISLAY='Lossless Compression Check'
MAIL_SUBJECT="Lossless Compression Detector - $TYPE_TO_CHECK - `date '+%Y/%m/%d %H:%M:%S'`"
MAIL_CMD="$SENDMAIL_BIN -f $FROM_MAIL_ADDRESS -F \"$FROM_MAIL_DISLAY\" $RECIPIENT_ADDRESSES"

TMP_DIR="/data/tmp/compressor/`whoami`"

#######################################

[ ! -d "$TMP_DIR" ] && mkdir -p $TMP_DIR

if [ $TYPE_TO_CHECK != "JPG" ] && [ $TYPE_TO_CHECK != "PNG" ]
then
	echo "ERROR - `date` - usage $0 <repo_directory> <PNG|JPG>"
	exit 1
fi

if [ $TYPE_TO_CHECK == "PNG" ]
then
	FIND_LIST=`find $DIR_TO_PARSE -name "*.png" -type f | grep -v sprites_c`
elif [ $TYPE_TO_CHECK == "JPG" ]
then
	FIND_LIST=`find $DIR_TO_PARSE -name "*.jpeg" -o -name "*.jpg" -type f | grep -v sprites_c`
fi


RETURN_LINE=""
for fileCheck in $FIND_LIST
do
	FILE_ONLY=`basename $fileCheck`
	FILE_LOSSLESS="$TMP_DIR/$FILE_ONLY-LOSSLESS"
	FILE_REPO=`echo $fileCheck | sed -e "s|$DIR_TO_PARSE||g"`
	
	if [ $TYPE_TO_CHECK == "PNG" ]
	then
		pngcrush -rem alla -reduce $fileCheck $FILE_LOSSLESS > /dev/null 2>&1
		STATUS=$?
	elif [ $TYPE_TO_CHECK == "JPG" ]
	then
		jpegtran -copy none -optimize -perfect $fileCheck > $FILE_LOSSLESS 2> /dev/null	
		STATUS=$?
	fi
	
	#test if we succeed to compress the file
	if [ $STATUS -eq 0 ]
	then
		SIZE_NORMAL=`stat -c '%s' $fileCheck`
		SIZE_LOSSLESS=`stat -c '%s' $FILE_LOSSLESS`
		STATUS=$?

		if [ $STATUS -eq 0 ] && [ $SIZE_LOSSLESS -lt $SIZE_NORMAL ]
		then
			PERCENT_GAIN=`perl -E "say 100*(1-($SIZE_LOSSLESS/$SIZE_NORMAL))"`
			echo "OK - `date` - $FILE_REPO - with a reduction of $PERCENT_GAIN%"
			RETURN_LINE="$FILE_REPO|$PERCENT_GAIN\n$RETURN_LINE"
		elif [ $STATUS -eq 0 ] && [ $SIZE_LOSSLESS -gt $SIZE_NORMAL ]
		then
			echo "WARNING - `date` - BIGGER - $FILE_REPO seems to be bigger after compression"
		elif [ $STATUS -eq 0 ] && [ $SIZE_LOSSLESS -eq $SIZE_NORMAL ]
		then
			echo "WARNING - `date` - SAME - $FILE_REPO is the same when is compressed"
		else
			echo "ERROR - `date` - $FILE_REPO problem when trying to compress it"
		fi
	else
		echo "ERROR - `date` - $FILE_REPO problem when trying to compress it"
	fi

done

if [ "$RETURN_LINE" != "" ]
then
	CMD_SAMPLE='pngcrush -rem alla -reduce FILE_TO_COMPRESS FILE_RESULT_LOSSLESS > /dev/null 2>&1'
	[ $TYPE_TO_CHECK == "JPG" ] && CMD_SAMPLE='jpegtran -copy none -optimize -perfect FILE_TO_COMPRESS > FILE_RESULT_LOSSLESS 2> /dev/null'

	(echo "Subject: $MAIL_SUBJECT"; \
		echo -e "MIME-Version: 1.0\nContent-Type: text/html\n"; \
		echo '<pre>'; \
		echo -e "Some images could be compressed!\n"; \
		echo -e "To compress them please use the following command example and finally commit them:"; \
		echo -e "\t$CMD_SAMPLE"; \
		echo -e "\n"; \
		echo -e 'IMAGE_PATH|PERCENT_GAIN'; \
		echo -e "$RETURN_LINE" \
	| eval $MAIL_CMD
fi

exit 0
