#!/bin/bash
#=================================================================
#----------------  Important notes  ------------------------------
#  backup files preserve user rights
#  list backup file using e.g.:
#  tar -tvf nc_backup_1.tar ./nextcloud/data
#
#  restore files using 
#  tar -xpf nc_backup_1.tar ./nextcloud/data
#
#  change the ownership using
#  $ chown -R www-data:www-data  /nextcloud/data
#
#  Arguments: -full=full backup 
#===================================================================
#
#    TODO: 
#    - Configure symbolic links as per in step 5: https://linuxize.com/post/how-to-install-and-configure-nextcloud-on-ubuntu-18-04/
#====================================================================
#
#   Notes:
#   Change file attributes for data folder
#     sudo find /nextcloud/quenchinnovations/ -type d -exec chmod 755 {} \;
#     sudo find /nextcloud/quenchinnovations/ -type f -exec chmod 750 {} \;
#====================================================================
output_red="\e[31m"
output_green="\e[32m"
output_yellow="\e[33m"
output_blue="\e[34m"
output_reset="\e[0m"
#================================================================================
function removeFolder(){
  folder=$1
  if [ -d $folder ]; then 
    writeLogLine "$output_blue Removing temporal local $folder $output_reset"
    sudo rm -r $folder
  fi
}
#================================================================================
function createFolder(){
  folder=$1
  if [ ! -d $folder ]; then 
    writeLogLine "$output_blue Creating temporal local $folder $output_reset"
    sudo mkdir -p $folder
    sudo chown -R $USER:$USER $folder
  fi
}
#================================================================================
function showerror (){

  if [ $? == 0 ]; then
    writeLogLine "$output_green backup succeed $output_reset"
    [ $notifyStatus == 1 ] && python ~/sendMail.py "Backup Succeed" $logfile
  else
    writeLogLine "$output_red \"${last_command}\" \n$output_yellow command failed with exit code $?. $output_reset"
    [ $notifyStatus == 1 ] &&  python ~/sendMail.py "Backup failed" $logfile
  fi

  end_time="$(date -u +%s)"
  elapsed="$(($end_time-$start_time))"
  writeLogLine "$output_yellow Total $elapsed seconds elapsed for process $output_reset"

}
#================================================================================
function backup_data_files(){
  writeLogLine "$output_blue packing MySql database $output_reset"
  mysqldump --single-transaction -h localhost -u$DB_USER -p$DB_PASSWORD $DB_NAME > $TMP_DB_BACKUP
  tar -cf $ARCHIVE_FILE $TMP_DB_BACKUP
  writeLogLine "$output_yellow packing /home/$USER/*.sh *.py to $ARCHIVE_FILE $output_reset"

  sudo tar -uf  $ARCHIVE_FILE /home/$USER/*.sh
  sudo tar -uf  $ARCHIVE_FILE /home/$USER/*.py

  for FOLDER in ${FOLDERS_DATA_BACKUP[@]}
  do
    if [ -d "$FOLDER" ];
    then
      writeLogLine "packing $FOLDER..."
      sudo tar -uf $ARCHIVE_FILE $FOLDER
    else
      writeLogLine "$output_yellow Skipping $FOLDER (does not exist!) $output_reset"
    fi
  done
  writeLogLine "User: $USER"
 }
#================================================================================
function backup_system_files(){
  writeLogLine "$output_blue Processing system backup $ARCHIVE_FILE $output_reset"
  sudo tar -cf $SYSTEM_FILE --files-from /dev/null
  for FOLDER in ${FOLDERS_SYSTEM_BACKUP[@]}
  do
    if [ -d "$FOLDER" ];
    then
      writeLogLine "Copying $FOLDER..."
      sudo tar -uf $SYSTEM_FILE $FOLDER
      #sudo rsync -AaRx --delete $FOLDER $BACKUP_SYSTEM
    else
      writeLogLine "$output_yellow Skipping $FOLDER (does not exist!) $output_reset"
    fi
  done
  createFolder $BACKUP_SYSTEM/etc/
  # tar the fstab
  [ -f /etc/fstab ] && sudo tar -uf $SYSTEM_FILE /etc/fstab
#  [ -f /etc/msmtprc ] && sudo tar -rf $SYSTEM_FILE /etc/msmtprc
}
#=================================================
function occCmd(){
  sudo -u www-data php /var/www/$NICKNAME/occ $*
}
#=================================================
function writeLogLine(){
  message=$1
  echo -e "$(date +"%Y-%m-%d %T") $message" | tee -a $logfile
}
# exit when an error ocurred
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap showerror exit
notifyStatus=1

logfile="backup_log.txt"
[ -f $logfile ] && rm $logfile

FULL_BACKUP=0
[ "$1" == "-full" ] && FULL_BACKUP=1

writeLogLine "START Backup process Full Backup: $FULL_BACKUP"
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
DATA_BACKUP=$BACKUP_ROOT/data
SYSTEM_BACKUP=$BACKUP_ROOT/system

writeLogLine "BACKUP_ROOT: $BACKUP_ROOT"
writeLogLine "DATA_ROOT: $DATA_ROOT"
writeLogLine "ARCHIVE_STORE: $ARCHIVE_STORE"
writeLogLine "DATA_BACKUP: $DATA_BACKUP"
writeLogLine "SYSTEM_BACKUP: $SYSTEM_BACKUP"

#database values
DB_NAME="nextcloud"
DB_USER="nextcloud"
DB_PASSWORD="admin"
DB_ROOT_USER="root"
DB_ROOT_PWD="CapitanAmerica#2020"

removeFolder "$BACKUP_ROOT"
createFolder $DATA_BACKUP
createFolder $BACKUP_SYSTEM
createFolder $ARCHIVE_STORE

ARCHIVE_FILE="$ARCHIVE_STORE/nc_data_backup_$(date +$CURRENT_TIME_FORMAT).tar"
SYSTEM_FILE="$ARCHIVE_STORE/nc_system_backup_$(date +$CURRENT_TIME_FORMAT).tar"
TMP_DB_BACKUP="$DATA_BACKUP/ncdb_$(date +$CURRENT_TIME_FORMAT).sql"

writeLogLine " ARCHIVE_FILE: $ARCHIVE_FILE"
writeLogLine "  SYSTEM_FILE: $SYSTEM_FILE"
writeLogLine "TMP_DB_BACKUP: $TMP_DB_BACKUP"

FOLDERS_DATA_BACKUP=(
"$DATA_ROOT/$NICKNAME/"
)

FOLDERS_SYSTEM_BACKUP+=(
"/etc/letsencrypt/"
"/etc/mysql/"
"/etc/nginx"
"/etc/apache2/"
"/etc/php/"
"/etc/ssh/"
"/etc/pam.d/"
"/etc/ssl/"
"/var/www/$NICKNAME/"
)

#set maintenance on
occCmd maintenance:mode --on | tee -a $logfile
backup_data_files

createFolder $(dirname $ARCHIVE_FILE)
writeLogLine "$output_blue Compressing $ARCHIVE_FILE $output_reset"
# print back up size
if [ -f $ARCHIVE_FILE ]; then
  writeLogLine "$output_green   Data Backup Size: $(stat --printf='%s' $ARCHIVE_FILE | numfmt --to=iec) $output_reset"
fi

if [ "$FULL_BACKUP" == "1" ]; then
  backup_system_files
  writeLogLine "$output_blue Compressing $SYSTEM_FILE $output_reset"
  # print back up size
  if [ -f $SYSTEM_FILE ]; then
    writeLogLine "$output_green System Backup Size: $(stat --printf='%s' $SYSTEM_FILE | numfmt --to=iec) $output_reset"
  fi
fi

occCmd maintenance:mode --off
writeLogLine "$output_green Maintenance mode off\e[0m"

writeLogLine "$output_blue uploading tar files $output_reset"
for file in $ARCHIVE_STORE/*.tar
do
    aws s3 cp $file s3://s3quenchinnovations/backups/$NICKNAME/
done

#Remove Archive folder without condition
removeFolder $BACKUP_ROOT

writeLogLine "$output_reset end of job $output_reset"
exit 0


