#!/bin/bash
#=================================================================
#----------------  Important notes  ------------------------------
#  backup files preserve user rights
#  list backup file using e.g.:
#  tar -tvf nc_backup_1.tar ./nextcloud/$CloudServer
#
#  restore files using 
#  tar -xpf nc_backup_1.tar ./nextcloud/$CloudServer
#
#  list files in tar file
#  tar -tvf nc_backup_1.tar
#
#  change the ownership using
#  $ chown -R www-data:www-data  /nextcloud/data
#
#   Change file attributes for data folder
#     sudo find /nextcloud/mydeskweb.com/ -type d -exec chmod 755 {} \;
#     sudo find /nextcloud/mydeskweb.com/ -type f -exec chmod 750 {} \;
#  
#===================================================================
#
#    TODO: 
#    - Configure symbolic links as per in step 5: https://linuxize.com/post/how-to-install-and-configure-nextcloud-on-ubuntu-18-04/
#====================================================================
function showerror (){

  if [ $? == 0 ]; then
    writeLogLine "$output_green backup succeed $output_reset"
    [ $notifyStatus == 1 ] && python2.7 ~/sendMail.py "Backup Succeed" $logfile
  else
    writeLogLine "$output_red \"${last_command}\" \n$output_yellow command failed with exit code $?. $output_reset"
    [ $notifyStatus == 1 ] &&  python2.7 ~/sendMail.py "Backup failed" $logfile
  fi

  end_time="$(date -u +%s)"
  elapsed="$(($end_time-$start_time))"
  writeLogLine "$output_yellow Total $elapsed seconds elapsed for process $output_reset"

}
#================================================================================
function backup_home(){
  verbose=$1
  if [ -f $ARCHIVE_FILE ]; then
    tarOptions='-uf'
    [ ! -z $verbose ] && tarOptions="-uvf"
  else
    tarOptions='-cf'
    [ ! -z $verbose ] && tarOptions="-cvf"
  fi

  writeLogLine "$output_blue packing $USER Home to $ARCHIVE_FILE, exclude hidden folders $output_reset"
  sudo tar --exclude=".*" --exclude="*.tar" $tarOptions  $ARCHIVE_FILE ./ 
  unset verbose
}
#================================================================================
function backup_database(){
  verbose=$1
  if [ -f $ARCHIVE_FILE ]
  then
    tarOptions="-uf"
    [ ! -z $verbose ] && tarOptions="-uvf"
  else
    tarOptions="-cf"
    [ ! -z $verbose ] && tarOptions="-cvf"
  fi
  writeLogLine "$output_blue packing MySql database $output_reset"
  docker exec -it mariadb-$CloudServer mysqldump --single-transaction -u $DB_NAME -p"$DB_PASSWORD" $serverName > ./"$serverName"_db.sql

  sudo tar $tarOptions $ARCHIVE_FILE ./"$serverName"_db.sql
  rm ./"$serverName"_db.sql
  unset verbose
  unset tarOptions
}
#================================================================================
function backup_files(){
  verbose=$1
  if [ -f $ARCHIVE_FILE ]
  then
    tarOptions="-uf"
    [ ! -z $verbose ] && tarOptions="-uvf"
  else
    [ ! -z $verbose ] && tarOptions="-cvf"
  fi

  for FOLDER in ${FOLDERS_DATA_BACKUP[@]}
  do
    if [ -d "$FOLDER" ];
    then
      writeLogLine "$output_blue packing $FOLDER... $output_reset"
      sudo tar $tarOptions $ARCHIVE_FILE $FOLDER
    else
      writeLogLine "$output_yellow Skipping $FOLDER (does not exist!) $output_reset"
    fi
  done
  writeLogLine "User: $USER"
  unset tarOptions
  unset verbose
 }
#================================================================================
function backup_image(){
  IMAGE_NEXTCLOUD="$ARCHIVE_STORE/nextcloud-image_$(date +$CURRENT_TIME_FORMAT).tar"
  IMAGE_MARIADB="$ARCHIVE_STORE/mariadb-image_$(date +$CURRENT_TIME_FORMAT).tar"
  IMAGE_LETSENCRYPT="$ARCHIVE_STORE/letsencrypt-image_$(date +$CURRENT_TIME_FORMAT).tar"
  IMAGE_PROXY="$ARCHIVE_STORE/proxy-image_$(date +$CURRENT_TIME_FORMAT).tar"

  writeLogLine "$output_blue compressing images as $IMAGE_NEXTCLOUD $output_reset"

  docker save --output $IMAGE_PROXY 690049365056.dkr.ecr.us-east-1.amazonaws.com/nextcloud:nextcloud-proxy
  docker save --output $IMAGE_NEXTCLOUD nextcloud
  docker save --output $IMAGE_MARIADB mariadb
  docker save --output $IMAGE_LETSENCRYPT jrcs/letsencrypt-nginx-proxy-companion
}
#================================================================================
function occCmd(){
  docker-compose exec --user www-data $serverName php occ $*
}
#=================================================
#            include subroutines
source ./writeLogLine.sh       # write fancy output to console
source ./folderMaintenance.sh  # create/remove folders
#=================================================

# exit when an error ocurred
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap showerror exit
#Send an email message at the end of the process
notifyStatus=1
serverName="mydeskweb"
CloudServer="mydeskweb.com"

logfile="backup_log.txt"
[ -f $logfile ] && rm $logfile
[ "$1" == "-full" ] && FULL_BACKUP=1

writeLogLine "START Backup process on $CloudServer"
start_time="$(date -u +%s)"

#check if NICKNAME is defined, True if the length of string is zero
if [ -z "$NICKNAME" ] ; then
    writeLogLine "$output_red NICKNAME is not defined, please define nickname accordingly $output_reset"
    exit -1
fi
#check if USER is defined, True if the length of string is zero
if [ -z "$USER" ] ; then
    writeLogLine "$output_red USER is not defined, please define $USER accordingly $output_reset"
    exit -1
fi

#set the current_date_format for the day of the week
CURRENT_TIME_FORMAT="%w"
DATA_ROOT="/nextcloud"
BACKUP_ROOT=/temp
ARCHIVE_STORE=$BACKUP_ROOT/repository

writeLogLine "BACKUP_ROOT: $BACKUP_ROOT"
writeLogLine "DATA_ROOT: $DATA_ROOT"
writeLogLine "ARCHIVE_STORE: $ARCHIVE_STORE"

#database values
DB_NAME="nextcloud"
DB_USER="nextcloud"
DB_PASSWORD="admin"
DB_ROOT_USER="root"
DB_ROOT_PWD="CapitanAmerica#2020"

ARCHIVE_FILE="$ARCHIVE_STORE/nc_backup_$(date +$CURRENT_TIME_FORMAT).tar"
writeLogLine " ARCHIVE_FILE: $ARCHIVE_FILE"

IMAGE_NEXTCLOUD=nextcloud-mydeskweb.com
IMAGE_MARIADB=mariadb
IMAGE_LETSENCRYPT=nextcloud-letsencrypt
IMAGE_PROXY=nextcloud-proxy-edited

FOLDERS_DATA_BACKUP=(
"$DATA_ROOT/$CloudServer/"
)

#set maintenance on
occCmd maintenance:mode --on | tee -a $logfile

removeFolder "$BACKUP_ROOT"
createFolder $ARCHIVE_STORE

backup_image
backup_database
backup_home verbose
backup_files

occCmd maintenance:mode --off | tee -a $logfile
for file in $ARCHIVE_STORE/*.tar
do
    writeLogLine "$output_green $(basename $file) Size: $(stat --printf='%s' $file | numfmt --to=iec) $output_reset"
    aws s3 cp $file s3://s3quenchinnovations/backups/$NICKNAME/$CloudServer/
done

#Remove Archive folder without condition
removeFolder $BACKUP_ROOT

writeLogLine "$output_reset end of job $output_reset"
exit 0


