#!/bin/bash
# dirname "$0"
#=================================================================
#
#                  Syntax
#    excport HOMEDIR=/home/ubuntu/nextcloud
#    ./backup_nextcloud.sh <serviceName>
#    serviceName: quenchinnovations.net, quenchinnovations.local, mydeskweb.com, paveltrujillo.info, paveltrujillo.local
#
#=================================================================
#               Important notes
#  script variables are stored in backup_nextcloud.env
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
#  $ chown -R www-data:www-data  /nextcloud/data
#
#   Change file attributes for data folder
#     sudo find /nextcloud/mydeskweb.com/ -type d -exec chmod 755 {} \;
#     
#  
#===================================================================
#    TODO: 
#    - Configure symbolic links as per in step 5: https://linuxize.com/post/how-to-install-and-configure-nextcloud-on-ubuntu-18-04/
#====================================================================
#   TODO:
#   - include environment variables from mydeskweb.env using
#   export $(grep -v '^#' mydeskweb.env | xargs)
#   unset $(grep -v '^#' mydeskweb.env | sed -E 's/(.*)=.*/\1/' | xargs)
#
#   set -o allexport
#   source mydeskweb.env
#   set +o allexport
#   unset $(grep -v '^#' mydeskweb.env | sed -E 's/(.*)=.*/\1/' | xargs)

#   set -a 
#   . ./mydeskweb.env
#   set +a
#   unset $(grep -v '^#' mydeskweb.env | sed -E 's/(.*)=.*/\1/' | xargs)

#====================================================================

function showerror (){

  if [ $? == 0 ]; then
    writeLogLine "backup succeed " $_color_green_
    [ ! -z $notifyStatus ] && python2.7 ~/sendMail.py "Backup Succeed" $logfile
  else
    writeLogLine "\"${last_command}\" \n$_color_yellow_ command failed with exit code $?. " $_color_red_
    [ ! -z $notifyStatus ] &&  python2.7 ~/sendMail.py "backup failed" $logfile
  fi

  end_time="$(date -u +%s)"
  [ ! -z $start_time ] && elapsed="$(($end_time-$start_time))"
  [ ! -z $start_time ] && writeLogLine "Total $elapsed seconds elapsed for process" $_color_yellow_ 

  # I think following lines no needed
  #  unset $(grep -v '^#' $environmentFile | sed -E 's/(.*)=.*/\1/' | xargs)
  #  unset $(grep -v '^#' backup_nextcloud.env | sed -E 's/(.*)=.*/\1/' | xargs)  
}
#================================================================================
function backup_home(){
  verbose=$1
  tarOptions='-uf'
  [ ! -z $verbose ] && tarOptions="-uvf"
  writeLogLine "tar using $tarOptions" $_color_yellow_
  writeLogLine "packing $HOMEDIR Home to $ARCHIVE_FILE, exclude hidden folders" $_color_blue_
  sudo tar $tarOptions $ARCHIVE_FILE --exclude="./.*" --exclude="*.tar" --exclude="*.log"  ./
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
  writeLogLine "packing DB $serverName.db to $BACKUP_DATABASE_FILE ON $DATABASE_SERVICE" $_color_blue_
  docker exec $DATABASE_SERVICE mysqldump --single-transaction -h$DATABASE_SERVICE -u$MYSQL_USER -p$MYSQL_PASSWORD $serverName > $BACKUP_REPOSITORY/$BACKUP_DATABASE_FILE
 
  tar $tarOptions $ARCHIVE_FILE $BACKUP_REPOSITORY/$BACKUP_DATABASE_FILE
  unset verbose
  unset tarOptions
}
#================================================================================
function backup_files(){
  verbose=$1
  tarOptions='-uf'
  [ ! -z $verbose ] && tarOptions="-uvf"
  echo "$FOLDERS_DATA_BACKUP"
  for FOLDER in ${FOLDERS_DATA_BACKUP[@]}
  do
    echo "packing $FOLDER"
    if [ -d "$FOLDER" ];
    then
      writeLogLine "packing $FOLDER..." $_color_blue_
      sudo tar $tarOptions $ARCHIVE_FILE $FOLDER
    else
      writeLogLine "Skipping $FOLDER (does not exist!)" $_color_yellow_
    fi
  done
  unset tarOptions
  unset verbose
 }
#================================================================================
function backup_image(){
  dockerImages="$BACKUP_REPOSITORY/$serverName-images_$(date +$CURRENT_TIME_FORMAT).tar"
  #dockerImages="$BACKUP_REPOSITORY/$serverName.tar"
  writeLogLine "compressing images as $dockerImages " $_color_blue_
  docker save $(docker images -q) -o $dockerImages
}
#================================================================================
function occCmd(){
  docker exec -it --user www-data $serviceName php occ $*
}
#================================================================================
function awsCmd(){
  echo $*
  docker run --rm -i  -v $(pwd):/aws pablitott/myawscmd:latest $*
}
#define global variables
if [ -z "$HOMEDIR" ] ; then
    echo "HOMEDIR is not defined, please define HOMEDIR accordingly"
    return -1
fi
echo "USER: $USER"
echo "HOMEDIR: $HOMEDIR"
cd $HOMEDIR

#================================================================================
#            include subroutines
source ./writeLogLine.sh  &1>/dev/null     # write fancy output to console
source ./folderMaintenance.sh              # create/remove folders
#=================================================
# exit when an error ocurred
# set -e
# keep track of the last executed command
# trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
#  ####   trap showerror exit
#Send an email message at the end of the process
# notifyStatus=0

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
[ "$2" == "-full" ] && FULL_BACKUP=1

serviceName=$1
serverName="${serviceName%.*}"
writeLogLine "serverName:$serverName" $_color_blue_
writeLogLine "serviceName: $serviceName" $_color_blue_

environmentFile="$HOMEDIR/$serverName/$serviceName.env"

set -a; source $environmentFile; set +a
set -a; source backup_nextcloud.env; set +a

logfileName="backup-$serverName-$(date +$CURRENT_TIME_FORMAT).log"
logfile="$HOMEDIR/$serverName/$logfileName"

[ -f $logfile ] && rm $logfile
writeLogLine "logfile: $logfile" $_color_blue_

writeLogLine "START Backup process on $NEXTCLOUD_TRUSTED_DOMAINS" $_color_purple_
start_time="$(date -u +%s)"

FOLDERS_DATA_BACKUP=(
"$NEXTCLOUD_HTTP_ROOT"
)

# TODO: review how to check if the docker sergvice exists, quenchinnovations returns 2 values
#       quenchinnovations.net returns only one value which is the correct vsalue expected

if [ $DATABASE_SERVICE ]; then 
  # set maintenance on only when DATABASE_SERVICE is defined
  occCmd maintenance:mode --on | tee -a $logfile
fi
removeFolder "$BACKUP_REPOSITORY"
createFolder "$BACKUP_REPOSITORY"

#do not backup the images in a regular backup
# backup_image
# is a database defined for the service?
if [ -z $DATABASE_SERVICE ]; then 
  writeLogLine "No database is defined for $serverName"$_color_yellow_
else
  backup_database verbose
fi
backup_home verbose
backup_files 
currentdir=$(pwd)
if [ $DATABASE_SERVICE ]; then 
  occCmd maintenance:mode --off | tee -a $logfile
fi
for file in $BACKUP_REPOSITORY/*.tar
do
    backup_file_name=$(basename $file)
    writeLogLine "$(basename $file) Size: $(stat --printf='%s' $file | numfmt --to=iec) " $_color_green_
    writeLogLine "Backup to $BACKUP_S3BUCKET/$NICKNAME/$NEXTCLOUD_TRUSTED_DOMAINS/" $_color_blue_
    writeLogLine "Change directory to: $BACKUP_REPOSITORY"
    cd $BACKUP_REPOSITORY
    writeLogLine "current folder $PWD"
    writeLogLine "awsCmd s3 cp $backup_file_name $BACKUP_S3BUCKET/$NICKNAME/$NEXTCLOUD_TRUSTED_DOMAINS/$backup_file_name"
    awsCmd s3 cp $backup_file_name $BACKUP_S3BUCKET/$NICKNAME/$NEXTCLOUD_TRUSTED_DOMAINS/$backup_file_name >> awscmd.log 2>&1
    error=$?
    
    if [ $error == 0 ]; then
      writeLogLine "awscmd process succeed!" $_color_green_
    else
      writeLogLine "awscmd backup error, see awscmd.log" $_color_red_
      cp awscmd.log $HOMEDIR/$serverName/
    fi
    writeLogLine "backup process error: $error"
done
cd $currentdir

#Remove Archive folder without condition
# writeLogLine "Backup folder: $BACKUP_REPOSITORY"
removeFolder $BACKUP_REPOSITORY
writeLogLine " end of job " $_color_green_

return 0


