dps(){ docker ps --format table {{.ID}}t{{.Names}}t{{.Size}}t{{.Image}} MYSQL_ROOT_PASSWORD=CapitanAmerica#2020 MYSQL_PASSWORD=admin MYSQL_DATABASE=mydeskweb MYSQL_USER=nextcloud NEXTCLOUD_ADMIN_USER=admin NEXTCLOUD_ADMIN_PASSWORD=CapitanAmerica#2020 NEXTCLOUD_UPDATE=0; }