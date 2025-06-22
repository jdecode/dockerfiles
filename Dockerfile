FROM jdecode/devops:php84-node22


RUN docker-php-ext-install pcntl

RUN apt update && apt install systemd -y

RUN apt-get install -y ca-certificates gnupg cron supervisor rsync

RUN journalctl -u supervisor

RUN pecl install xdebug
RUN docker-php-ext-enable xdebug

