#!/bin/bash

BASE_DIR=$(echo $(dirname $(readlink -f $0)))

source $BASE_DIR/helpers.sh
source $BASE_DIR/params.sh

if [ -z $PLUGINS_TO_INSTALL ]; then
    usage
fi
# Optional Plugins
installPlugins
publishAssets

