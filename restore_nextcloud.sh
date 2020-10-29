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
#  $ chown -R www-data:www-data  /nextcloud/mydeskweb.com/
#
#   Change file attributes for data folder
#     sudo find /nextcloud/mydeskweb.com/ -type d -exec chmod 755 {} \;
#     sudo find /nextcloud/mydeskweb.com/ -type f -exec chmod 750 {} \;
#  
# In case need to create the mysql.user 
# docker exec -it mariadb-mydeskweb.com mysql -uroot -p"CapitanAmerica#2020" -e "CREATE USER 'nextcloud'@localhost IDENTIFIED BY 'admin'"
#===================================================================
#
#    TODO: 
#    - Configure symbolic links as per in step 5: https://linuxize.com/post/how-to-install-and-configure-nextcloud-on-ubuntu-18-04/
#====================================================================
function showerror (){

  if [ $? == 0 ]; then
    writeLogLine "$output_green Restore succeed $output_reset"
    [ $notifyStatus == 1 ] && python2.7 ~/sendMail.py "Backup Succeed" $logfile
  else
    writeLogLine "$output_red \"${last_command}\" \n$output_yellow command failed with exit code $?. $output_reset"
    [ $notifyStatus == 1 ] &&  python2.7 ~/sendMail.py "Restore failed" $logfile
  fi

  end_time="$(date -u +%s)"
  elapsed="$(($end_time-$start_time))"
  writeLogLine "$output_yellow Total $elapsed seconds elapsed for process $output_reset"

}
#====================================================================
function occCmd(){
  docker-compose exec --user www-data $serverName php occ $*
}
#====================================================================
#            include subroutines
source ./writeLogLine.sh       # write fancy output to console
source ./folderMaintenance.sh  # create/remove folders
#====================================================================

# exit when an error ocurred
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap showerror exit
#Send an email message at the end of the process

# occCmd maintenance:mode --on
if [ -z $1 ]; then
  writeLogLine "$output_red must define backup number 1-5 $output_reset"
  exit 1
fi
serverName="mydeskweb"
CloudServer="mydeskweb.com"

logfile="backup_log.txt"
[ -f $logfile ] && rm $logfile
[ "$1" == "-full" ] && FULL_BACKUP=1

writeLogLine "START Restore process on $CloudServer"
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
BACKUP_TO_RESTORE=$1
DATA_ROOT="/nextcloud"
SERVER_ROOT=$DATA_ROOT/$CloudServer
DATA_SERVER=$SERVER_ROOT/data
THEMES_SERVER=$SERVER_ROOT/themes
CUSTOM_APPS=$SERVER_ROOT/custom_apps

BACKUP_ROOT=/temp
ARCHIVE_STORE=$BACKUP_ROOT/repository
ARCHIVE_SERVER=$ARCHIVE_STORE/nextcloud/$CloudServer
ARCHIVE_SERVER_DATA=$ARCHIVE_SERVER/data

#database values
DB_NAME="mydeskweb"
DB_USER="nextcloud"
DB_PASSWORD="admin"
DB_ROOT_USER="root"
DB_ROOT_PWD="CapitanAmerica#2020"

DB_FILE=mydeskweb_db.sql
TAR_FILE="nc_backup_$BACKUP_TO_RESTORE.tar"
ARCHIVE_FILE="$ARCHIVE_STORE/$TAR_FILE"

writeLogLine " ARCHIVE_FILE: $ARCHIVE_FILE"

#set maintenance on
occCmd maintenance:mode --on | tee -a $logfile

removeFolder "$BACKUP_ROOT"
createFolder $ARCHIVE_STORE

[ -f $TAR_FILE ] && sudo rm $TAR_FILE
aws s3 cp s3://s3quenchinnovations/backups/$NICKNAME/$CloudServer/$TAR_FILE $TAR_FILE
#   - sudo mysql_secure_installation
writeLogLine " Restoring datafiles from $TAR_FILE to $ARCHIVE_STORE"
writeLogLine " Database file: $ARCHIVE_STORE/$DB_FILE"
sudo tar -xpf $TAR_FILE -C $ARCHIVE_STORE

# for full command lines see docker-notes.md
docker exec -it mariadb-mydeskweb.com mysql -u$DB_ROOT_USER -p"$DB_ROOT_PWD" -e "DROP DATABASE $DB_NAME"
docker exec -it mariadb-mydeskweb.com mysql -u$DB_ROOT_USER -p"$DB_ROOT_PWD" -e "CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

# docker exec -it mariadb-mydeskweb.com mysql -u$DB_ROOT_USER -p"$DB_ROOT_PWD" -e "CREATE USER nextcloud IDENTIFIED BY admin"
docker exec -it mariadb-mydeskweb.com mysql -u$DB_ROOT_USER -p"$DB_ROOT_PWD" -e "GRANT ALL PRIVILEGES on $DB_NAME.* to $DB_USER"
docker exec -i mariadb-mydeskweb.com mysql -u$DB_USER -p$DB_PASSWORD $DB_NAME < $ARCHIVE_STORE/$DB_FILE


#restore original files

writeLogLine "$output_yellow restart docker-compose $output_reset"
docker-compose down

writeLogLine "$output_yellow remove $SERVER_ROOT $output_reset"
sudo rm -r $SERVER_ROOT

writeLogLine "$output_yellow restore $SERVER_ROOT from $ARCHIVE_SERVER  $output_reset"
echo "sudo cp -rp $ARCHIVE_SERVER $SERVER_ROOT"
sudo cp -rp $ARCHIVE_SERVER $SERVER_ROOT

docker-compose up -d

occCmd maintenance:mode --off | tee -a $logfile
writeLogLine "$output_blue docker-compose is up $output_reset"

#Remove Archive folder without condition
removeFolder $BACKUP_ROOT

writeLogLine "$output_reset end of job $output_reset"
exit 0


