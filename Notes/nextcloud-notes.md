# Nextcloud configuration

## Configuraging WebServer
### PHP configuration
    find the php configuration at /etc/php/7.4/apache2/php.ini and change following values
    - php_value upload_max_filesize 16G
    - php_value post_max_size 16G

    change following values if you see PHP timeouts in your logfiles
    - php_value max_input_time 3600
    - php_value max_execution_time 3600
    
