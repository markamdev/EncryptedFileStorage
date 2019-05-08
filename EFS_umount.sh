#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $APP_NAME <mount_point> [options]"
    echo ""
    echo " <mount_point>     directory where EFS image is mounted"
    echo ""
    echo "Options:"
    echo "--del-dir     delete mount point after successful unmounting"
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
MOUNT_POINT=$1

DEL_MOUNTPOINT=0
if [ $# -ge 2 ];
then
    if [ "$2" == "--del-dir" ];
    then
        DEL_MOUNTPOINT=1
    else
        echo "ERROR: Invalid option '$2'"
        print_help
        exit 1
    fi
fi

luks_image_umount $MOUNT_POINT
if [ $? -ne 0 ];
then
    echo "ERROR: Image unmounting failure"
    exit 1
fi

if [ $DEL_MOUNTPOINT -eq 1 ];
then
    echo "Removing mount point directory"
    rmdir $MOUNT_POINT
    if [ $? -ne 0 ];
    then
        echo "WARNING: Failed to delete mount point after unmounting"
    fi
fi

# Finish without any errors
echo "DONE"
exit 0
