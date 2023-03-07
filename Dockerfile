FROM php:8.2-apache

ARG NODE_VERSION=18
ARG POSTGRES_VERSION=14
ARG XDEBUG_START_WITH_REQUEST=1


WORKDIR /var/www/html

RUN apt-get update

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Install zip+icu dev libs, wget, git
RUN apt-get install libzip-dev zip libicu-dev libpng-dev wget git -y

#Install PHP extensions zip and intl (intl requires to be configured)
RUN docker-php-ext-install zip && docker-php-ext-configure intl && docker-php-ext-install intl exif gd

#PostgreSQL
RUN apt-get install libpq-dev -y
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && docker-php-ext-install pdo_pgsql pgsql


RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

RUN a2enmod rewrite

#RUN usermod -u 1001 www-data && groupmod -g 1001 www-data

# Set Apache webroot to "public" folder (for Laravel support)
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf



## -------------------------------
##          Install SSL
## -------------------------------

# Prepare fake SSL certificate
RUN apt-get install -y ssl-cert
RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj  "/C=UK/ST=EN/L=LN/O=FNL/CN=127.0.0.1" -keyout ./docker-ssl.key -out ./docker-ssl.pem -outform PEM
RUN mv docker-ssl.pem /etc/ssl/certs/ssl-cert-snakeoil.pem
RUN mv docker-ssl.key /etc/ssl/private/ssl-cert-snakeoil.key

# Setup Apache2 mod_ssl
RUN a2enmod ssl
# Setup Apache2 HTTPS env
RUN a2ensite default-ssl.conf

## -------------------------------
##          SSL Installed
## -------------------------------



## ---------------------------------------
##      Install Node 18.x
## ---------------------------------------

RUN curl -sLS https://deb.nodesource.com/setup_$NODE_VERSION.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g npm

## ---------------------------------------
##      Node 18.x installed
## ---------------------------------------




## ---------------------------------------
##      Install Postman CLI
## ---------------------------------------

RUN curl -o- "https://dl-cli.pstmn.io/install/linux64.sh" | sh
##      Postman CLI installed
## ---------------------------------------




## ---------------------------------------
##      Install xdebug 3.x
## ---------------------------------------

RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

## ---------------------------------------
##      xdebug 3.x installed
## ---------------------------------------

# If this cofiguration is not the one you want, you can override this in Dockerfile of your project
# If overriding does not work, then use this file as source to generate a new docker image with following lines as commented
RUN echo '\
zend_extension=xdebug \n\
xdebug.mode = debug,coverage \n\
xdebug.start_with_request = ${XDEBUG_START_WITH_REQUEST} \n\
xdebug.discover_client_host = on \n\
xdebug.client_host = host.docker.internal \n\
' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini



RUN usermod -u 1001 www-data && groupmod -g 1001 www-data


