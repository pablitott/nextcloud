#!/bin/bash
#####################################################################################
#
#   occCmd <ServiceName> <occ Command>
#
#   execute an occ command for NextCloud
#   <ServiceName>    quenchinnovations.net or mydeskweb.com
#   <occCmd> for a full list see https://docs.nextcloud.com/server/stable/admin_manual/configuration_server/occ_command.html#maintenance-commands-label
#####################################################################################
function occCmd()
{
    _color_red_="\e[31m"
    _color_reset_="\e[0m"

    if [ -z $1 ] ; then
        message="Service name is not provided, Syntax: occCmd <ServiceName> \n Where service Name would either QuestInnovations.net or mydeskweb.com"
        echo $message
        return
    fi
    echo $*
    ServiceName=$1
    docker exec --user www-data $ServiceName php occ $2 $3 $4

}

