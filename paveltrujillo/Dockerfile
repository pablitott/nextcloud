# FROM php:7.4-cli
FROM php:7-fpm
#WORKDIR /usr/src/myapp
# COPY . /usr/src/myapp/
# Install composer in /usr/lib folder

WORKDIR /usr/lib
RUN apt-get update && apt-get install -y 
RUN apt-get -y install  apt-utils zip unzip wget
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php \
    && php -r "unlink('composer-setup.php');"

# Install PHPMailer
WORKDIR /usr/src/myapp
RUN wget https://github.com/PHPMailer/PHPMailer/archive/master.zip
RUN unzip master.zip
RUN mv PHPMailer-master PHPMailer
RUN rm master.zip

RUN php /usr/lib/composer.phar require phpmailer/phpmailer
RUN ls -r ./
RUN PATH="$PATH:/usr/src/myapp"
# ENTRYPOINT  [ "php" ]
# CMD [ "php" ]
