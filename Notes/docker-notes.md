
# Nextcloud in Docker containers
---
[Install nextcloud server using Docker images](https://hub.docker.com/_/nextcloud)
[How to install NextCloud in your server with Docker](https://blog.ssdnodes.com/blog/installing-nextcloud-docker/)

---
```yaml {.line-numbers}
  mydeskweb:
    image: nextcloud:latest
    container_name: nextcloud-mydeskweb.com
    networks:
      - nextcloud_network
    depends_on:
      - letsencrypt
      - proxy
      - db
    volumes:
      - /nextcloud/mydeskweb.com/html:/var/www/html
      - /nextcloud/mydeskweb.com/config:/var/www/html/config
      - /nextcloud/mydeskweb.com/custom_apps:/var/www/html/custom_apps
      - /nextcloud/mydeskweb.com/data:/var/www/html/data
      - /nextcloud/mydeskweb.com/themes:/var/www/html/themes
      - /etc/localtime:/etc/localtime:ro
    environment:
      - VIRTUAL_HOST=mydeskweb.com
      - LETSENCRYPT_HOST=mydeskweb.com
      - LETSENCRYPT_EMAIL=pablitott@gmail.com
      - NEXTCLOUD_ADMIN_USER=admin
      - NEXTCLOUD_ADMIN_PASSWORD=**************
      - MYSQL_DATABASE=db
      - MYSQL_USER
      - MYSQL_PASSWORD 
      - MYSQL_HOST

    restart: unless-stopped

```
![Tux, Linux](tux.png)
## Useful nextcloud commands to use in docker

Stop the container(s) using the following command
```
docker-compose down
```

Delete all containers using the following command:

```
   docker rm -f $(docker ps -a -q)   **use the force argument -f**
   docker rm $(docker ps -a -q)
```

Delete all volumes using the following command:
```
    docker volume rm $(docker volume ls -q)
```

delete current images
```
   docker rmi $(docker images -a -q)
```

Restart the containers using the following command:
```
   docker-compose up -d
```
### save docker images [docker save image](https://docs.docker.com/engine/reference/commandline/save/)
```
docker save --output [tar image name] [docker image to save]
docker save --output 
```
### load docker images [docker load images](https://docs.docker.com/engine/reference/commandline/load/)
```
  Not implemented yet
```

### Backup a database
```
   docker run -it mariadb bash
   mariadb is the container name
   connect using root
   docker exec -it e4c973a42bdb mysql -uroot -p"CapitanAmerica#2020"

   backup database
   docker exec -it mariadb-mydeskweb.com mysqldump --single-transaction -u nextcloud -p"admin" mydeskweb > ./mydeskweb_db.sql
```
### Restore database
```
change root-password by your root password below
change db-password by the nextcloud db user password below
docker exec -it mariadb-mydeskweb.com mysql -uroot -p"root-password" -e "DROP DATABASE mydeskweb"
docker exec -it mariadb-mydeskweb.com mysql -uroot -p"root-password" -e "CREATE DATABASE mydeskweb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
docker exec -it mariadb-mydeskweb.com mysql -uroot -p"root-password" -e "GRANT ALL PRIVILEGES on mydeskweb.* to nextcloud@localhost"
docker exec -i mariadb-mydeskweb.com mysql -unextcloud -pdb-password mydeskweb < /temp/repository/mydeskweb_db.sql

```

### To use the Nextcloud command-line interface (aka. occ command):
```
    $ docker exec --user www-data CONTAINER_ID php occ
    $ docker exec --user www-data nextcloud-mydeskweb.com php occ config:system:get trusted_domains
        or for docker-compose:
    $ docker-compose exec --user www-data app php 
```

### renew ssh certificates
```
docker exec nextcloud-letsencrypt /app/force_renew
```

### Reload nginx
```
docker exec -it nextcloud-proxy nginx -s reload
```

## php commands
### List php environment
```
docker exec -it nextcloud-mydeskweb.com php -i
```

**References**
- [allow upload big files](https://help.nextcloud.com/t/nextcloud-17-0-0-on-docker-container-where-is-the-php-ini-file/63413/10)

- [documents to allow big files](https://docs.nextcloud.com/server/17/admin_manual/configuration_files/big_file_upload_configuration.html)


```
$ docker ps
[...]
CONTAINER ID        IMAGE                                    COMMAND                  CREATED             STATUS              PORTS                                      NAMES
87e4f0cc7edd        jwilder/nginx-proxy:alpine               "/app/docker-entrypo…"   10 hours ago        Up 10 hours         0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   **nextcloud-proxy**

[...]
   $ docker exec -it nextcloud-proxy bash
   # vi /etc/nginx/nginx.conf
or 
   $ docker exec -it nextcloud-proxy vi /etc/nginx/nginx.conf

Then:
   http {
   …
   client_max_body_size 2048M;
   }
   docker exec -it nextcloud-proxy nginx -s reload
```
*and voila*

**Save docker container as image**
[create docker image](https://www.scalyr.com/blog/create-docker-image/)
save the container after it is modified

```
   docker ps
   CONTAINER ID        IMAGE                                    COMMAND                  CREATED             STATUS              PORTS                                      NAMES
*5aa026a1272b*        nextcloud-proxy                   "/app/docker-entrypo…"   12 seconds ago      Up 11 seconds       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nextcloud-proxy
eddd1e0bc13f        nextcloud:latest                         "/entrypoint.sh apac…"   3 hours ago         Up 3 hours          80/tcp                                     nextcloud-mydeskweb.com
2690e7a9a194        jrcs/letsencrypt-nginx-proxy-companion   "/bin/bash /app/entr…"   3 hours ago         Up 3 hours                                                     nextcloud-letsencrypt
e4c973a42bdb        mariadb                                  "docker-entrypoint.s…"   3 hours ago         Up 3 hours          3306/tcp                                   mariadb-mydeskweb.com

```
===
```
    save the container as an image
    $ docker commit nextcloud-proxy nextcloud-proxy-edited
    $docker ps
    CONTAINER ID        IMAGE                                    COMMAND                  CREATED             STATUS              PORTS                                      NAMES
5aa026a1272b        nextcloud-proxy-edited                   "/app/docker-entrypo…"   12 seconds ago      Up 11 seconds       0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp   nextcloud-proxy
e

```
### format docker outputs
```
  Images
  docker image list --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"
  Containers
  
  docker ps --format '{{.Image}}'
  docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Size}}"

```
[basics markdown guide](https://www.markdownguide.org/basic-syntax/)
