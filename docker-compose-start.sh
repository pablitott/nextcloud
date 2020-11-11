#!/bin/bash
curpwd=$PWD

if [ "$1" = "up" ]; then
    docker-compose -f nginx/docker-compose.yml up -d
    docker-compose -f paveltrujillo.info/docker-compose.yml up -d
    cd mydeskweb
    if [[ "$2" = "production" ]]; then
        docker-compose --env-file mydeskweb.com.env up -d
    else
        docker-compose --env-file mydeskweb.local.env up -d
    fi
    cd $curpwd
    cd questinnovations
    if [[ "$2" = "production" ]]; then
        docker-compose --env-file mydeskweb.com.env up -d
    else
        docker-compose --env-file mydeskweb.local.env up -d
    fi
    cd $curpwd
else
    docker-compose -f paveltrujillo.info/docker-compose.yml down
    docker-compose -f questinnovations/docker-compose.yml down
    cd mydeskweb
    if [[ "$2" = "production" ]]; then
        docker-compose --env-file mydeskweb.com.env down
    else
        docker-compose --env-file mydeskweb.local.env down
    fi
    cd $curpwd
    cd questinnovations
    if [[ "$2" = "production" ]]; then
        docker-compose --env-file mydeskweb.com.env down
    else
        docker-compose --env-file mydeskweb.local.env down
    fi
    cd $curpwd
    docker-compose -f nginx/docker-compose.yml down
fi