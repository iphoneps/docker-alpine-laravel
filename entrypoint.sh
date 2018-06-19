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

npm install
npm run dev

if [ "QUEUE_WORKER" = "enable" ]; then
    cp -r /etc/supervisor/conf.d/supervisord-queue-worker.conf /etc/supervisor/conf.d/supervisord.conf
fi

exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/conf.d/supervisord.conf