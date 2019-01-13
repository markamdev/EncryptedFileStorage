#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $1 <key_file>"
    echo ""
    echo " - key_file    name of file to store key in"
    echo ""
}

#check if necessary binaries are accesible
check_tools
if [ $? -ne 0 ];
then
    echo "ERROR: Necessary tools not found"
    exit 1
fi

# Check param list
if [ $# -lt 1 ];
then
    print_help
    exit 0
fi

KEY_FILENAME=$1

if [ -e "$KEY_FILENAME" ];
then
    echo "ERROR: File '$KEY_FILENAME' already exists - please provide another <key_file>"
    exit 1
fi

generate_random_key $KEY_FILENAME
if [ $? -ne 0 ];
then
    echo "ERROR: Failed to generate key"
    exit 1
fi

# Finished with success
echo "DONE"
exit 0