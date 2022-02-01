#!/bin/bash
#=======================================================#
#                                                       #
# Internal functions                                    #
#-------------------------------------------------------#
#=======================================================#
# Remove an element                                     #
#=======================================================#
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
        echo "Syntax error: Paramneters missed"
        echo "turn-docker <Server Name> <action>"
        echo "e.g. nextcloud-set webnotes.local up"
        echo "e.g. nextcloud-set webnotes.local down"
        return 1
    fi
    if [ -z $2 ]; then
        echo "Syntax error: Action missed"
        echo "turn-docker <Server Name> <action>"
        echo "e.g. nextcloud-set webnotes.local up"
        echo "e.g. nextcloud-set webnotes.local down"
        return 1
    fi
    options="up down stop pause unpause"
    action=$2
    [[ $options =~ (^| )$action($| ) ]] && isValid=1 || isValid=0
    if [ $isValid != 1 ]; then
        echo "Error: action \"$action\" is invalid"
        echo "valid actions: $options"
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
        echo "Service for \"$serverName\" does not exists or is down"
        echo "Try dpStatus to check the status"
        return 1
    fi
    currentpwd=$PWD
    homedir="$HOME/nextcloud"
    environmentFile="$homedir/$serviceName/$serverName.env"
    cd "$homedir/$serviceName"

    if [[ -f $environmentFile ]]; then
        echo "$serverName will be $action"
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
    unset services
    unset servers
    unset serversLocal
    servers=($(cat services | grep -v '#' ))  # include domain
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
        services=( "nginx" "${services[@]:0:nLenght}"   )
    else
        action=$1
        # Add nginx at the end of the list
        services=( "${services[@]:0:nLenght}" "nginx" )
    fi

    # echo ${servers[@]}
    # return 0
    currentdir=$PWD
    homedir="/home/vagrant/nextcloud"
    buildOption=""
    awscliImage=$(docker images amazon/aws-cli -q)
    if [ "$1" = "up" ] && [ -f "Dockerfile" ]; then
        buildOption="--build"
        if [[ -z $awscliImage ]]; then
            docker pull amazon/aws-cli
        fi
    fi

    for server in ${servers[@]}; do
        service="${server%.*}"
        if [ "$environment" = "local" ]; then
            environmentFile=$service.local.env
        else
            environmentFile=$domain.env
        fi
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
