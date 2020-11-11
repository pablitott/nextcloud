# export MYSQL_ROOT=root
# export MYSQL_ROOT_PASSWORD=CapitanAmerica
# export MYSQL_USER=nextclouduser
# export MYSQL_PASSWORD="MariaMagdalena"
# export DATABASE_SERVICE=mydeskweb.db
# export MYSQL_DATABASE=mydeskweb

# export NEXTCLOUD_ADMIN_USER=admin
# export NEXTCLOUD_ADMIN_PASSWORD="tutp610125"
# export NEXTCLOUD_TRUSTED_DOMAINS=mydeskweb.local
set -a; source mydeskweb/environment.env ; set +a

restore_db_file=ncdb_2.sql

#mariadb-mydeskweb.com
  echo "Remove DB"
  docker exec -it $DATABASE_SERVICE mysql -u$MYSQL_ROOT -p"$MYSQL_ROOT_PASSWORD" -e "DROP DATABASE IF EXISTS $MYSQL_DATABASE"
  echo "Create  DB"
  docker exec -it $DATABASE_SERVICE mysql -u$MYSQL_ROOT -p"$MYSQL_ROOT_PASSWORD" -e "CREATE DATABASE $MYSQL_DATABASE CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci"
  echo "DROP USER"
  docker exec -it $DATABASE_SERVICE mysql -u$MYSQL_ROOT -p"$MYSQL_ROOT_PASSWORD" -e "DROP USER IF EXISTS "$MYSQL_USER""
  echo  "Create USER"
  docker exec -it $DATABASE_SERVICE mysql -u$MYSQL_ROOT -p"$MYSQL_ROOT_PASSWORD" -e "CREATE USER "$MYSQL_USER" IDENTIFIED BY '$MYSQL_PASSWORD'"
  echo "GRANT PRIVILEGES"
  docker exec -it $DATABASE_SERVICE mysql -u$MYSQL_ROOT -p"$MYSQL_ROOT_PASSWORD" -e "GRANT ALL PRIVILEGES ON $MYSQL_DATABASE.* TO $MYSQL_USER"
  echo "import DB DATA"
  docker exec -i $DATABASE_SERVICE mysql -u $MYSQL_USER -p"$MYSQL_PASSWORD" $MYSQL_DATABASE < $restore_db_file
