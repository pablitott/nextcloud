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
### change php ini file
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
 sudo chown -R www-data:www-data /nextcloud/mydeskweb.com/
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
>  
>  docker exec -u www-data quenchinnovations php occ maintenance:mode --off
>  docker exec -u www-data quenchinnovations php occ files:scan --all
>  docker exec -u www-data quenchinnovations php occ files:cleanup

List of users
>  docker exec -u www-data quenchinnovations php occ user:list
Reset password
> docker exec -u www-data quenchinnovations php occ user:resetpassword <user name> 
```

### change nextcloud config values using occ
[configuration server](https://docs.nextcloud.com/server/15/admin_manual/configuration_server/occ_command.html#config-commands-label)

save current configuration
> docker exec -it -u www-data mydeskweb.local php occ config:list --private > mydeskweb.local.json

import existing configuration
> docker exec -i -u www-data mydeskweb.local php occ config:import <br mydeskweb.local.json

after migration or restore is util to run
> docker exec -i -u www-data mydeskweb.local php occ files:scan <br/>
> docker exec -i -u www-data mydeskweb.local php occ files:cleanup <br/>
> docker exec -i -u www-data mydeskweb.local php occ user:resetpassword admin </br>
> docker exec -i -u www-data quenchinnovations.local php occ user:list

## docker cron tasks
>sudo crontab -l -u www-data
>*/15  *  *  *  * docker exec -it -u www-data quenchinnovations.net php -f /var/www/html/cron.php
>*/15  *  *  *  * docker exec -it -u www-data mydeskweb.com php -f /var/www/html/cron.php

## Update Nextcloud
> Source: [How to upgrade nextcloud in docker](https://forum.openmediavault.org/index.php?thread/31542-how-to-upgrade-nextcloud-in-docker/)
```
1. SSH to host
2. Run
  docker exec -it nextcloud sudo -u abc php /config/www/nextcloud/occ upgrade
3. run
  docker exec -it nextcloud sudo -u abc php /config/www/nextcloud/occ maintenance:mode --off
  
```

