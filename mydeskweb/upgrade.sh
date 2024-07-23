if [[ -z "$1" ]]; then 
    echo "error: please provide new version number, aborting..."
    return 1
fi
newVersion=$1   
echo "new version: $newVersion"
# replace the new version in the base image
sed -E "s/[0-9]+\.[0-9]+\.[0-9]+/${newVersion}/g" ../nextCloudImage/Dockerfile  > ../nextCloudImage/newVersion
sleep 1
mv ../nextCloudImage/newVersion ../nextCloudImage/Dockerfile

docker compose --env-file /home/ubuntu/nextcloud/mydeskweb/mydeskweb.com.env down
docker compose --env-file /home/ubuntu/nextcloud/mydeskweb/mydeskweb.com.env build
docker compose --env-file /home/ubuntu/nextcloud/mydeskweb/mydeskweb.com.env up


docker exec -u www-data mydeskweb.com php occ maintenance:mode --off
docker exec -u www-data mydeskweb.com php occ upgrade

# fix missing indexes
docker exec -u www-data mydeskweb.com php occ db:add-missing-indices

# shut off maintenance mode and allow to update
docker exec -u www-data mydeskweb.com php occ maintenance:mode --off