#!/bin/bash

# Script location on filesystem can be used in many places
TOOL_DIR=$(cd `dirname $0` && pwd)

# Print header (just some kind of text-logo)
cat $TOOL_DIR/EFS_header

# import common functions
source $TOOL_DIR/EFS_common

print_help() {
    echo "Usage: $APP_NAME <key_file> [options]"
    echo ""
    echo " <key_file>    name of file to store key in"
    echo ""
    echo "Options:"
    echo " --from-password [pass]   generate key file from sha256sum of password string"
    echo "                          if [pass] not given then script will ask for it."
    echo "                          This way is more secure as password does not stay in shell history"
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

if [ $# -gt 1 ];
then
    if [ "$2" == "--from-password" ];
    then
        if [ $# -eq 3 ];
        then
            # password given in command line
            PASSWORD=$3
        else
            # password should be read from user input
            echo "Enter password: "
            read -s PASSWORD
        fi
        echo "Generating key file from password"
        create_key_from_pass $KEY_FILENAME $PASSWORD
        if [ $? -ne 0 ];
        then
            echo "ERROR: Failed to generate key from password"
            exit 1
        fi
    else
        print_help
        exit 1
    fi
else
    generate_random_key $KEY_FILENAME
    if [ $? -ne 0 ];
    then
        echo "ERROR: Failed to generate key"
        exit 1
    fi
fi

# Finished with success
echo "DONE"
exit 0