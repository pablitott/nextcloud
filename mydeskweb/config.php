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
  'instanceid' => 'ocrywqatj2xl',
  'passwordsalt' => 'H8TasS5/SejHH3zY17JVbPH6mCmYJd',
  'secret' => 'Cn0Dfur7bORIMIOd7JcoRc6hW+KA2xhZz6PpdxqpeUNGYgf8',
  'trusted_domains' => 
  array (
    0 => 'mydeskweb.com',
    1 => 'www.mydeskweb.com',
  ),
  'trusted_proxies' => ['127.0.0.1'],
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'mysql',
  'version' => '29.0.3.4',
  'overwrite.cli.url' => 'http://www.mydeskweb.com',
  'overwriteprotocol' => 'https',
  'dbname' => 'mydeskweb',
  'dbhost' => 'mydeskweb.db',
  'dbport' => '',
  'dbtableprefix' => 'oc_',
  'mysql.utf8mb4' => true,
  'dbuser' => 'nextclouduser',
  'dbpassword' => 'MariaMagdalena',
  'installed' => true,
  'mail_from_address' => 'admin',
  'mail_smtphost' => 'smtp.mail.us-west-2.awsapps.com',
  'mail_domain' => 'mydeskweb.awsapps.com',
  'mail_smtpmode' => 'smtp',
  'mail_sendmailmode' => 'smtp',
  'mail_smtpport' => '465',
  'maintenance' => false,
  'theme' => '',
  'loglevel' => 2,
  'default_phone_region' => 'US',
  'app_install_overwrite' => 
  array (
    0 => 'files_external_gdrive',
  ),
  'mail_smtpauth' => 1,
  'mail_smtpauthtype' => 'LOGIN',
  'mail_smtpname' => 'admin@mydeskweb.awsapps.com',
  'mail_smtppassword' => 'Franchesca#2020',
  'updater.release.channel' => 'stable',
  'maintenance_window_start' => 1,
  'memcache.locking' => '\\OC\\Memcache\\Redis',
  'encryption.legacy_format_support' => false,
  'redis' => 
  array (
    'host' => 'mydeskweb.redis',
    'port' => 6379,
    'timeout' => 0.0,
    'password' => 'nextcloud_redis_pass',
  ),
  'mail_smtpsecure' => 'ssl',
);
