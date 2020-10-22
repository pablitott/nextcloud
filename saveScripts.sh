#!/bin/bash
# bash file to backup all the scripts under /home/$USER
s3Target=s3://s3quenchinnovations/nextcloud/scripts/$NICKNAME/
workingFolder=$(pwd)
for file in $workingFolder/*.sh $workingFolder/*.yml 
do
    aws s3 cp $file $s3Target
done
