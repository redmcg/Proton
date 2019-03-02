#!/usr/bin/env bash

docker build --add-host aptcache:172.20.21.114 -t wine-native-dev32 -f wine-native-dev32.docker .
