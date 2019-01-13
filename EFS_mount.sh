#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $0 <storage_file> <key_file> <mount_point>"
    echo ""
    echo " - storage_file    file with encrypted storage disk"
    echo " - key_file        file with encryption key"
    echo " - mount_point     mount target directory"
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
if [ $# -lt 3 ];
then
    print_help
    exit 0
fi

luks_image_mount $1 $2 $3
if [ $? -ne 0 ];
then
    echo "ERROR: Image mounting failure"
    exit 1
fi

# Finish without any errors
echo "DONE"
exit 0
