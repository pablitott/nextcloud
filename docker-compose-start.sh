#!/bin/bash
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
homedir=$PWD
services=(questinnovations paveltrujillo mydeskweb quenchinnovations)

if [ "$1" = "up" ]; then
    docker-compose -f nginx/docker-compose.yml up -d

    for service in ${services[@]}; do
        echo $service
        cd $homedir/$service
        docker-compose --env-file env.$environment up -d
    done
    cd $homedir
else
    for service in ${services[@]}; do
        echo $service
        cd $homedir/$service
        docker-compose --env-file env.$environment down
    done

    cd $homedir
    docker-compose -f nginx/docker-compose.yml down
fi
