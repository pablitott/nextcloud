#!/bin/bash

target="s3://s3quenchinnovations/backups/quenchinnovations/"
aws s3 ls $target > content.txt
for file in "$target"/*
do
  printf "%s\n" "$file" | cut -d"/" -f8
done
