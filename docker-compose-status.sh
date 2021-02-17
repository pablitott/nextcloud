#################################################################
#
#  docker-compose-status
#
#  check the status for all docker containers 
#
#################################################################
# Inspect the status for specific container
#  docker inspect letsencrypt-proxy-companion -f {{.State.Status}}
#  docker inspect nginx-proxy -f {{.HostConfig.NetworkMode}}