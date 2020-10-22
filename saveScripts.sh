#!/bin/bash
# bash file to backup all the scripts under /home/$USER
s3Target=s3://s3quenchinnovations/nextcloud/scripts/$NICKNAME/
for file in /home/$USER/*
do
    aws s3 cp $file $s3Target
done
