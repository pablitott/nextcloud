#!/bin/bash
##################################################################
#   Syntax: docker-compose-start.sh <action> <environment>
#   Where:
#       action: up | down
#       environment: local | production
#check arguments provided
###################################################################

# Global variables
# list of services to turn on/off
if [[ $BASH_VERSINFO -lt 4 ]] ; then
    echo "You need to update bash to version 4+"
    exit 1
fi

if [[ $# < 2 ]]
then
    printf "Arguments error: syntax is:\n\tdocker-compose-start.sh <action> <environment>\n"
    printf "\twhere: action can be up or down\n"
    printf "\tEnvironment: Local/production\n" 
    exit 1
fi

case $1 in
    "up") action="up -d";;
    "down") action="down";;
    *) echo "Invalid option $1 options must be up/down"
    exit 1;;
esac

if [[ "$2" = "local" || "$2" = "production" ]]
then
    environment=$2
    echo "environment: $2" 
else
    echo "specify either <local> or <production> environments"
    exit 1
fi
exit 0
services="nginx paveltrujillo.info absolutehandymanservices.com questinnovations.net mydeskweb.com quenchinnovations.net"

echo "action: $action"
echo "Environment: $environment"

#check core service status
coreName=$(docker ps --filter name="nginx-proxy" --format {{.Names}})
echo "coreName: $coreName"
if [[ ! -z $coreName ]]; then
    nginxStatus=$(docker inspect nginx-proxy -f {{.State.Status}})
    echo "service: $coreName is $nginxStatus"
    letsencryptStatus=$(docker inspect nginx-proxy -f {{.State.Status}})
    NEXTCLOUD_NETWORK=$(docker inspect nginx-proxy -f {{.HostConfig.NetworkMode}})
    echo "Network: $NEXTCLOUD_NETWORK"
else
    echo "$coreName service is down"
fi

letsEncrypt=$(docker ps --filter name="letsencrypt-proxy-companion" --format {{.Names}})
echo "letsEncrypt: $letsEncrypt"
if [[ ! -z $letsEncrypt ]]; then
    letsEncryptStatus=$(docker inspect nginx-proxy -f {{.State.Status}})
    echo "service: $letsEncrypt is $letsEncryptStatus"
    letsencryptStatus=$(docker inspect letsencrypt-proxy-companion -f {{.State.Status}})
else
    echo "$letsEncrypt service is down"
fi

homedir=$PWD
buildOption=""
#check if amazon/aws-cli image exists, image used for aws commands
awscliImage=$(docker images amazon/aws-cli -q)
#pull amazon/aws-cli for aws-cli commands
if [[ -z $awscliImage && $action="up" ]]; then
    docker pull amazon/aws-cli
fi

if [ "$1" = "down" ]; then
    # for down services nginx must be the last
    services=$(echo ${services[@]}  | tac -s ' ')
fi
for service in ${services[@]}; do
    serverName="${service%.*}"
    if [ "$environment" = "local" ]; then 
        environmentFile=$serverName.local.env
    else
        environmentFile=$service.env
    fi
    cd $homedir/$serverName
    if [[ -f "Dockerfile"  && "$1" = "up" ]]; then
        buildOption="--build"
    fi
    
    if [[ -f $environmentFile ]]; then
        echo "turn $1 service $serverName using $environmentFile"
        docker-compose --env-file $environmentFile $action $buildOption
    else
        echo "NO environment file"
        docker-compose $action $buildOption
    fi
done
cd $homedir
#print summary
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Image}}"
