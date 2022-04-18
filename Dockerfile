FROM ubuntu:20.04
LABEL Maintainer="Admin <admin@iphonephotographyschool.com>"

# Make sure random packages don't stop the installation by asking for user's input.
ARG DEBIAN_FRONTEND=noninteractive

# Merged a lot of commands under the same docker layer to optimise size
# Update default ubuntu packages
RUN apt-get -y update && \
# Install all necessary server packages
apt-get install --no-install-recommends --no-install-suggests -y  \
	software-properties-common nginx supervisor curl openssh-client bash unzip netcat mysql-client gpg-agent && \
# Install Node and NPM (Repo for the node LTS version is not available in ubuntu 20 by default for some reason)
curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
apt-get install --no-install-recommends --no-install-suggests -yq nodejs build-essential && \
# Install PHP. Has been properly maintained by this guy and with 7.4 its pretty much the only working option.
add-apt-repository ppa:ondrej/php && \
apt-get --assume-yes -y update && \
apt-get install --no-install-recommends --no-install-suggests --assume-yes -y  \
	php8.1 php8.1-fpm \
	php8.1-bcmath php8.1-mbstring php8.1-mysql php8.1-zip php8.1-curl php8.1-xml php8.1-imagick php8.1-gd php8.1-intl && \
# Install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
# clean ubuntu apk cache
apt-get autoclean && \
# Create run folder for PHP process
mkdir -p /run/php/

RUN apt-get -y install git

# Configure PHP
COPY ./docker-config/php-fpm.conf /etc/php/8.1/fpm/php-fpm.conf
COPY ./docker-config/www.conf /etc/php/8.1/fpm/pool.d/www.conf

COPY ./docker-config/php.ini /etc/php/8.1/fpm/conf.d/zzz_custom.ini
COPY ./docker-config/xdebug.ini /etc/php/8.1/fpm/conf.d/xdebug.inioff

# Configure Nginx
COPY ./docker-config/nginx.conf /etc/nginx/nginx.conf

# Setup application folder
RUN mkdir -p /var/www/
WORKDIR /var/www/

# Copy config files
COPY ./docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker-config/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf