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
  for FOLDER in ${FOLDERS_DATA_BACKUP[@]}
  do
    if [ -d "$FOLDER" ];
    then
      echo "Copying $FOLDER..."
      sudo rsync -AaRx --delete $FOLDER $DATA_BACKUP
    else
      writeLogLine "$output_yellow Skipping $FOLDER (does not exist!) $output_reset"
    fi
  done
  writeLogLine "User: $USER"
  createFolder $DATA_BACKUP/home/$USER
  writeLogLine "Copy files from $USER to $DATA_BACKUP/home/$USER"
  sudo cp /home/$USER/*.sh $DATA_BACKUP/home/$USER
  writeLogLine "compressing $USER data"
  sudo tar -cpzf $ARCHIVE_FILE $DATA_BACKUP
}
#================================================================================
function backup_system_files(){
  writeLogLine "$output_blue Processing system backup $ARCHIVE_FILE $output_reset"
  for FOLDER in ${FOLDERS_SYSTEM_BACKUP[@]}
  do
    if [ -d "$FOLDER" ];
    then
      writeLogLine "Copying $FOLDER..."
      sudo rsync -AaRx --delete $FOLDER $DATA_BACKUP
    else
      writeLogLine "$output_yellow Skipping $FOLDER (does not exist!) $output_reset"
    fi
  done
  createFolder $SYSTEM_BACKUP/etc/
  # copy the fstab
  [ -f /etc/fstab ] && sudo cp /etc/fstab $DATA_BACKUP/etc/
  # copy the mail configuration
  [ -f /etc/msmtprc ] && sudo cp /etc/msmtprc $DATA_BACKUP/etc/
  # create the directories

  sudo mkdir -p $(dirname $ARCHIVE_FILE)
  writeLogLine "$output_blue Compressing $SYSTEM_FILE $output_reset"
  sudo tar -cpzf $SYSTEM_FILE $SYSTEM_BACKUP
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

logfile="backup_log.txt"
[ -f $logfile ] && rm $logfile
notifyStatus=1

if [ "$1" == "-full" ]; then
  FULL_BACKUP=1
else
  FULL_BACKUP=0
fi
writeLogLine "START Backup process"
start_time="$(date -u +%s)"

#check if NICKNAME is defined, True if the length of string is zero
if [ -z "$NICKNAME" ] ; then
    writeLogLine "$output_red NICKNAME is not defined, please define nickname accordingly $output_reset"
    exit -1
fi
if [ -z "$USER" ] ; then
    writeLogLine "$output_red USER is not defined, please define $USER accordingly $output_reset"
    exit -1
fi
#save disk space 1 to remov2 local temporal folder for backup, it makes little bit slower
#save disk space 0 to preserver local temporal folder, it makes little faster but need more storage 
saveDiskSpace=1

#set the current_date_format for the day of the week
CURRENT_TIME_FORMAT="%w"
DATA_ROOT="/nextcloud"
BACKUP_ROOT=/tmp/backup
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

if [ "$saveDiskSpace" == "1" ]; then
  removeFolder "$BACKUP_ROOT"
fi
createFolder $DATA_BACKUP
createFolder $SYSTEM_BACKUP
createFolder $ARCHIVE_STORE

# start rsync to back up the folders
#set maintenance on
occCmd maintenance:mode --on | tee -a $logfile

writeLogLine "$output_blue Backup MySql database $output_reset"
mysqldump --single-transaction -h localhost -u$DB_USER -p$DB_PASSWORD $DB_NAME > /tmp/ncdb_`date +"%w"`.sql

sudo mv /tmp/ncdb_`date +"%w"`.sql $DATA_BACKUP/
writeLogLine "$output_green MySql backup success $output_reset"

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

ARCHIVE_FILE="$ARCHIVE_STORE/nc_data_backup_$(date +$CURRENT_TIME_FORMAT).tar"
SYSTEM_FILE="$ARCHIVE_STORE/nc_system_backup_$(date +$CURRENT_TIME_FORMAT).tar"

writeLogLine "$output_blue Compressing $ARCHIVE_FILE $output_reset"
backup_data_files

if [ "$FULL_BACKUP" == "1" ]; then
  backup_system_files
fi
# print back up size
if [ -f $SYSTEM_FILE ]; then
  writeLogLine "$output_green System Backup Size : $(stat --printf='%s' $SYSTEM_FILE | numfmt --to=iec) $output_reset"
fi
if [ -f $ARCHIVE_FILE ]; then
  writeLogLine "$output_green   Data Backup Size : $(stat --printf='%s' $ARCHIVE_FILE | numfmt --to=iec) $output_reset"
fi
occCmd maintenance:mode --off
writeLogLine "$output_green Maintenance mode off\e[0m"

writeLogLine "$output_blue uploading tar files $output_reset"
for file in $ARCHIVE_STORE/*.tar
do
    aws s3 cp $file s3://s3quenchinnovations/backups/$NICKNAME/
done
#Remove Archive folder without condition

if [ "$saveDiskSpace" == "1" ]; then
  removeFolder $BACKUP_ROOT
fi
writeLogLine "$output_reset end of job $output_reset"
exit 0


