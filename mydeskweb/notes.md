full docker-compose example
https://hub.docker.com/_/nextcloud

to fix error: error Legacy cipher is no longer supported
```bash
docker exec -u www-data mydeskweb.cron crontab
docker exec -u www-data mydeskweb.com php occ trashbin:cleanup --all-users
docker exec -u www-data mydeskweb.com php occ versions:cleanup
```
And setting 'encryption.legacy_format_support' => true, in config.php in nextcloud/config

and
```bash
docker compose --env-file mydeskweb.com.env restart
```

### Remove log files
docker exec -it mydeskweb.com truncate /var/www/html/data/nextcloud.log --size 0
or 
truncate /nextcloud/mydeskweb.com/data/nextcloud.log
