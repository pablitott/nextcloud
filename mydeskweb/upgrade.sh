if [[ -z "$1" ]]; then 
    echo "error: please provide new version number, aborting..."
    return 1
fi
newVersion=$1   
echo "new version: $newVersion"
# replace the new version in the base image
sed -E "s/image:\s+nextcloud:[0-9]+\.[0-9]+\.[0-9]+/image: nextcloud:${newVersion}/g" docker-compose.yml   > newVersion.yml
sleep 1
mv newVersion.yml Dockerfile

docker exec -u www-data mydeskweb.com php occ maintenance:mode --off
docker compose --env-file /home/ubuntu/nextcloud/mydeskweb/mydeskweb.com.env pull
#docker compose --env-file /home/ubuntu/nextcloud/mydeskweb/mydeskweb.com.env build
docker compose --env-file /home/ubuntu/nextcloud/mydeskweb/mydeskweb.com.env up

# docker exec -u www-data mydeskweb.com php occ upgrade
wait 60 seconds before execute next command
sleep 60
# fix missing indexes
docker exec -u www-data mydeskweb.com php occ db:add-missing-indices

# shut off maintenance mode and allow to update
docker exec -u www-data mydeskweb.com php occ maintenance:mode --off