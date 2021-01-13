# Nextcloud configuration

## Configuraging WebServer
### PHP configuration
    find the php configuration at /etc/php/7.4/apache2/php.ini and change following values
    - php_value upload_max_filesize 16G
    - php_value post_max_size 16G

    change following values if you see PHP timeouts in your logfiles
    - php_value max_input_time 3600
    - php_value max_execution_time 3600
    
##
### change psp ini file 
[how to change PHP settings with inline replacements](https://davescripts.com/docker-container-how-to-change-php-settings-inline-replacements)
```
RUN=docker exec -it nextcloud-mydeskweb.com
RUN sed -E -i -e 's/post_max_size = 8M/post_max_size = 16G/' /usr/local/etc/php/php.ini-production               
RUN sed -E -i -e 's/upload_max_filesize = 2M/upload_max_filesize = 16G/' /usr/local/etc/php/php.ini-production
```
## Manual upgrade<br/>
[How to upgrade nextcloud manually](https://docs.nextcloud.com/server/latest/admin_manual/maintenance/manual_upgrade.html)
### change data attributes
```
 sudo find /nextcloud/mydeskweb.com/ -type d -exec chmod 755 {} \;
 sudo find /nextcloud/mydeskweb.com/ -type f -exec chmod 740 {} \;

```
## [nextcloud conf file](https://docs.nextcloud.com/server/11/admin_manual/configuration_server/config_sample_php_parameters.html?highlight=filesystem_check_changes)

## Clean file locks
[How to clean up nextcloud stale locked files](https://zedt.eu/tech/linux/how-to-clean-up-nextcloud-stale-locked-files/)<br/>
```bash
docker-compose exec -u www-data quenchinnovations php occ maintenance:mode --on
docker exec -it mariadb-quenchinnovations mysql -uroot -ptoor
```
```mysql
    DELETE FROM oc_file_locks WHERE 1
```
docker-compose exec -u www-data quenchinnovations php occ files:scan admin
```
>  docker-compose exec -u www-data quenchinnovations occ maintenance:mode --off
>  docker-compose exec -u www-data quenchinnovations php occ files:scan --all
>  docker-compose exec -u www-data quenchinnovations php occ files:cleanup

List of users
>  docker-compose exec -u www-data quenchinnovations php occ user:list
Reset password
> docker-compose exec -u www-data quenchinnovations php occ user:passwordreset <user name> 
