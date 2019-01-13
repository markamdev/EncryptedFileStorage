#!/bin/bash

INSTALL_DIR=$HOME/.EFS
INSTALL_TAG="EFS_INSTALL_TAG"
EFS_FILES="EFS_common EFS_header"
EFS_FILES+=" EFS_prepare.sh"
EFS_FILES+=" EFS_extract.sh  EFS_store.sh"
EFS_FILES+=" EFS_mount.sh EFS_umount.sh"
EFS_FILES+=" EFS_keygen.sh"
RC_FILE=$HOME/.bashrc

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

echo "Checking if $INSTALL_DIR is in \$PATH (using .bashrc)"
TAG_FOUND=`grep "PATH" $RC_FILE | grep -c $INSTALL_DIR`
if [ $TAG_FOUND -eq 0 ];
then
    echo " - not found - adding"
    echo "" >> $RC_FILE
    echo "# Add EncryptedFileStorage tools to \$PATH" >> $RC_FILE
    echo "export PATH=$INSTALL_DIR:$PATH" >> $RC_FILE
else
    echo " - already added - skipped"
fi
