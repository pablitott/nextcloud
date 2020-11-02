#!/bin/bash
images=$(docker image list --format "{{.Repository}}")
for image in $images
do 
    echo $image
    docker save "$image" -o "backup_$image.tar" 
done

