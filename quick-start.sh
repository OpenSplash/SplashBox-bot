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
	sleep 2
fi


sleep 2
echo " ==== Chat service started ==== " >&2
echo " ==== Run \"$ABS_BASE/scripts/parser-0.pl hello\" to test the language parser to A.I. chatbot ==== " >&2
echo " ==== Run \"$ABS_BASE/scripts/parser-0.pl run xterm\" to test the language parser to command bot ==== " >&2
echo " ==== Run \"$ABS_BASE/scripts/splashbox-daemon\" to test the action daemon. ==== " >&2

