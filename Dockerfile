FROM alpine:3.10
LABEL Maintainer="Janis Purins <janis@purins.lv>"

# Install packages
RUN apk --no-cache add php7 php7-fpm php7-zip php7-json php7-openssl php7-curl \
    php7-zlib php7-xml php7-phar php7-intl php7-dom php7-xmlreader php7-xmlwriter php7-ctype \
    php7-mbstring php7-gd php7-session php7-pdo php7-pdo_mysql php7-tokenizer php7-posix \
    php7-fileinfo php7-opcache php7-cli php7-mcrypt php7-pcntl php7-iconv php7-simplexml \
    php7-exif php7-pdo_sqlite nginx supervisor curl git openssh-client bash nodejs-npm shadow

# Configure nginx
COPY ./docker-config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY ./docker-config/fpm-pool.conf /etc/php7/php-fpm.d/zzz_custom.conf
COPY ./docker-config/php.ini /etc/php7/conf.d/zzz_custom.ini
COPY ./docker-config/xdebug.ini /etc/php7/conf.d/xdebug.inioff

# Configure supervisord
COPY ./docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker-config/supervisord-queue-worker.conf /etc/supervisor/conf.d/supervisord-queue-worker.conf
COPY ./docker-config/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf

# Configure composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# rebuild node-sass binding for current os environment
RUN npm rebuild node-sass

# Setup Application Folder
RUN mkdir -p /var/www/
WORKDIR /var/www/

# Fpm runs as nobody. To grant proper 775 permissions for laravel we add nobody to www-data group
RUN usermod -aG www-data nobody

# Setup entrypouint that will be run on deploy
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh