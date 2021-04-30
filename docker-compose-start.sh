#!/bin/bash
##################################################################
#   Syntax: docker-compose-start.sh <action> <environment>
#   Where:
#       action: up | down
#       environment: local | production
#check arguments provided
if [[ "$1" = "up" ]]; then
    action="up -d"
else
    action=$1
fi
if [ -z "$2" ] ; then
    if [ -z "$NICKNAME" ] ; then
        echo "no NICKNAME is defined for this computer"
        echo "you can either define a NICKNAME variable or"
        echo "specify the environment as <local> or <production> as a second argument"
        exit 1
    else
        environment=$NICKNAME
    fi 
elif [[ "$2" = "local" || "$2" = "production" ]]; then
    environment=$2
    echo "environment: $2" 
else
    echo "specify either <local> or <production> environments"
    exit 1
fi
echo "action: $action $environment"

#check core service status
coreName=$(docker ps --filter name="nginx-proxy" --format {{.Names}})
echo "coreName: $coreName"
if [[ ! -z $coreName ]]; then
    nginxStatus=$(docker inspect nginx-proxy -f {{.State.Status}})
    echo "service: $coreName is $nginxStatus"
#    letsencryptStatus=$(docker inspect letsencrypt-proxy-companion -f {{.State.Status}})
    letsencryptStatus=$(docker inspect letsencrypt -f {{.State.Status}})
    NEXTCLOUD_NETWORK=$(docker inspect nginx-proxy -f {{.HostConfig.NetworkMode}})
else
    echo "core service is down"
fi

homedir=$PWD
if [ "$1" = "up" ]; then
    # for up services nginx must be the first
    services=(nginx paveltrujillo.info mydeskweb.com quenchinnovations.net )
else
    # for down services nginx must be the last
    services=(paveltrujillo.info mydeskweb.com quenchinnovations.net nginx)
fi
for service in ${services[@]}; do
    echo "turn $1 service $service"
    serverName="${service%.*}"
    if [ "$environment" = "local" ]; then 
        environmentFile=$serverName.local.env
    else
        environmentFile=$service.env
    fi
    cd $homedir/$serverName
    
    if [[ -f $environmentFile ]]; then
        docker-compose --env-file $environmentFile $action
    else
        docker-compose $action
    fi
done
cd $homedir
#print summary
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Image}}"
