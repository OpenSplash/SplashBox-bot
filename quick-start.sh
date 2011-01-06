#!/bin/bash
ABS_PATH=`readlink -f $0`
ABS_BASE=`dirname $ABS_PATH`

ls $ABS_BASE/service/aiml/*.aiml > /dev/null
if [ $? -ne 0 ]; then
	cd $ABS_BASE/service/aiml
	echo " ==== Downloading AIML ==== " >&2
	sleep 2
	./download-aiml.sh
fi

is_chat_daemon_running=$(ps aux | grep chat-service | grep -v grep | wc -l)
if [ $is_chat_daemon_running -lt 1 ]; then
	echo " ==== Starting chat-service ==== " >&2
	sleep 2
	cd $ABS_BASE/service
	nohup ./chat-service &
else
	echo " ==== Starting chat-service ==== " >&2
	echo " ==== A chat-service is already running in background, skip this step ==== " >&2
fi

is_splashbox_daemon_running=$(ps aux | grep splashbox-daemon | grep -v grep | wc -l)

if [ $is_splashbox_daemon_running -lt 1 ]; then
	echo " ==== Starting SplashBox Main Daemon ==== " >&2
	#TODO redirect log somewhere.
	cd $ABS_BASE/scripts/
	nohup ./splashbox-daemon &
	sleep 1
fi

sleep 1
echo " ==== Chat service started ==== " >&2
echo " ==== !!! Remember to set your PERLLIB manually: " >&2
echo "      export PERLLIB=$ABS_BASE/scripts/ " >&2
echo "" >&2
echo " ==== Then try it by these commands: " >&2
echo "        - Chat with the A.I. chatbot: " >&2
echo "          $ABS_BASE/scripts/splashbox-parser0 how are you" >&2
echo "" >&2
echo "        - Tell the command bot to run a command: " >&2
echo "          $ABS_BASE/scripts/splashbox-parser0 run xterm" >&2
echo "" >&2
echo "        - Try a google search: " >&2
echo "          $ABS_BASE/scripts/splashbox-parser0 search OpenSplash-project" >&2
echo " ======================================================================" >&2

