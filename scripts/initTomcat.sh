#!/bin/bash


### BEGIN INIT INFO
# Provides:          tomcat
# Required-Start:    $local_fs $remote_fs $syslog $named $network $time
# Required-Stop:     $local_fs $remote_fs $syslog $named $network
# Should-Start:
# Should-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start/Stop tomcat
### END INIT INFO

# by Erwan Ben Souiden - ebs@deezer.com

# Add this script to the boot:
#	ln -s /PATH/TO/initTomcat /etc/init.d/tomcat
#	update-rc.d tomcat defaults

TOMCAT_USER='YOUR_USER'
TOMCAT_DIR_PATH='/PATH/TO/ROOT/TOMCAT'

# only root could launch the init script
id=$((`/usr/bin/id -u`))
if [ $id -ne 0 ]; then
	echo "ERROR - This command should be launched by root"
	exit 1
fi

case "$1" in
	start)
		echo 'Starting opengrok...'
		if [ -e "$TOMCAT_DIR_PATH/bin/startup.sh" ]
		then
			sudo -u $TOMCAT_USER "$TOMCAT_DIR_PATH/bin/startup.sh"
		else
			echo "ERROR - $TOMCAT_DIR_PATH/bin/startup.sh doesn't seem to exist"
			exit 1
		fi
	;;
	stop)
		echo "Stopping opengrok..."
		if [ -e "$TOMCAT_DIR_PATH/bin/shutdown.sh" ]
		then
			sudo -u $TOMCAT_USER "$TOMCAT_DIR_PATH/bin/shutdown.sh"
		else
			echo "ERROR - $TOMCAT_DIR_PATH/bin/shutdown.sh doesn't seem to exist"
			exit 1
		fi
	;;
	restart)
		$0 stop
		sleep 2
		$0 start
	;;
	*)
		echo "Usage: $0 {start|stop|restart}" 
		exit 1
	;;
esac

exit 0
