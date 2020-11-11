#!/bin/bash
#=================================================================
#
#                  Syntax
#    ./backup_nextcloud.sh <serviceName>
#    serviceName: quenchinnovations, mydeskweb
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
    [ ! -z $notifyStatus ] &&  python2.7 ~/sendMail.py "Restore failed" $logfile
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
  writeLogLine "packing $PWD Home to $ARCHIVE_FILE, exclude hidden folders" $_color_blue_
  sudo tar $tarOptions $ARCHIVE_FILE --exclude="./.*" --exclude="*.tar"   ./
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
  writeLogLine "packing DB $serverName.db to $BACKUP_DATABASE_FILE"
  docker exec -it $DATABASE_SERVICE mysqldump --single-transaction -h$DATABASE_SERVICE -u$MYSQL_USER -p$MYSQL_PASSWORD $serverName > $BACKUP_REPOSITORY/$BACKUP_DATABASE_FILE
 
  sudo tar $tarOptions $ARCHIVE_FILE $BACKUP_REPOSITORY/$BACKUP_DATABASE_FILE
  unset verbose
  unset tarOptions
}
#================================================================================
function backup_files(){
  verbose=$1
  tarOptions='-uf'
  [ ! -z $verbose ] && tarOptions="-uvf"

  for FOLDER in ${FOLDERS_DATA_BACKUP[@]}
  do
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
  docker run --rm -ti -v ~/.aws:/root/.aws -v $(pwd):/aws amazon/aws-cli $*
}
#================================================================================
#            include subroutines
source ./writeLogLine.sh  &1>/dev/null     # write fancy output to console
source ./folderMaintenance.sh              # create/remove folders
#=================================================

# exit when an error ocurred
set -e
# keep track of the last executed command
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
# echo an error message before exiting
trap showerror exit
#Send an email message at the end of the process
# notifyStatus=0
if [ -z $1 ] ; then
    writeLogLine "ServerName to be backup is not defined, please define ServerName accordingly" $_color_red_
    exit -1
fi

serviceName=$1
serverName="${serviceName%.*}"

#check if NICKNAME is defined, True if the length of string is zero
if [ -z "$NICKNAME" ] ; then
    writeLogLine "NICKNAME is not defined, please define nickname accordingly" $_color_red_
    exit -1
fi
#check if USER is defined, True if the length of string is zero
if [ -z "$USER" ] ; then
    writeLogLine "USER is not defined, please define $USER accordingly" $_color_red_
    exit -1
fi
[ "$2" == "-full" ] && FULL_BACKUP=1

logfile="$PWD/restore-$serverName.log"
environmentFile=$serverName.env

set -a; source $environmentFile; set +a
set -a; source backup_nextcloud.env; set +a

[ -f $logfile ] && rm $logfile

writeLogLine "START Backup process on $NEXTCLOUD_TRUSTED_DOMAINS" $_color_purple_
start_time="$(date -u +%s)"

FOLDERS_DATA_BACKUP=(
"$DATA_ROOT/$serviceName"
)

# TODO: review how to check if the docker sergvice exists, quenchinnovations returns 2 values
#       quenchinnovations.net returns only one value which is the correct vsalue expected
#set maintenance on
occCmd maintenance:mode --on | tee -a $logfile

removeFolder "$BACKUP_REPOSITORY"
createFolder "$BACKUP_REPOSITORY"

#do not backup the images in a regular backup
# backup_image
backup_database
backup_home verbose
backup_files

occCmd maintenance:mode --off | tee -a $logfile
for file in $BACKUP_REPOSITORY/*.tar
do
    writeLogLine "$(basename $file) Size: $(stat --printf='%s' $file | numfmt --to=iec) " $_color_green_
    writeLogLine "Backup to $BACKUP_S3BUCKET/$NICKNAME/$NEXTCLOUD_TRUSTED_DOMAINS/" $_color_blue_
    aws s3 cp $file $BACKUP_S3BUCKET/$NICKNAME/$NEXTCLOUD_TRUSTED_DOMAINS/ | tee -a $logfile
#    awsCmd s3 cp $file $BACKUP_S3BUCKET/$NICKNAME/$NEXTCLOUD_TRUSTED_DOMAINS/
done

#Remove Archive folder without condition
removeFolder $BACKUP_REPOSITORY
writeLogLine " end of job " $_color_green_

exit 0


