#TODO:
#    Review paths, this file was moved from ~/nextcloud  to ~/nextcloud/quenchinnovations
#
# purpose: execute command manually to track errors
# use in the migration of quenchinnovations to Lightsails
#commands to initialize data base, hardcoded on purpose
#hard coded file to restore quenchinnovations fro

set -a; source quenchinnovations.env; set +a
set -a; source backup_nextcloud.env; set +a

echo "removing ./$FOLDER_ROOT if exists"
[ -d ./$FOLDER_ROOT ] && sudo rm -rd ./$FOLDER_ROOT    # remove ./nextcloud

echo "removing ./$DB_FOLDER if exists"
[ -d ./$DB_FOLDER ] && sudo rm -rd ./$DB_FOLDER  # remove ./temp

aws s3 cp $BACKUP_S3BUCKET/$NEXTCLOUD_SERVICE/$BACKUP_TAR_FILE $BACKUP_TAR_FILE
echo "untar $BACKUP_TAR_FILE"
sudo tar -xpf ./$BACKUP_TAR_FILE            #untar all files

docker-compose exec -u www-data $NEXTCLOUD_SERVICE php occ maintenance:mode --on

docker exec -it $DB_SERVICE mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $MYSQL_DATABASE;"
docker exec -it $DB_SERVICE mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"

docker exec -it $DB_SERVICE mysql -h $MYSQL_HOST -uroot -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER IF EXISTS $MYSQL_USER;"
docker exec -it $DB_SERVICE mysql -h $MYSQL_HOST -uroot -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER '$MYSQL_USER' IDENTIFIED BY '$MYSQL_PASSWORD';"
docker exec -it $DB_SERVICE mysql -h $MYSQL_HOST -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT USAGE ON *.* TO '$MYSQL_USER'@'$DB_SERVICE' IDENTIFIED BY '$MYSQL_PASSWORD';" 
docker exec -it $DB_SERVICE mysql -h $MYSQL_HOST -uroot -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES on $MYSQL_DATABASE.* to $MYSQL_USER;" 
docker exec -it $DB_SERVICE mysql -h $MYSQL_HOST -uroot -p"$MYSQL_ROOT_PASSWORD" -e "FLUSH PRIVILEGES;"

docker exec -it $DB_SERVICE mysql -h $MYSQL_HOST -uroot -p"$MYSQL_ROOT_PASSWORD" -e "select user, host from mysql.user;"

docker exec -i $DB_SERVICE mysql -h $MYSQL_HOST -u$MYSQL_USER -p"$MYSQL_PASSWORD" $MYSQL_DATABASE < ./$DB_FOLDER/data/ncdb_6.sql

docker-compose down

sudo rm -r /$FOLDER_ROOT/$WEB_SERVICE/data
sudo mv ./$FOLDER_ROOT/$NEXTCLOUD_SERVICE /$FOLDER_ROOT/$WEB_SERVICE/data

aws s3 cp s3://s3quenchinnovations/backups/quenchinnovations/nc_quenchinnovations.tar nc_quenchinnovations.tar
tar -tvf nc_quenchinnovations.tar var/www/quenchinnovations/config/config.php
# fix values in /nextcloud/quenchinnovations.net/config/config.config.php for values:
# after restore when can't login with admin is because the following values does not match
#  'instanceid' => 'ocovmzo9yy6b',
#  'passwordsalt' => 'xXYssu4Hnzjhgya3Bk4xzSDD/7Pxez',
#  'secret' => 'm28XuyvLRAmAITfiSnUeScVkqWrdHlMN7J4ftU4+dpcpWVS7',

# USE THE original CONFIG.PHP the upndate accordingly

docker-compose up -d

docker-compose exec -u www-data $NEXTCLOUD_SERVICE php occ maintenance:mode --off
docker-compose exec -u www-data $NEXTCLOUD_SERVICE php occ files:scan-app-data
docker-compose exec -u www-data $NEXTCLOUD_SERVICE php occ files:cleanup
docker-compose exec -u www-data $NEXTCLOUD_SERVICE php occ files:scan --all

#unset environment variables
unset $(grep -v '^#' quenchinnovations.env | sed -E 's/(.*)=.*/\1/' | xargs)
unset $(grep -v '^#' backup_nextcloud.env | sed -E 's/(.*)=.*/\1/' | xargs)


#reset password
#docker-compose exec -u www-data $NEXTCLOUD_SERVICE php occ user:resetpassword ptrujillo