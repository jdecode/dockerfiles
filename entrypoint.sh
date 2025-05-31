#!/bin/bash

git config --global --add safe.directory /var/www/html

echo -e "zend_extension=xdebug\n\
xdebug.mode=debug,coverage\n\
xdebug.discover_client_host=on\n\
xdebug.client_host=host.docker.internal\n" > /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

## If vendor folder does not exist, run composer install
if [ ! -d "/var/www/html/vendor" ]; then
    composer install --optimize-autoloader
fi

## If node_modules folder does not exist, run npm install
if [ ! -d "/var/www/html/node_modules" ]; then
    npm install
fi

## If .env file does not exist, copy .env.example to .env
if [ ! -f "/var/www/html/.env" ]; then
    composer run post-root-package-install
    composer run post-create-project-cmd
fi

npm run build

cat <<EOF > /etc/supervisor/conf.d/supervisord.conf
[program:queues]
process_name=%(program_name)s_%(process_num)02d
command=php /var/www/html/artisan horizon
autostart=true
autorestart=true
stopasgroup=true
killasgroup=true
user=www-data
numprocs=2
redirect_stderr=true
stdout_logfile=/var/www/html/storage/queues.log
stopwaitsecs=3600
EOF

# Add scheduler runner to crontab
echo "* * * * * root cd /var/www/html && php artisan schedule:run >> /dev/null 2>&1" >> /etc/crontab

# Start services
service cron start
supervisord -c /etc/supervisor/supervisord.conf
supervisorctl reread
supervisorctl update
supervisorctl start queues

npm run dev --host &

apache2-foreground

