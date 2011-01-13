#!/bin/bash

INSTALL_PREFIX=./INSTALL_PREFIX

SPLASHBOX_LIB=$INSTALL_PREFIX/var/lib/splashbox/
WHERE_AM_I=$(pwd)

mkdir -p $SPLASHBOX_LIB

cp -rf action $SPLASHBOX_LIB || exit 1
cp -rf data $SPLASHBOX_LIB || exit 1
if [ $(ls -1 chat-service/AIML/*.aiml|wc -l) = 0 ]; then
	cd chat-service/AIML && ./download-aiml.sh
	cd $WHERE_AM_I
fi
cp -rf chat-service $SPLASHBOX_LIB || exit 1
