#!/bin/bash
# bash file to backup all the scripts under /home/$USER
# change the command to use like following line
#   aws s3 sync . s3://s3quenchinnovations/nextcloud/scripts/$NICKNAME/

# improve following line, actually is not what I expect
# find  -not -path "./.git*" -type f -exec echo {} \;

s3Target=s3://s3quenchinnovations/nextcloud/$NICKNAME/scripts
FOLDERS_DATA_BACKUP=("." "./Notes" "./images" "./home/$USER")

for FOLDER in ${FOLDERS_DATA_BACKUP[@]}
do
    if [ -d $FOLDER ]; then
        for file in $FOLDER/*
        do
            if [ -f $file ]; then
                fileName=$(basename $file)
                folderName=$(dirname $file)
                targetFile=$s3Target/$file
                aws s3 cp $file $targetFile
            fi
        done
    fi
done

