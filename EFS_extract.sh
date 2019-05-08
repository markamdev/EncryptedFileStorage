#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $APP_NAME <image_file> (--use-key <file> | --use-password [password])"
    echo ""
    echo " <image_file>     encrypted image file with data to be extracted"
    echo ""
    echo "Options:"
    echo "--use-key         <file>      store data in image using provided key for encryption"
    echo "--use-password    [password]  store data in image using key generated from password"
    echo "                              (if password not given script will ask for it)"
    echo ""
}

print_help
echo "ERROR: not implemented"
exit 1
