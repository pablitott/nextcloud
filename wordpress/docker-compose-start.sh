#!/bin/bash
echo "start"
source ../writeLogLine.sh  # &1>/dev/null     # write fancy output to console

serviceName=$(basename $PWD)
serverName=$serviceName.$NICKNAME
writeLogLine " serverName: $_color_yellow_ $serverName" 
writeLogLine "serviceName: $_color_yellow_ $serviceName" 

environmentFile="$PWD/$VIRTUAL_HOST.env"
writeLogLine "Environment: $PWD/$serverName.env"
set -a; source $environmentFile; set +a
#set -a; source backup_nextcloud.env; set +a

docker-compose up 

mkdir /wordpress/absolutehandymanservices.local/wp-content/plugins
mkdir /wordpress/absolutehandymanservices.local/wp-content/uploads
sudo chown -R www-data:www-data /wordpress/absolutehandymanservices.local
sudo find /wordpress/absolutehandymanservices.local -type d -exec chmod 0755 {} \;
sudo find /wordpress/absolutehandymanservices.local -type f -exec chmod 644 {} \;