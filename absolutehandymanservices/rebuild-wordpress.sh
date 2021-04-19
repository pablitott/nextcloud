#!/bin/bash
#
# Remove wordpress docker images
docker-compose down
# docker rm db
# docker rm wordpress
# docker rm webserver
# docker rm certbot

docker rmi mysql:8.0
docker rmi wordpress:5.1.1-fpm-alpine
docker rmi nginx

#docker volume rm wordpress_certbot_etc
docker volume rm wordpress_wordpress
docker volume rm wordpress_dbdata
