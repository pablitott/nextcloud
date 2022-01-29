# Backup and restore wp volumes
Since we have the data stored in volumes, we need to backup the volume content 

---

## Volumes are
to find the volume to backup execute
> $ docker volume ls
and look for the volumes associated
```
> absolutehandymanservices_dbdata for /var/lib/mysql<br/>
> absolutehandymanservices_wordpress for /var/www/html<br/>
```

## Backup commands
```
docker run --rm -v absolutehandymanservices_wordpress:/var/www/html -v /tmp:/backup ubuntu tar -cvf /backup/wp_backup.tar -V /volume /var/www/html <br>

docker run --rm -v absolutehandymanservices_dbdata:/var/lib/mysql -v /tmp:/backup ubuntu tar -cvf /backup/wp_db_backup.tar -V /volume /var/lib/mysql <br/>
```

## Restore commands
```
$ docker run --rm -v absolutehandymanservices_dbdata:/var/lib/mysql  -v /tmp:/backup alpine sh -c "rm -rf /volume/* /volume/..?* /volume/.[!.]* ; tar -C /volume/ -xpf /backup/wp_db_backup.tar" <br/>
```