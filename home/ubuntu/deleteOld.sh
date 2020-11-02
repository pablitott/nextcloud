#!/bin/bash

# Usage: ./deleteOld "quenchinnovations" "3 days"
s3Bucket="s3://s3quenchinnovations/backups/$1/"
aws s3 ls $s3Bucket | while read -r line;
  do
    createDate=`echo $line|awk {'print $1" "$2'}`
    createDate=`date -d"$createDate" +%s`
    olderThan=`date -d"-$2" +%s`

    if [[ $createDate -lt $olderThan ]]
      then 
        fileName=`echo $line|awk {'print $4'}`
#        echo $fileName
        if [[ $fileName != "" ]] && [[ "$fileName" != *"-full.tar"* ]]
	  then
	     echo "removing $fileName from $s3Bucket"
	     aws s3 rm $s3Bucket$fileName
        fi	     
    fi
  done;
