#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $0 <mount_point>"
    echo ""
    echo " - mount_point     directory where EFS image is mounted"
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

luks_image_umount $1
if [ $? -ne 0 ];
then
    echo "ERROR: Image umounting failure"
    exit 1
fi

# Finish without any errors
echo "DONE"
exit 0