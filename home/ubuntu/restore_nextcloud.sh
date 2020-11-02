#!/bin/bash
#=================================================================
#----------------  Important notes  ------------------------------
#  backup files does not preserver user rights
#  when inflate datafile.zip change the ownership
#
#  $ unzip $datafile.zip -d /
#
#  In case the data is unzipped in /nextcloud-data
#  $ chown www-data:  /nextcloud-data
#===================================================================
# exit when an error ocurred
set -e

# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap 'echo "\"${last_command}\" command failed with exit code $?."' EXIT
#export NICKNAME="TestServer"
#check if NICKNAME is defined
if [ -z "$NICKNAME" ] ; then
    echo "NICKNAME is not defined, please define nickname accordingly"
    exit -1
fi
CURRENT_TIME_FORMAT="%w"
CURRENT_TIME_FORMAT="1"
echo "START: $(date)"
ROOT_FOLDER="nextcloud"
ARCHIVE_TANK="/$ROOT_FOLDER/backup/repository"
HOLDING_TANK="/$ROOT_FOLDER/backup/holdingtank"
FOLDERS_TO_RESTORE_SOURCE="./$ROOT_FOLDER/$NICKNAME"
FOLDERS_TO_RESTORE_TARGET="/$ROOT_FOLDER/$NICKNAME"

TAR_FILE=nc_backup_$CURRENT_TIME_FORMAT.tar
DB_FILE=ncdb_$CURRENT_TIME_FORMAT.sql
ARCHIVE_FILE="$ARCHIVE_TANK/$TAR_FILE"

if [ -d "$ARCHIVE_TANK" ] ; then
   echo "removing $ARCHIVE_TANK"
   sudo rm -r $ARCHIVE_TANK
fi
if [ -d "$HOLDING_TANK" ] ; then
   echo "removing $HOLDING_TANK"
   sudo rm -r $HOLDING_TANK
fi
sudo mkdir -p $ARCHIVE_TANK $HOLDING_TANK

sudo aws s3 cp s3://s3quenchinnovations/backups/$NICKNAME/$TAR_FILE $ARCHIVE_FILE
cd $HOLDING_TANK
pwd
sudo tar -xpf $ARCHIVE_FILE $FOLDERS_TO_RESTORE_SOURCE
sudo tar -xpf $ARCHIVE_FILE ./$DB_FILE
cd ~
exit 0

# start rsync to back up the folders
#set maintenance on
sudo -u www-data php /var/www/html/occ maintenance:mode --on
echo -e "\e[34mMaintenance mode is on\e[0m"

echo -e "\e[34mRestore MySql database\e[0m"
#extract sqldb backup

#set the password before use this script, actually password is empty using:
#   - sudo mysql_secure_installation
sudo mysql -h localhost -uroot -pCapitanAmerica#2020 -e "DROP DATABASE nextcloud"
sudo mysql -h localhost -uroot -pCapitanAmerica#2020 -e "CREATE DATABASE nextcloud CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
sudo mysql -h localhost -uroot -pCapitanAmerica#2020 -e "GRANT ALL PRIVILEGES on nextcloud.* to nextcloud@localhost"

#sudo mysql -h localhost -unextclouduser -pNext#1995! nextcloud < $HOLDING_TANK/ncdb_`date +"%w"`.sql
sudo mysql -h localhost -unextcloud -padmin nextcloud < $HOLDING_TANK/ncdb_$CURRENT_TIME_FORMAT.sql

echo -e "\e[032mMySql restore success\e[0m"

#sudo mkdir -p $(dirname $ARCHIVE_FILE)
# restore all data
echo -e "\e[34mRestoring data $ARCHIVE_FILE\e[0m"
sudo rm -r -f $FOLDERS_TO_RESTORE_TARGET
sudo mkdir $FOLDERS_TO_RESTORE_TARGET -p
sudo mv $HOLDING_TANK/$FOLDERS_TO_RESTORE_TARGET $FOLDERS_TO_RESTORE_TARGET
# sudo chown -R www-data:www-data /nextcloud

sudo service php7.4-fpm restart
sudo service apache2 restart

sudo -u www-data php /var/www/html/occ maintenance:mode --off
echo -e "\e[32mMaintenance mode offe[0m"

echo -e "\e[2mend of job\e\[0m"
exit 0
