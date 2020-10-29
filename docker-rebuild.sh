#Stop the container(s) using the following command
docker-compose down

#Delete all containers using the following command:
#docker rm -f $(docker ps -a -q)
docker rm $(docker ps -a -q)

#Delete all volumes using the following command:
docker volume rm $(docker volume ls -q)


#following commands are optional for full clean
#delete current images

# I think is no needed all the time, next time run it using force option
docker rmi $(docker images -a -q)
#Restart the containers using the following command:

#Delete the folders created as /nextcloud/...
#aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 690049365056.dkr.ecr.us-east-1.amazonaws.com
#docker-compose up -d


