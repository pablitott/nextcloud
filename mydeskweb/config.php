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
  'trusted_proxies' => 
  array (
    0 => '127.0.0.1',
  ),
  'datadirectory' => '/var/www/html/data',
  'dbtype' => 'mysql',
  'version' => '29.0.4.1',
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
  'mail_smtpmode' => 'smtp',
  'mail_sendmailmode' => 'smtp',
  'maintenance' => false,
  'theme' => '',
  'loglevel' => 2,
  'default_phone_region' => 'US',
  'app_install_overwrite' => 
  array (
    0 => 'files_external_gdrive',
  ),
  'mail_smtpauthtype' => 'LOGIN',
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
  'mail_smtpauth' => 1,
  'mail_smtpsecure' => 'ssl',
  'mail_from_address' => 'automation',
  'mail_domain' => 'mydeskweb.awsapps.com',
  'mail_smtphost' => 'smtp.mail.us-east-1.awsapps.com',
  'mail_smtpport' => '465',
  'mail_smtpname' => 'automation@mydeskweb.awsapps.com',
  'mail_smtppassword' => 'CapitanAmerica#2020',
  'opcache.validate_timestamps' => 0,
  'opcache.save_comments' => 1,
  'allow_local_remote_servers' => true,
  'enable_previews' => true,
  'enabledPreviewProviders' =>
  array (
    'OC\Preview\PNG',
    'OC\Preview\JPEG',
    'OC\Preview\GIF',
    'OC\Preview\BMP',
    'OC\Preview\XBitmap',
    'OC\Preview\MP3',
    'OC\Preview\TXT',
    'OC\Preview\MarkDown',
    'OC\Preview\OpenDocument',
    'OC\Preview\Krita',
    'OC\Preview\HEIC',
  ),  
);
