#!/bin/bash
curpwd=$PWD
if [[ "$2" = "" ]]; then
    echo "please specify platform local/production"
    exit 1
fi
if [[ "$2" = "production" ]]; then
    services=(
        "paveltrujillo.info"
        "quenchinnovations.net"
        "atmosphericwatergenerator.net"
        "mydeskweb.com"
        "questinnovations.net"
    )
else
    services=(
        "quenchinnovations.local"
        "atmosphericwatergenerator.local"
        "mydeskweb.local"
    )
fi

if [ "$1" = "up" ]; then
    docker-compose -f nginx/docker-compose.yml up -d
    for service in ${services[@]}
    do
        serviceName="$(cut -d'.' -f1 <<<"$service")"
        environmentFile=$service.env
        cd $curpwd/$serviceName
        if [ -f "$environmentFile" ]; then
            docker-compose --env-file $environmentFile up -d
        else
            docker-compose up -d
        fi
    done
    cd $curpwd
else
    for service in ${services[@]}
    do
        serviceName="$(cut -d'.' -f1 <<<"$service")"
        environmentFile=$service.env
        cd $curpwd/$serviceName
        echo $PWD
        if [ -f "$environmentFile" ]; then
            docker-compose --env-file $environmentFile down
        else
            docker-compose down
        fi
    done
    cd $curpwd
    docker-compose -f nginx/docker-compose.yml down
fi