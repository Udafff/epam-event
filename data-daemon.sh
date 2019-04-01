#!/bin/bash

# Vars
PID_FILE="/tmp/a876c2d7.pid"
ANSWER_FILE="e9ab8a18.lock"


# Show help func
usage()
{
	echo "$0 (start|stop)"
}

# Logging func
_log()
{
	process=$1
	shift
	echo "${process}[$$]: $*"
}

# Stop daemon func
stop()
{
	# If we have PID_FILE then kill parrent process
	if [ -e ${PID_FILE} ]
	then
		_pid=$(cat ${PID_FILE})
		kill $_pid
		rt=$?
		if [ "$rt" == "0" ]
		then
			echo "Daemon stopped"
		else
			echo "Error stop daemon"
		fi
	else
		echo "Daemon isn't running"
	fi
}

# Start daemon funct
start()
{
	# If we have a file with pid then don't start daemon copy
	if [ -e $PID_FILE ]
	then
		_pid=$(cat ${PID_FILE})
		if [ -e /proc/${_pid} ]
		then
			echo "Daemon already running."
			exit 0
		fi
	fi

	# Redirect STDIN, STDOUT, STDERR
	exec < /dev/null

	# Start job copy of process (fork process)
	(
		# Remove parent pid file
		trap  "{ rm -rf ${PID_FILE}; exit 255; }" TERM INT EXIT

		# Open file desriptor
		exec 3<> ${ANSWER_FILE}
		$(pwd)/data-gen

		# Main loop
		while [ 1 ]
		do
			sleep 1
		done
		exit 0
	)&

	# Write pid of created process and exit	
	echo $! > ${PID_FILE}
}

# Daemon commands
case $1 in
	"start")
		start
		;;
	"stop")
		stop
		;;
	*)
		usage
		;;
esac
exit
