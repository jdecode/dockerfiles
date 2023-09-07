FROM jdecode/devops:php-8.2-np

RUN apt-get update

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
xdebug.start_with_request = 1 \n\
xdebug.discover_client_host = on \n\
xdebug.client_host = host.docker.internal \n\
' > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

