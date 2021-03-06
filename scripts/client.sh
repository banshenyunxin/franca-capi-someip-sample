#!/usr/bin/env bash

sudo route add -net 224.0.0.0/4 dev ens33
COMMONAPI_PATH=~/git/genivi/capicxx-core-runtime/build
COMMONAPI_SOMEIP_PATH=~/git/genivi/capicxx-someip-runtime/build
VSOMEIP_PATH=~/git/genivi/vsomeip/build
export LD_LIBRARY_PATH=../lib:${COMMONAPI_PATH}:${COMMONAPI_SOMEIP_PATH}:${VSOMEIP_PATH}:$LD_LIBRARY_PATH
export VSOMEIP_APPLICATION_NAME=client-sample
export VSOMEIP_CONFIGURATION=../config/vsomeip-client.json
export COMMONAPI_CONFIG=../config/commonapi.ini
../bin/MLClient
