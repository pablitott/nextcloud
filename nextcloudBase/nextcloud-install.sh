#============================================================================
# TODO: 
#  - Transform this fiel to be used in automated installation for nextcloud 
#  = Create an md file for instructions
#============================================================================
docker exec -it -u www-data nextcloud.local php \
  occ maintenance:install \
  --database "mysql"  \
  --database-host "nextcloud.db"     \
  --database-name "nextcloud"        \
  --database-user "nextclouduser"    \
  --database-pass "MariaMagdalena"   \
  --admin-user "admin"               \
  --admin-pass "CapitanAmerica#2020" \
  --admin-email "pablitott@gmail.com"

# get existing configuration
docker exec -it -u www-data mydeskweb.local php \
  occ config:list > mydeskweb/local-settings.json --private

#get current trusted_domains
docker exec -it -u www-data nextcloud.local php \
  occ config:system:get trusted_domains

# set trusted_domains
docker exec -it -u www-data nextcloud.local php \
  occ config:system:set trusted_domains 0 --value="nextcloud.local"

# delete trusted_domains
docker exec -it -u www-data nextcloud.local php \
  occ config:system:delete trusted_domains 1

#set overwrite.cli.url
docker exec -it -u www-data nextcloud.local php \
  occ config:system:set overwrite.cli.url --value="http://nextcloud.local"

#set logtimezone 
docker exec -it -u www-data nextcloud.local php \
  occ config:system:set logtimezone --value="America/New_York"

https://docs.nextcloud.com/server/latest/admin_manual/configuration_server/occ_command.html

#'session_lifetime' => 60 * 60 * 24,
#'remember_login_cookie_lifetime' => 60*60*24*15,
"logfile" => "/var/log/nextcloud.log",