

# turn up or turn down a docker container

function turn-docker(){
    serverName=$1
    serviceName="${serverName%.*}"
    if [ "$2" = "up" ]; then
        action="$2 -d"
    else
        action="down"
    fi
    homedir=$PWD
    set -a; source backup_nextcloud.env; set +a
    
    environmentFile="$homedir/$serviceName/$serverName.env"
    echo $environmentFile

    cd "$homedir/$serviceName"
    if [[ -f $environmentFile ]]; then
        echo "$serviceName will be $action"
        set -a; source $environmentFile ; set +a
        docker-compose --env-file $environmentFile $action
        unset $(grep -v '^#' $environmentFile | sed -E 's/(.*)=.*/\1/' | xargs)
    else
        docker-compose $action
    fi
    cd $homedir
}
# turn-docker nginx up
# turn-docker mydeskweb.local up


turn-docker mydeskweb.local down
turn-docker nginx down

# exit 0
