#/bin/bash

SENDMAIL_BIN='/usr/sbin/sendmail'
FROM_MAIL_ADDRESS='noreply@plop.com'
FROM_MAIL_DISLAY='From Name'
# several addresses could be specified, just separate them by a comma
RECIPIENT_ADDRESSES='mail1@plop.com,mail2@plop.com'

MAIL_SUBJECT="[Test] Simple Mail - `date '+%Y/%m/%d %H:%M:%S'`"
MAIL_CMD="$SENDMAIL_BIN -f $FROM_MAIL_ADDRESS -F \"$FROM_MAIL_DISLAY\" $RECIPIENT_ADDRESSES"
(echo "Subject: $MAIL_SUBJECT"; \
	echo -e "MIME-Version: 1.0\nContent-Type: text/html\n"; \
	echo '<pre>'; \
	echo -e "Simple line\n"; \
	echo -e "\t Line with a tab"; \
	dmesg; \
	echo '</pre>') \
| eval $MAIL_CMD

exit 0
