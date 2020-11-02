#!/bin/bash
# bash file to backup all the scripts under /home/$USER
# change the command to use like following line
#   aws s3 sync . s3://s3quenchinnovations/nextcloud/scripts/$NICKNAME/

# improve following line, actually is not what I expect
# find  -not -path "./.git*" -type f -exec echo {} \;

s3Target=s3://s3quenchinnovations/nextcloud/$NICKNAME/scripts


for file in ./*
do
    #echo $file
    aws s3 cp $file $s3Target/
done

for file in ./Notes/* ./images/* ./home/ubuntu/*
do
    #echo $file
    aws s3 cp $file $s3Target/Notes/
done

