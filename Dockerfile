FROM php:8.2-apache

ARG NODE_VERSION=18


WORKDIR /var/www/html

RUN apt-get update

RUN apt-get install -y ca-certificates gnupg
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_VERSION.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list

RUN apt-get update

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

#Install zip+icu dev libs, wget, git
RUN apt-get install \
    exif zip unzip wget git \
    libzip-dev libicu-dev libpng-dev libjpeg-dev libfreetype6-dev zlib1g-dev  -y

#RUN apk add libjpeg-dev libpng-dev \
RUN docker-php-ext-configure gd --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd

#Install intl (intl requires to be configured)
RUN docker-php-ext-configure intl && docker-php-ext-install intl
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg
RUN docker-php-ext-install -j$(nproc) gd

#PostgreSQL
RUN apt-get install libpq-dev -y
RUN docker-php-ext-configure pgsql -with-pgsql=/usr/local/pgsql && docker-php-ext-install pdo_pgsql pgsql


RUN sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set Apache webroot to "public" folder
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!/var/www/html/public!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf



## -------------------------------
##      Setup Apache2 mod_ssl
## -------------------------------

# Prepare fake SSL certificate
RUN apt-get install -y ssl-cert
RUN openssl req -new -newkey rsa:4096 -days 3650 -nodes -x509 -subj  "/C=UK/ST=EN/L=LN/O=FL/CN=127.0.0.1" -keyout ./docker-ssl.key -out ./docker-ssl.pem -outform PEM
RUN mv docker-ssl.pem /etc/ssl/certs/ssl-cert-snakeoil.pem
RUN mv docker-ssl.key /etc/ssl/private/ssl-cert-snakeoil.key

# Enable the mod and default ssl site
RUN a2enmod ssl
RUN a2ensite default-ssl.conf

## -------------------------------
##      Apache2 mod_ssl setup
## -------------------------------


## ---------------------------------------
##      Install Node
## ---------------------------------------

RUN apt-get install nodejs -y
RUN npm install -g npm

## ---------------------------------------
##      Node installed
## ---------------------------------------


## ---------------------------------------
##      Install Postman CLI
## ---------------------------------------

RUN curl -o- "https://dl-cli.pstmn.io/install/linux64.sh" | sh
##      Postman CLI installed
## ---------------------------------------

## ---------------------------------------
##      Install vim
## ---------------------------------------

RUN apt-get install vim -y

## ---------------------------------------
##      vim installed
## ---------------------------------------


## ---------------------------------------
##      Install xdebug 3.x
## ---------------------------------------

#RUN pecl install xdebug
#RUN docker-php-ext-enable xdebug

## ---------------------------------------
##      xdebug 3.x installed
## ---------------------------------------

# If this cofiguration is not the one you want, you can override this in Dockerfile of your project
# If overriding does not work, then use this file as source to generate a new docker image without following lines
#RUN echo '\
#zend_extension=xdebug \n\
#xdebug.mode = debug,coverage \n\
#xdebug.discover_client_host = on \n\
#xdebug.client_host = host.docker.internal \n\
#' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini


RUN usermod -u 1001 www-data && groupmod -g 1001 www-data

RUN echo "Mutex posixsem" >> /etc/apache2/apache2.conf

RUN echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/docker-php-upload.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/docker-php-upload.ini

