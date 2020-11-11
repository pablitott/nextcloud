#Stop the container(s) using the following command
docker stop $(docker ps -q -a  --filter Name=quenchinnovations.net)
docker stop $(docker ps -q -a  --filter Name=mariadb-quenchinnovations)
#Delete all containers using the following command:
#docker rm -f $(docker ps -a -q)
docker rm  $(docker ps -q -a  --filter Name=quenchinnovations.net)
docker rm $(docker ps -q -a  --filter Name=mariadb-quenchinnovations)

docker volume rm nextcloud_vol_db_qi
docker volume rm  nextcloud_vol_db_qi


# I think is no needed all the time, next time run it using force option
docker rmi $(docker images nextcloud -q -a)
docker rmi $(docker images mariadb -q -a)

#Restart the containers using the following command:

#Delete the folders created as /nextcloud/...
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 690049365056.dkr.ecr.us-east-1.amazonaws.com
#docker-compose up -d


