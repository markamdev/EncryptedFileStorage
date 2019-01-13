#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $1 <storage_name> <storage_size> [options]"
    echo ""
    echo " -  storage_name    has to match normal filename criteria"
    echo " -  storage_size    can be given as bytes, mega-bytes (M suffix) and so"
    echo ""
    echo "Currently supported options:"
    echo " --use-key <file>   use provided key file instead of generating new one "
}

#check if necessary binaries are accesible
check_tools
if [ $? -ne 0 ];
then
    echo "ERROR: Necessary tools not found"
    exit 1
fi

# Check param list (number of params, mandatory params)
if [ $# -lt 2 ];
then
    print_help
    exit 0
fi

IMAGE_FILENAME=$1
IMAGE_SIZE=$2
KEY_FILENAME=""

if [ $# -gt 2 ];
then
    # additional commandline params found
    # skip first two mandatory params
    shift
    shift

    while [[ $# -gt 0 ]]
    do
        param="$1"
        case $param in
            "--use-key")
            KEY_FILENAME="$2"
            shift # shift out param
            shift # shift out value
            ;;
        esac
    done
fi

if [ -e "$IMAGE_FILENAME" ];
then
    echo "ERROR: File '$IMAGE_FILENAME' already exists - please provide another <store_name>"
    exit 1
fi

create_image $IMAGE_FILENAME $IMAGE_SIZE
if [ $? -ne 0 ];
then
    echo "ERROR: Image creation failed"
    exit 1
fi

if [ "$KEY_FILENAME" == "" ];
then
    KEY_FILENAME=$IMAGE_FILENAME.key
    generate_random_key $KEY_FILENAME
    if [ $? -ne 0 ];
    then
        echo "ERROR: Key generation failed"
        exit 1
    fi
fi

luks_image_prepare $IMAGE_FILENAME $KEY_FILENAME
if [ $? -ne 0 ];
then
    echo "ERROR: encrypted image creation failed"
    exit 1
fi

# Finish without any errors
echo "DONE"
exit 0
