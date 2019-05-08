#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $APP_NAME <image_file> <mount_point> (--use-key <file> | --use-password [password])"
    echo ""
    echo " <image_file>      file with encrypted storage disk"
    echo " <mount_point>     mount target directory"
    echo ""
    echo "Options"
    echo "--use-key      <file>     mount with given encryption key"
    echo "--use-password [password] mount with key generated from password"
    echo "                          (ask for password if not given in command line)"
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
if [ $# -lt 3 ]; # in fact 3 params for password, 4 for key or password
then
    print_help
    exit 0
fi

IMAGE_FILENAME=$1
MOUNT_POINT=$2
KEY_FILENAME=""
USE_PASSWORD=0

case $3 in
    "--use-key")
    if [ $# -lt 4 ];
    then
        echo "ERROR: key file not defined"
        exit 1
    else
        KEY_FILENAME=$4
    fi
    ;;
    "--use-password")
    USE_PASSWORD=1
    PASSWORD=""
    if [ $# -lt 4 ];
    then
        # password not given - read from user
        echo "Enter password:"
        read -s PASSWORD
    else
        # password given in command line (not recommended but supported)
        PASSWORD=$4
    fi
    KEY_FILENAME="tmpkey_"$(basename $IMAGE_FILENAME)
    create_key_from_pass $KEY_FILENAME $PASSWORD
    if [ $? -ne 0 ];
    then
        echo "ERROR: Failed to create temporary key from password"
        rm -f $KEY_FILENAME
        exit 1
    fi
    ;;
    *)
    echo "ERROR: Unsupported option $3"
    exit 1
esac

luks_image_mount $IMAGE_FILENAME $KEY_FILENAME $MOUNT_POINT
RUN_RESULT=$?
# ----
if [ $USE_PASSWORD -eq 1 ];
then
    # !! key file should be immediately removed !!
    # (as it was generated temporary from password)
    rm -f $KEY_FILENAME
fi
# ----
if [ $RUN_RESULT -ne 0 ];
then
    echo "ERROR: Image mounting failure"
    exit 1
fi



# Finish without any errors
echo "DONE"
exit 0
