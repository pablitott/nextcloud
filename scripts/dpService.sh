#!/bin/bash
# use as: source dpService.sh
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
export _NEXTCLOUD_ROOT_FOLDER="/nextcloud"
export _NEXTCLOUD_WWW_FOLDER="$_NEXTCLOUD_ROOT_FOLDER/www"
export _AWS_S3_ROOT="s3://s3quenchinnovations/backups"
export _HTTP_USER='www-data'
export _WORK_DIR="$HOME/nextcloud"

unset build
function echoError(){
  echo -e "\t\e[31m$1\e[0m"
}
function echoWarning(){
   echo -e "\t\e[33m$1\e[0m"
}
function echoSuccess(){
    echo -e "\e[32m$1\e[0m"
}
function echoNote(){
    echo -e "\t\e[34m$1\e[0m"
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
function dps(){ docker ps $* --format "table {{.ID}}\t{{.Names}}\t{{.State}}\t{{.Size}}\t{{.Image}}\t{{.Ports}}"; }
#=======================================================#
#                                                       #
# Show the status for all images                        #
# Syntax:  dms                                          #
#=======================================================#
function dms(){ docker images $* --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"; }
#=======================================================#
#                                                       #
# Turns up/down the core container nginx                #
# Syntax:  dpCore <up>/<down>                           #
#=======================================================#
function dpCoreTurn(){
    if [ $1 = "up" ]; then action="up -d"; else action="$1"; fi
    currentdir=$PWD
    cd "$_WORK_DIR/nginx"
    docker compose $action
    cd $currentdir
    unset currentdir
    unset action
}
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
        echoWarning "e.g. dpTurn webnotes.local up" 
        echoWarning "e.g. dpTurn webnotes.com down"
        return 1
    fi
    if [ -z $2 ]; then
        echoError "Syntax error: Action missed"
        echoWarning "dpTurn <Server Name> <action>"
        echoWarning "e.g. dpTurn webnotes.local up" 
        echoWarning "e.g. dpTurn webnotes.com down"
        return 1
    fi
    # check the full name is provided
    domain=$( echo $1 | awk -F "." '{ print $2 }' )
    if [ -z $domain ]; then
        echoError  "Full server name must be provided e.g. webnotes.me or webnotes.local"
        return 1
    fi
    options="up down stop pause unpause restart build pull"
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
        docker compose --env-file $environmentFile $action
    else
        CONTAINER_NAME=$serverName docker compose $action
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
    server=$1
    currentFolder=$PWD
    format="table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Size}}\t{{.Ports}}"
    if [ -z $1 ]; then
        # no service name [provided]
        docker ps --format "${format}"
    else
        homedir="/home/$USER/nextcloud"
        service="${server%.*}"
        environmentFile=$server.env
        if [[ -d "$homedir/$service" ]]; then
            cd "$homedir/$service"
            if [[ -f $environmentFile ]]; then
                
                CONTAINER_NAME=$server docker compose --env-file=$environmentFile ps --format "${format}"
            else
                echo "Environment file does not exists, aborting..."
                # docker compose ps --format "${format}"
            fi
            cd $currentFolder
        else
            echo "Error: folder for $service does not exists!"
        fi
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
    dpTurn $1 up
}
function dpStop(){
    dpTurn $1 stop
}
function dpDown(){
    dpTurn $1 down
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
        echoWarning "dpRestore <Server Name>"
        echoWarning "e.g. dpRestore webnotes.local" 
        echoWarning "e.g. dpRestore webnotes.local"
        return 1
    fi
    service=$1
    remove=$2
    echo "remove: $remove"
    echo "service: $service"

    serviceRoot=$( echo $1 | awk -F "." '{ print $1 }' )
    domain=$( echo $1 | awk -F "." '{ print $2 }' )
    # in s3 folder name has no domain
    s3Folder=$_AWS_S3_ROOT/$serviceRoot/
    # Local folder is full Name
    localFolder=$_NEXTCLOUD_WWW_FOLDER/$service
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
    source=$_AWS_S3_ROOT/$domain/$serviceRoot/$serviceRoot.tar
    target=$_NEXTCLOUD_WWW_FOLDER/$service

    echo "source: $source"
    echo "target: $target"
    echo $source
    echo $target 
    
    dpTurn $service down
    aws s3 cp $source ./$serviceRoot.tar
    echo "error: $?"
    sudo tar -xvf ./$serviceRoot.tar -C $target .

    #change the ownership to _HTTP_USER
    sudo chown -R $_HTTP_USER:$_HTTP_USER $localFolder

    #Change the folder/file permissions
   sudo find $localFolder -type f -exec chmod 774 {} \;
    rm -f ./$serviceRoot.tar

    # turn up the service
    dpTurn $service up
    return 0
}
#=======================================================#
#                 dpBackup                             #
#-------------------------------------------------------#
# Restore services files                                #
# Syntax:  dpBackup <service name>                     #
#                                                       #
#  TODO: extent to backup db data with the files       #
#                                                       #
#=======================================================#
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
    # AWS_S3_STORE="$_AWS_S3_ROOT/$domain"

    # in s3 folder name has no domain
    S3FOLDER=$_AWS_S3_ROOT/$domain
    # Local folder is full Name
    localFolder=$_NEXTCLOUD_WWW_FOLDER/$service
    echo $localFolder

    sudo tar -cvf /tmp/$serviceRoot.tar -C $_NEXTCLOUD_WWW_FOLDER/$service .
    aws s3 cp /tmp/$serviceRoot.tar $S3FOLDER/$serviceRoot/
    echo backup done
    return 0
}
#=======================================================#
#                 dpKill                                #
#-------------------------------------------------------#
# Kills all containers, images and                      #
# volumes in a projects                                 #
#                                                       #
#  USE WITH EXTREME CAUTION                             #
# Syntax:  dpKill <service name>                        #
#                                                       #
#=======================================================#
function dpKill(){
    echoWarning "\t   <<<WARNING>>>"
    echoWarning "This script will kill and erase the whole components in a project $1"
    echoWarning "containers/images, volumes will be erased"
    echoWarning "it cannot be reverted"
    continue='No'
    read -p 'Continue? (only yes is accepted): ' continue
    echo "continue \"$continue\""
    service=$1
    project="${service%.*}"

    if [[ $continue != 'yes' ]]; then return 1; fi
    if [[ -d "$_WORK_DIR/$project" ]]; then
        echoSuccess "Project $project folder exists continue"
    else
        echoError "project $project folder does not exist...Abort"
        return 1
    fi
    unset projectImages
    unset projectContainers
    
    pwd=$PWD
    cd "$_WORK_DIR/$project"
    domain=$( echo $service | awk -F "." '{ print $2 }' )
    envFile=$project.$domain.env

    if [[ -f $envFile ]]; then
        projectImages=$(docker compose --env-file $project.$domain.env images -q)
        projectContainers=$(docker compose --env-file $project.$domain.env ps -q)
        docker compose --env-file $project.local.env kill
    else
        projectImages=$(docker --env-file=images compose -q)
        projectContainers=$(docker compose ps -q)
        CONTAINER_NAME=$serverName docker compose kill
    fi
    unset CONTAINER_NAME
    coreImage=$(docker images nginx:latest --format {{.ID}} ) 
    docker rm ${projectContainers}
    for image in $projectImages; do
        echo "image: $coreImage"
        if [[ ! $image = $coreImage ]]; then
            # TODO: Image is short while coreImage is long format
            #       Match the strings
            echo "removing: $image" 
            docker rmi ${image}
       fi
    done
    docker volume prune -f
    cd $pwd
}
########################################################
#                                                      #
# dpTurnAll <<action>>                                 #
#    valid actions: up down stop restart               #
#                                                      #
########################################################
function dpTurnAll(){
    services=(paveltrujillo.info mynotes.mydeskweb.com mydeskweb.com )
    core="nginx"
    options="up down stop restart"
    actionfound=0
    actionprovide=""
    for action in ${options[@]}
    do
        if [[ "$action" = "$1" ]]; then
            actionfound=1
            actionprovide=$action
            break
        fi
    done

    if [ $actionfound = 1 ]; then
        if [ "$actionprovide" = "down" ] || [ "$actionprovide" = "stop" ]; then
            for service in ${services[@]}
            do
                dpTurn "$service" "$actionprovide"
            done
            dpCoreTurn "$actionprovide"
        fi
        if [[ "$actionprovide" = "up" ]]; then
            dpCoreTurn "$actionprovide"
            for service in ${services[@]}
            do
                dpTurn $service "$actionprovide"
            done
        fi

        if [[ "$actionprovide" = "restart" ]]; then
            for service in ${services[@]}
            do
                dpTurn "$service" stop
            done
            dpCoreTurn "restart"

            for service in ${services[@]}
            do
                dpTurn "$service" "up"
            done

        fi
    else
        echo "Invalid action: must be one of: <<$options>>"
    fi

}