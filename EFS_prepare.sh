#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $APP_NAME <storage_name> <storage_size> [options]"
    echo ""
    echo " -  storage_name    has to match normal filename criteria"
    echo " -  storage_size    can be given as bytes, mega-bytes (M suffix) and so"
    echo ""
    echo "Currently supported options:"
    echo "--use-key      <file>     use provided key file instead of generating new one "
    echo "--use-password [password] use password based key"
    echo "                          (if password not provided script will ask user for it)"
    echo ""
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
USE_KEY=0
USE_PASS=0
PASSWORD=""

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
            if [ "$2" == "" ];
            then
                echo "ERROR: Key file not given"
                exit 1
            fi
            KEY_FILENAME="$2"
            USE_KEY=1
            shift # shift out param
            shift # shift out value
            ;;
            "--use-password")
            USE_PASS=1
            if [ "$2" == "" ];
            then
                echo "Enter password:"
                read -s PASSWORD
            else
                PASSWORD=$2
                shift # shift out password string
            fi
            shift # shift out param (pass selection)
            ;;
            *)
            echo "ERROR: Unsupported option $param"
            exit 1
        esac
    done
fi

if [[ $USE_KEY -eq 1 && $USE_PASS -eq 1 ]];
then
    echo "ERROR: Cannot use key and password at the same time"
    exit 1
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

if [ $USE_PASS -eq 1 ];
then
    echo "Preparing image with password"
    # prepare temporary key file
    TEMP_KEY="tmpkey_$IMAGE_FILENAME"

    create_key_from_pass $TEMP_KEY $PASSWORD
    if [ $? -ne 0 ];
    then
        echo "ERROR: Failed to create temporary key from password"
        rm -f $IMAGE_FILENAME $TEMP_KEY
        exit 1
    fi

    luks_image_prepare $IMAGE_FILENAME $TEMP_KEY
    if [ $? -ne 0 ];
    then
        echo "ERROR: encrypted image creation failed"
        rm -f $IMAGE_FILENAME $TEMP_KEY
        exit 1
    fi
    rm $TEMP_KEY
else
    echo "Preparing image with key"
    if [ "$KEY_FILENAME" == "" ];
    then
        KEY_FILENAME=$IMAGE_FILENAME.key
        generate_random_key $KEY_FILENAME
        if [ $? -ne 0 ];
        then
            echo "ERROR: Key generation failed"
            rm -f $IMAGE_FILENAME
            exit 1
        fi
    fi

    luks_image_prepare $IMAGE_FILENAME $KEY_FILENAME
    if [ $? -ne 0 ];
    then
        echo "ERROR: encrypted image creation failed"
        rm -f $IMAGE_FILENAME
        exit 1
    fi
fi

# Finish without any errors
echo "DONE"
exit 0
