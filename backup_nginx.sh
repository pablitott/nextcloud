#!/bin/bash
# dirname "$0"
#=================================================================
#
#                  Syntax
#    excport HOMEDIR=/home/ubuntu/nextcloud
#    ./backup_nginx.sh <serviceName>
#    serviceName: paveltrujillo.info, paveltrujillo.local
#
#=================================================================
#               Important notes
#  script variables are stored in backup_nginx.env
#====================================================================
function backup_home(){
  verbose=$1
  tarOptions='-uf'
  [ ! -z $verbose ] && tarOptions="-uvf"
  writeLogLine "tar using $tarOptions" $_color_yellow_
  tarFile=home_$serviceName.tar
  backupFile="/tmp/$home_$serviceName.tar"

  writeLogLine "packing $HOMEDIR/$serviceName to $tarFile, exclude hidden folders" $_color_blue_
  sudo tar $tarOptions $backupFile --exclude="./.*" --exclude="*.tar" --exclude="*.log"  $HOMEDIR/$serverName
  aws s3 cp $backupFile $BACKUP_S3BUCKET/$NICKNAME/$serviceName/$tarFile
  sudo rm -f $backupFile
  unset verbose 
}
#================================================================================
function backup_files(){
  verbose=$1
  tarOptions='-uf' 
  [ ! -z $verbose ] && tarOptions="-uvf"

  echo "packing $serviceName"
  tarFile=/tmp/$serviceName.tar
  sudo tar $tarOptions $tarFile $folderData
  aws s3 cp $tarFile $BACKUP_S3BUCKET/$NICKNAME/$serviceName/$serviceName.tar
  sudo rm -f $tarFile
 }
#================================================================================
function awsCmd(){
  docker run --rm -ti  -v $(pwd):/aws pablitott/myawscmd:latest $*
}
#define global variables
if [ -z "$HOMEDIR" ] ; then
    echo "HOMEDIR is not defined, please define HOMEDIR accordingly"
    exit -1
fi
echo "USER: $USER"
echo "HOMEDIR: $HOMEDIR"
cd $HOMEDIR

#================================================================================
#            include subroutines
# source ./writeLogLine.sh  &1 > /dev/null     # write fancy output to console
# source ./folderMaintenance.sh &1 > /dev/null              # create/remove folders
# set -a; source backup_nginx.env; set +a

#=================================================
if [ -z $1 ] ; then
    writeLogLine "ServerName to be backup is not defined, please define ServerName accordingly" $_color_red_
    return
fi

#check if NICKNAME is defined, True if the length of string is zero
if [ -z "$NICKNAME" ] ; then
    writeLogLine "NICKNAME is not defined, please define nickname accordingly" $_color_red_
    return
fi

#check if USER is defined, True if the length of string is zero
if [ -z "$USER" ] ; then
    writeLogLine "USER is not defined, please define $USER accordingly" $_color_red_
    return
fi

serverName="${serviceName%.*}"
writeLogLine "serverName:$serverName" $_color_blue_
writeLogLine "serviceName: $serviceName" $_color_blue_

folderData="/nextcloud/www/$serviceName"
homeDir=~/nextcloud/$serverName

logfileName="backup-$serverName-$(date +$CURRENT_TIME_FORMAT).log"
logfile="$HOMEDIR/$serverName/$logfileName"

[ -f $logfile ] && rm $logfile
writeLogLine "logfile: $logfile" $_color_blue_
writeLogLine "folder Data: $folderData " $_color_blue_
writeLogLine "START Backup process on $serverName" $_color_purple_
start_time="$(date -u +%s)"

backup_home 
backup_files 

writeLogLine " end of job " $_color_green_

return 0


