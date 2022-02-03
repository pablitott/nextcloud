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
```
sudo chown -R www-data:www-data /wordpress/absolutehandymanservices.local
sudo find /wordpress/absolutehandymanservices.local -type d -exec chmod 0755 {} \;
sudo find /wordpress/absolutehandymanservices.local -type f -exec chmod 644 {} \;
```

To rebuild the containers you can use the rebuild-wordpress.sh, but running following command is enough
> docker-compose --env-file wordpress.local.env down --volumes

above command stop, delete containers and the volumes, allow to start the project from scratch


TODO: change the container-name in docker-compose file, remember the volume will be deleted

at this time password: qwuEB^Fvofo!O4zyA^