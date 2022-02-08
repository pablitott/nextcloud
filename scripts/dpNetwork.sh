netToolsPresent=$(dpkg -l net-tools)
function IpAddress(){
    network=$1
    if [[ $netToolsPresent ]]; then
        ifconfig ${1:-$1} | awk '/inet / {print $2}';
    else
        ip a show dev ${1:-$1} | awk '/inet / {print $2}';
    fi
    unset network
}
function domainName(){
    echo $(hostname -d)
}
function macAddress(){
    network=$1
    if [[ $netToolsPresent ]]; then
        ifconfig ${1:-$network} | awk '/ether / {print $2}'
    else
        ip a show dev $1 | awk '/ether / {print $2}'
    fi
    unset network
    
}
function netMask(){
    network=$1
    if [[ $netToolsPresent ]]; then
        ifconfig ${1:-$network} | awk '/netmask / {print $2}'
    else
        ip a show dev $1 | awk '/netmask / {print $2}'
    fi
    unset network
}
function broadcast(){
    network=$1
    if [[ $netToolsPresent ]]; then
        ifconfig ${1:-$network} | awk '/broadcast / {print $2}'
    else
        ip a show dev $1 | awk '/broadcast / {print $2}'
    fi
    unset network
}
function getProperty(){
    # not working yet, ${print $2} is giving worn expansion
    network=$1
    if [[ $netToolsPresent ]]; then
        ifconfig ${1:-$network} | awk "/$property / {print $2}"
    else
        ip a show dev $network | awk "/$property / {print $2}"
    fi
    unset network
}