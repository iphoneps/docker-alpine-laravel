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

#npm run dev

if [ "$QUEUE_WORKER" = "enable" ]; then
    echo 'Queue worker will start'
    cp -r /etc/supervisor/conf.d/supervisord-queue-worker.conf /etc/supervisor/conf.d/supervisord.conf
fi


if [ "$XDEBUG" = "enable" ]; then

    #enable XDEBUG
    echo 'Installing xdebug'
    apk --no-cache add php7-xdebug
    mv /etc/php7/conf.d/xdebug.inioff /etc/php7/conf.d/xdebug.ini

    #to debug xdebug issues
    touch /var/log/xdebug.log
    chmod 777 /var/log/xdebug.log

    #PHPStorm file mappings
    export PHP_IDE_CONFIG="serverName=_"

    #install openssh
    echo 'Installing openssh'
    apk add --no-cache openssh
    sed -i s/#PermitRootLogin.*/PermitRootLogin\ yes/ /etc/ssh/sshd_config
    echo "root:root" | chpasswd
    ssh-keygen -A

    echo 'Run "ssh -R  127.0.0.1:9001:127.0.0.1:9000 -vvv -p 2222 root@localhost" to create reverse ssh tunnel'

    #supervisor with sshd
    cp -r /etc/supervisor/conf.d/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord.conf
fi

exec /usr/bin/supervisord --nodaemon -c /etc/supervisor/conf.d/supervisord.conf