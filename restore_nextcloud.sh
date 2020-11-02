#!/bin/bash
#=================================================================
#
#                  Syntax
#    ./restore_nextcloud.sh <serviceName> <backup day of week>
#    serviceName: quenchinnovations, <[0,1,2,3,4,5,6]
#
#=================================================================
#               Important notes
#  backup files preserve user rights
#  list backup file using e.g.:
#  tar -cvf nc_backup_1.tar ./nextcloud/quenchinnovations.net
#  tar -uvf nc_backup_1.tar ./nextcloud/quenchinnovations.net
#
#  restore files using 
#  tar -xpf nc_backup_1.tar ./nextcloud/quenchinnovations.net
#
#  list files in tar file
#  tar -tvf nc_backup_1.tar 
#
#  change the ownership using
#  $ chown -R www-data:www-data  /nextcloud/mydeskweb.com/
#
#   Change file attributes for data folder
#     sudo find /nextcloud/mydeskweb.com/ -type d -exec chmod 755 {} \;
#     sudo find /nextcloud/mydeskweb.com/ -type f -exec chmod 640 {} \;
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
    writeLogLine "$_color_green_ Restore succeed $output_reset"
    [ ! -z $notifyStatus ] && python2.7 ~/sendMail.py "Backup Succeed" $logfile
  else
    writeLogLine "$_color_red_ \"${last_command}\" \n$_color_yellow_ command failed with exit code $?."
    [ ! -z $notifyStatus ] &&  python2.7 ~/sendMail.py "Restore failed" $logfile
  fi

  end_time="$(date -u +%s)"
  [ ! -z $start_time ] && elapsed="$(($end_time-$start_time))"
  [ ! -z $start_time ] && writeLogLine "$_color_yellow_ Total $elapsed seconds elapsed for process "
  # I think these lines are not needed
  #unset $(grep -v '^#' $environmentFile | sed -E 's/(.*)=.*/\1/' | xargs)
  #unset $(grep -v '^#' backup_nextcloud.env | sed -E 's/(.*)=.*/\1/' | xargs)
}
#====================================================================
function occCmd(){
  docker-compose exec --user www-data $serverName php occ $*
}
#====================================================================
function restore_files(){
  workingdir=$PWD 
  writeLogLine "Restore user datafiles from $restoreTarFile" $_color_blue_
  cd /
  for FOLDER in ${FOLDERS_DATA_BACKUP[@]}
  do
      if [ -d "$FOLDER" ];
      then
        writeLogLine "$_color_yellow_ deleting $FOLDER... "
        sudo rm -r $FOLDER
      fi
      writeLogLine "$_color_yellow_ restore $FOLDER... "
      sudo tar -xpf $BACKUP_REPOSITORY/$restoreTarFile $FOLDER 
  done
  cd $workingdir
  writeLogLine "End of Restore user datafiles" $_color_purple_
}
#====================================================================
function restore_database(){
  writeLogLine "Restore DataBase $MYSQL_DATABASE from $restore_db_file"
  restore_db_file=$serverName-db.sql
  writeLogLine "Restoring datafiles from $restoreTarFile to $BACKUP_REPOSITORY"
  writeLogLine "Database file: $BACKUP_REPOSITORY/$restore_db_file"

  sudo tar -xpf $BACKUP_REPOSITORY/$restoreTarFile $BACKUP_FOLDER/$restore_db_file
  # for full command lines see docker-notes.md
  writeLogLine "DROP DATABASE $MYSQL_DATABASE" $_color_yellow_
  docker exec -it $DATABASE_SERVICE mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE $MYSQL_DATABASE"

  writeLogLine "CREATE DATABASE $MYSQL_DATABASE" $_color_yellow_
  docker exec -it $DATABASE_SERVICE mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"

  # docker exec -it mariadb-mydeskweb.com mysql -uroot -p"$DB_ROOT_PWD" -e "CREATE USER nextcloud IDENTIFIED BY admin"
  writeLogLine "GRANT ALL PRIVILEGES on $MYSQL_DATABASE.* to $MYSQL_USER" $_color_yellow_
  docker exec -it $DATABASE_SERVICE mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES on $MYSQL_DATABASE.* to $MYSQL_USER"

  writeLogLine "RESTORE $MYSQL_DATABASE FROM $BACKUP_FOLDER/$restore_db_file IN SERVICE $DATABASE_SERVICE" $_color_yellow_
  docker exec -i $DATABASE_SERVICE mysql -u$MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE < $BACKUP_FOLDER/$restore_db_file
  writeLogLine "End of Restore DataBase ..." $_color_purple_
}
#====================================================================
#            include subroutines
source ./writeLogLine.sh  &1>/dev/null     # write fancy output to console
source ./folderMaintenance.sh              # create/remove folders
#====================================================================
#             Set environment variables 
set -a; source backup_nextcloud.env; set +a
#====================================================================

# exit when an error ocurred
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap showerror exit

if [ -z $1 ] ; then
    writeLogLine "$_color_red_ ServerName to be backup is not defined, please define ServerName accordingly "
    exit -1
fi
serviceName=$1
serverName="${serviceName%.*}"

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

if [ -z $2 ]; then
  writeLogLine "$output_red must define backup number 1-5 $output_reset"
  exit 1
fi
backupToRestore=$2
logfile="$PWD/restore-$serverName.log"
environmentFile=$serverName.env
set -a; source $environmentFile ; set +a

[ -f $logfile ] && rm $logfile

writeLogLine "START Restore process on $serviceName"
start_time="$(date -u +%s)"

FOLDERS_DATA_BACKUP=(
"$FOLDER_ROOT/$serviceName/data"
)
#"$FOLDER_ROOT/$serviceName"
#"$FOLDER_ROOT/$serviceName/custom_apps"
#"$FOLDER_ROOT/$serviceName/data"
#"$FOLDER_ROOT/$serviceName/config"
#"$FOLDER_ROOT/$serviceName/themes"

occCmd maintenance:mode --on | tee -a $logfile

removeFolder "$BACKUP_REPOSITORY"
createFolder "$BACKUP_REPOSITORY"
restoreTarFile="nc_backup_$(date +$backupToRestore).tar"

writeLogLine "Recover backup file from $BACKUP_S3BUCKET/$NICKNAME/$serviceName/$restoreTarFile" $_color_blue_
aws s3 cp $BACKUP_S3BUCKET/$NICKNAME/$serviceName/$restoreTarFile $BACKUP_REPOSITORY/$restoreTarFile | tee -a  $logfile

restore_database

writeLogLine "$output_blue shut down docker service $serviceName" $_color_blue_
docker stop $serviceName | tee -a $logfile

restore_files

docker start $serviceName | tee -a $logfile
writeLogLine "$output_blue docker service $serviceName is up" $_color_purple_

occCmd maintenance:mode --off | tee -a $logfile
# review data files
occCmd files:scan-app-data | tee -a $logfile
occCmd files:cleanup  | tee -a $logfile
occCmd files:scan --all  | tee -a $logfile


removeFolder $BACKUP_REPOSITORY

writeLogLine "$_color_purple_ end of restore $serverName"
exit 0


