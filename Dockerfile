FROM jdecode/devops:php83-node20



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

RUN docker-php-ext-install opcache

RUN echo "allow_url_fopen=0 \n\
expose_php=0 \n\
display_startup_errors=0 \n\
log_errors=1 \n\
" > /usr/local/etc/php/conf.d/docker-php-expose.ini






