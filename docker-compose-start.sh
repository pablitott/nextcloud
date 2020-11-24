#!/bin/bash
#check arguments provided
if [[ "$1" = "up" ]]; then
    action="up -d"
elif [[ "$1" = "down" ]]; then
    action=$1
else
    echo "specify either <up> or <down> actions"
    exit 1
fi
if [[ "$2" = "local" || "$2" = "production" ]]; then
    echo "environment: $2" 
else
    echo "specify either <local> or <production> environments"
    exit 1
fi
environment=$2
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
    services=(nginx questinnovations paveltrujillo mydeskweb quenchinnovations)
elif [ "$1" = "down" ]; then
    # for down services nginx must be the last
    services=(questinnovations paveltrujillo mydeskweb quenchinnovations nginx)
fi
for service in ${services[@]}; do
    echo "turn $1 service $service"
    cd $homedir/$service
    if [[ -f env.$environment ]]; then
        docker-compose --env-file env.$environment $action
    else
        docker-compose $action
    fi
done
cd $homedir
#print summary
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Size}}\t{{.Image}}"
