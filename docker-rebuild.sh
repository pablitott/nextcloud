#Stop the container(s) using the following command
docker-compose down

#Delete all containers using the following command:
#docker rm -f $(docker ps -a -q)
docker rm $(docker ps -a -q)

#Delete all volumes using the following command:
docker volume rm $(docker volume ls -q)


#following commands are optional for full clean
#delete current images
docker rmi $(docker images -a -q)
#Restart the containers using the following command:

#Delete the folders created as /nextcloud/...

docker-compose up -d


