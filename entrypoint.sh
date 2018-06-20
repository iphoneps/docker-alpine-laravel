#!/bin/sh

echo 'Setting Permissons'

#chmod -R g+w storage &&\
#chmod -R 775 storage &&\
#chgrp -R www-data . &&\
#chmod -R 775 . &&\
#chown -R www-data:www-data /var/www

echo 'Starting Artisan Commands'
php artisan optimize
php artisan migrate --force

#npm install
#npm run dev

if [ "$QUEUE_WORKER" = "enable" ]; then
    echo 'Queue worker will start'
    cp -r /etc/supervisor/conf.d/supervisord-queue-worker.conf /etc/supervisor/conf.d/supervisord.conf
fi


if [ "$XDEBUG" = "enable" ]; then
    echo 'Enabling xdebug'
    apk --no-cache add php7-xdebug
    mv /etc/php7/conf.d/xdebug.inioff /etc/php7/conf.d/xdebug.ini

fi

exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/conf.d/supervisord.conf