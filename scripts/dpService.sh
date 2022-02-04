#!/bin/bash
#=======================================================#
#                                                       #
# Internal functions                                    #
#-------------------------------------------------------#
#=======================================================#
# Remove an element                                     #
#=======================================================#
# readonly _color_grey_="\e[30m"
# readonly _color_red_="\e[31m"
# readonly _color_green_="\e[32m"
# readonly _color_yellow_="\e[33m"
# readonly _color_blue_="\e[0;34m"
# readonly _color_purple_="\e[35m"
# readonly _color_cyan_="\e[36m"
# readonly _color_white_="\e[37m"
# readonly _color_reset_="\e[0m"
#=================================================
# todo: tempral user of variables
export NEXTCLOUD_HTTP_ROOT="/nextcloud"
export NEXTCLOUD_HTTP_WWW="$NEXTCLOUD_HTTP_ROOT/www"
export AWS_S3_ROOT="s3://s3quenchinnovations/backups"
export HTTP_USER='www-data'

function echoError(){
  echo -e "\t\e[31m$1\e[0m"
}
function echoWarning(){
   echo -e "\t\e[33m$1\e[0m"
}
function echoSuccess(){
    echo -e "\e[32m$1\e[0m"
}
function ArrayRemove(){
    ArrayLenght=${#servers[@]}
    # remove 3rd element
    arr=( "${arr[@]:0:1}" "${arr[@]:$ArrayLenght}" )
}
function ArrayAdd(){
    # remove 3rd element
    arr+=("new value")
}

#=======================================================#
#                                                       #
# Show the status for all containers                    #
# Syntax:  dps                                          #
#=======================================================#
function dps(){ docker ps --format "table {{.ID}}\t{{.Names}}\t{{.State}}\t{{.Size}}\t{{.Image}}"; }
#=======================================================#
#                                                       #
# Show the status for all images                        #
# Syntax:  dms                                          #
#=======================================================#
function dms(){ docker images --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"; }
#=======================================================#
#                                                       #
# turn up/down/pause/unpause                            #
# Syntax:  dpTurn <Server Name> <action>                #
#                                                       #
# e.g. dpTurn webnotes.local up                         #
#=======================================================#
function dpTurn(){
    if [ -z $1 ]; then
        echoError "Syntax error: Parameters missed"
        echoWarning "dpTurn <Server Name> <action>"
        echoWarning "e.g. nextcloud-set webnotes.local up" 
        echoWarning "e.g. nextcloud-set webnotes.local down"
        return 1
    fi
    if [ -z $2 ]; then
        echoError "Syntax error: Action missed"
        echoWarning "turn-docker <Server Name> <action>"
        echoWarning "e.g. nextcloud-set webnotes.local up" 
        echoWarning "e.g. nextcloud-set webnotes.local down"
        return 1
    fi
    # check the full name is provided
    domain=$( echo $1 | awk -F "." '{ print $2 }' )
    if [ -z $domain ]; then
        echoError  "Full server name must be provided e.g. webnotes.me or webnotes.local"
        return 1
    fi
    options="up down stop pause unpause"
    action=$2
    [[ $options =~ (^| )$action($| ) ]] && isValid=1 || isValid=0
    if [ $isValid != 1 ]; then
        echoError "Error: action \"$action\" is invalid"
        echoWarning "valid actions: $options"
    fi
    serverName=$1
    serviceName="${serverName%.*}"   # same as serverName with no extension
    if [ "$2" = "up" ]; then
        action="$2 -d"
    fi
    
    # show services status
    # docker ps --format "table {{.Names}}\t{{.State}}"
    servicesName=$(docker ps --format {{.Names}} )
    serviceStatus=$(docker ps --filter name="$serverName" --format {{.Names}})
    if [[ -z $serviceStatus && $action = 'down' ]]; then
        echoError "Service for \"$serverName\" does not exists or is down"
        echoWarning "Try dpStatus to check the status"
        return 1
    fi
    currentpwd=$PWD
    homedir="$HOME/nextcloud"
    environmentFile="$homedir/$serviceName/$serverName.env"
    cd "$homedir/$serviceName"

    if [[ -f $environmentFile ]]; then
        docker-compose --env-file $environmentFile $action
    else
        CONTAINER_NAME=$serverName docker-compose $action
    fi
    cd $currentpwd

}
#=======================================================#
#                                                       #
# Show the container status for specific service        #
# Syntax:  dpStatus [<Server Name>]                     #
# Server Name is optional if is not                     #
# provided return all the services                      #
# e.g. Display the status of webnotes                   #
# OR                                                    #
# e.g. dpStatus webnotes.local                          #
#      dpStatus webnotes                                #
#                                                       #
#=======================================================#
function dpStatus(){
    if [ -z $1 ]; then
        # no service name [provided]
        docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Size}}"
    else
        docker ps --filter name=$1 --format "table {{.Names}}\t{{.Status}}"
    fi
    
}
#=======================================================#
#                                                       #
# Turn up/down all the existing services                #
# Syntax:  dpStart <action> <environment>               #
#   where: <action>=up/down                             #
#          environment=local/production                 #
#                                                       #
#  Environment default = local                          #
#  TODO: before down a service verify is up             #
#                                                       #
#=======================================================#
function dpStart(){
    if [ -z $1 ]; then
        echoError "Syntax error: Parameters missed"
        echoWarning "dpStart <action> <location>"
        echoWarning "e.g. dpStart up local" 
        echoWarning "e.g. dpStart up aws"
        return 1
    fi
    if [ -z $2 ]; then
        echoError "Syntax error: Parameters missed"
        echoWarning "dpStart <action> <location>"
        echoWarning "e.g. dpStart up local" 
        echoWarning "e.g. dpStart up aws"
        return 1
    fi
    unset services
    unset servers
    unset serversLocal
    services=$(awk -F'.' '{print $1}' services | grep -v '#' )
    if [[ -z $2 || $2 = "local" ]]; then
        environment="local"
        servers=()
        for service in ${services[@]}; do
            servers+="$service.local "
        done
    else
        environment=$2
    fi

    nLenght=${#servers[@]}
    
    if [[ -z $1 || $1 = "up" ]]; then
        action="up -d"
        # include nginx at the begining of the list
        servers=( "nginx" "${servers[@]:0:nLenght}"   )
    else
        action=$1
        # Add nginx at the end of the list
        servers=( "${servers[@]:0:nLenght}" "nginx"  )
    fi

    # echo ${servers[@]}
    # return 0
    currentdir=$PWD
    homedir="/home/vagrant/nextcloud"
    buildOption=""
    # awscliImage=$(docker images amazon/aws-cli -q)
    # if [ "$1" = "up" ] && [ -f "Dockerfile" ]; then
    #     buildOption="--build"
    #     if [[ -z $awscliImage ]]; then
    #         docker pull amazon/aws-cli
    #     fi
    # fi

    for server in ${servers[@]}; do
        service="${server%.*}"
        environmentFile=$service.$environment.env
        cd "$homedir/$service"
        if [[ -f $environmentFile ]]; then
            echo "turn $1 service $service using $environmentFile"
            docker-compose --env-file $environmentFile $action $buildOption
        else
            CONTAINER_NAME=$server docker-compose $action
        fi
    done
    cd $currentdir

}
#=======================================================#
#                 dpRestore                             #
#-------------------------------------------------------#
# Restore services files                                #
# Syntax:  dprestore <service name>                     #
#                                                       #
#  TODO: extent to restore db data with the files       #
#                                                       #
#=======================================================#
function dpRestore(){
    if [ -z $1 ]; then
        echoError "Syntax error: Parameters missed"
        echoWarning "dpRestore <Server Name> <action>"
        echoWarning "e.g. nextcloud-set webnotes.local up" 
        echoWarning "e.g. nextcloud-set webnotes.local down"
        return 1
    fi
    service=$1
    remove=$2
    echo "remove: $remove"
    echo "service: $service"

    serviceRoot=$( echo $1 | awk -F "." '{ print $1 }' )
    domain=$( echo $1 | awk -F "." '{ print $2 }' )
    # in s3 folder name has no domain
    s3Folder=$AWS_S3_ROOT/$serviceRoot/
    # Local folder is full Name
    localFolder=$NEXTCLOUD_HTTP_WWW/$service
    echo "folder: $localFolder"
    #change the owner of the HTTP folder
    if [[ -d $localFolder ]]; then
        if [[ ! -z $2 ]]; then 
            echo "Removing $localFolder"
            sudo rm -r $localFolder
            sudo mkdir -p $localFolder
        else
            echoError "Folder $localFolder exists, delete folder before restore"
            return 1
        fi
    else
        sudo mkdir -p $localFolder
    fi
    source=$AWS_S3_ROOT/$domain/$serviceRoot/$serviceRoot.tar
    target=$NEXTCLOUD_HTTP_WWW/$service

    echo "source: $source"
    echo "target: $target"
    echo $source
    echo $target 
    
    dpTurn $service down
    aws s3 cp $source ./$serviceRoot.tar
    echo "error: $?"
    sudo tar -xvf ./$serviceRoot.tar -C $target .

    #change the ownership to HTTP_USER
    sudo chown -R $HTTP_USER:$HTTP_USER $localFolder

    #Change the folder/file permissions
    sudo find $localFolder -type f -exec chmod 774 {} \;
    rm -f ./$serviceRoot.tar

    # turn up the service
    dpTurn $service up
    return 0
}
function dpBackup(){
    # Note: Actually this script works only with www websites no Nextcloud yet
    if [ -z $1 ]; then
        echoError "Syntax error: Parameters missed"
        echoWarning "dpRestore <Server Name>"
        echoWarning "e.g. nextcloud-set webnotes.local" 
        echoWarning "e.g. nextcloud-set webnotes.me"
        return 1
    fi
    service=$1
    serviceRoot=$( echo $1 | awk -F "." '{ print $1 }' )
    domain=$( echo $1 | awk -F "." '{ print $2 }' )
    # AWS_S3_STORE="$AWS_S3_ROOT/$domain"

    # in s3 folder name has no domain
    S3FOLDER=$AWS_S3_ROOT/$domain
    # Local folder is full Name
    localFolder=$NEXTCLOUD_HTTP_WWW/$service
    echo $localFolder

    sudo tar -cvf /tmp/$serviceRoot.tar -C $NEXTCLOUD_HTTP_WWW/$service .
    aws s3 cp /tmp/$serviceRoot.tar $S3FOLDER/$serviceRoot/
    echo backup done
    return 0
    #     sudo tar -cvf /tmp/paveltrujillo.tar -C /nextcloud/www/paveltrujillo.local .
    #         no sudo tar -cjf /tmp/paveltrujillo.bz2 -C /nextcloud/www/paveltrujillo.local .
    # compress
    #     sudo tar -cvf /tmp/paveltrujillo.tar -C /nextcloud/www/paveltrujillo.local .
    # list
    #     sudo tar -tvf /tmp/paveltrujillo.bz2
    # uncompress
    #     sudo mkdir /tmp/paveltrujillo.info
    #     sudo tar -xvf /tmp/paveltrujillo.tar -C /tmp/paveltrujillo.info .
}