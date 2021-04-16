# Nextcloud migration
## Specific tasks
### Change database name used in NextCloud
database name is defined in config.php to change the database name thesescripts must be done
- Change the database name on docker-compose
- Change the database name in the Backup/Restore scripts
- Execute following scripts to change the database name in config.php
reg expression to find an string in config file
```bash
$   sudo sed -n '/\'dbhost\'[[:space:]]\=\>[[:space:]]\'db_quenchinnovations\','/p' <path to php config>
```

- get the existing line in config.php
```bash
    configFile="/nextcloud/quenchinnovations.net/config/config.php"
    oldDatabase="db_quenchinnovations"
    olddbLine=sudo $(sed -n '/\'dbhost\'[[:space:]]\=\>[[:space:]]\'$oldDatabase\','/p' $configFile)

```
- now replace old database for new database in th line
```bash
    newDatabase="mariadb"
    newdbLine=$(sed -s 's/'$oldDatabase'/'$newDatabase'/g' <<< $olddbLine)
```
- now replace the old line for the new line in the config.file
```bash
    sudo sed -i "s/$olddbLine/$newdbLine/g" $configFile
```


