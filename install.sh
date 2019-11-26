#!/bin/bash

INSTALL_DIR=$HOME/.EFS
INSTALL_TAG="EFS_INSTALL_TAG"
EFS_FILES="EFS_common EFS_header"
EFS_FILES+=" EFS_prepare.sh"
# Do not install not implemented features
# EFS_FILES+=" EFS_extract.sh  EFS_store.sh"
EFS_FILES+=" EFS_mount.sh EFS_umount.sh"
EFS_FILES+=" EFS_keygen.sh"
RC_FILE=$HOME/.bashrc
EFS_ENV_FILE=$INSTALL_DIR/efs_env

echo "Check if instal dir exists"
if [ ! -d "$INSTALL_DIR" ];
then
    echo " - creating $INSTALL_DIR ..."
    mkdir $INSTALL_DIR
    if [ $? -ne 0 ];
    then
        echo "ERROR: Failed to create directory - exiting"
        exit 1
    fi
fi

echo "Copying tool files to $INSTALL_DIR"
for tool in $EFS_FILES
do
    echo " - copying $tool ..."
    cp -p $tool $INSTALL_DIR

    if [ $? -ne 0 ];
    then
        echo "ERROR: Failed to copy - exiting"
        exit 1
    fi
done

echo "Preparing environment settings file (overwriting if exists)"
echo "# Environment variables needed for EncryptedFileStorage tools" > $EFS_ENV_FILE
echo "export PATH=$INSTALL_DIR:\$PATH" >> $EFS_ENV_FILE
echo "" >> $EFS_ENV_FILE

echo "Checking if EncryptedFileStorage envs are set (using $RC_FILE)"
TAG_FOUND=`grep "PATH" $RC_FILE | grep -c $EFS_ENV_FILE`
if [ $TAG_FOUND -eq 0 ];
then
    echo " - not found - adding"
    echo "" >> $RC_FILE
    echo "# Add EncryptedFileStorage tools to \$PATH" >> $RC_FILE
    echo "source $EFS_ENV_FILE" >> $RC_FILE
else
    echo " - already set - skipping"
fi
