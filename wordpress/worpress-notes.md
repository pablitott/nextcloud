# Wordpress docker-compose settings

For Wordpres I'm following kind of same settings as NextCloud, the Wordpress files are located under /worpress/siteName
where site name is the .local or .com | .net

## Naming convention
> serviceName=absolutehandymanservices <br/>
> siteName=absolutehandymanservices.local <br/>
> hostName=dockerMachine1 <br/>
> NICKNAME=local <br/>
> environment file: .env

Permissions
````bash
sudo chown -R bitnami:daemon TARGET
sudo find TARGET -type d -exec chmod 775 {} \;
sudo find TARGET -type f -exec chmod 664 {} \;
sudo chmod 640 TARGET/wp-config.php
````

To Create the containers use following command
> docker-compose --env-file wordpress.local.env up -d

To shutdown the website
docker-compose --env-file wordpress.local.env down

file attributes for worpress HTML:
```bash
sudo find wp-content/uploads/2022/02/ -type f -exec chmod 664 {} \;
sudo find wp-content/uploads/2022/02/ -type f -exec chown 82:82 {} \;
# 82 is the user id from the container
````
Checking the users in the container absolutehandymanservices.com as
````bash
docker exec -i absolutehandymanservices.com  cat /etc/passwd
    www-data:x:82:82:Linux User,,,:/home/www-data:/sbin/nologin
````
I do realize the user www-data has an ID of 82

and the user id for www-data on the VM is 
````bash
cat /etc/passwd | grep www-data
     www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
````
this is why I have to set the permissions using the user ID from container


To rebuild the containers you can use the rebuild-wordpress.sh, but running following command is enough
````bash
docker-compose --env-file wordpress.local.env down --volumes
````

following command stop, delete containers and the volumes, allow to start the project from scratch
docker-compose kill

TODO: change the container-name in docker-compose file, remember the volume will be deleted

at this time password: qwuEB^Fvofo!O4zyA^