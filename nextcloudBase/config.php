<?php
$CONFIG = array (
  'htaccess.RewriteBase' => '/',
  'memcache.local' => '\\OC\\Memcache\\APCu',
  'apps_paths' => 
  array (
    0 => 
    array (
      'path' => '/var/www/html/apps',
      'url' => '/apps',
      'writable' => false,
    ),
    1 => 
    array (
      'path' => '/var/www/html/custom_apps',
      'url' => '/custom_apps',
      'writable' => true,
    ),
  ),
  'instanceid' => 'ocf0lrgctt02',
  'passwordsalt' => 'xykqkfyLdUEXAeOHbr9csA6v0l2IZM',
  'secret' => 'WelYECleLUICITq6+8pWNxGqD8STXVLVSy+XoaTWUoQCmW01',
  'trusted_domains' => 
  array (
    0 => 'nextcloud.local',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'mysql',
  'version' => '22.0.0.11',
  'overwrite.cli.url' => 'http://nextcloud.local',
  'dbname' => 'nextcloud',
  'dbhost' => 'nextcloud.db',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextclouduser',
  'dbpassword' => 'MariaMagdalena',
  'installed' => true,
  'logtimezone' => 'America/New_York',
  'loglevel' => 3,
  'session_lifetime' => '60 * 60 * 24',
  'remember_login_cookie_lifetime' => '60*60*24*15',
  'logfile' => '/var/www/html/data/nextcloud.log',
);
