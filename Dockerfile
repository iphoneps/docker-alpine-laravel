FROM ubuntu:22.04
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
curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
apt-get install -yq nodejs  --no-install-recommends --no-install-suggests && \
# Install PHP. Has been properly maintained by this guy and with 7.4 its pretty much the only working option.
add-apt-repository ppa:ondrej/php && \
apt-get --assume-yes -y update && \
apt-get install --no-install-recommends --no-install-suggests --assume-yes -y  \
	php8.2 php8.2-fpm \
	php8.2-bcmath php8.2-mbstring php8.2-mysql php8.2-zip php8.2-curl php8.2-xml php8.2-gd php8.2-intl php8.2-dev php8.2-imagick && \
# Install composer
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
# Install git
apt-get -y install --no-install-recommends git && \
# clean ubuntu apk cache
apt-get autoclean && \
apt-get autoremove -y && \
rm -rf /var/lib/apt/lists/* && \
rm -rf archive.tar.gz && \
# Create run folder for PHP process
mkdir -p /run/php/

# Install specific NPM version
RUN npm i -g npm@9.2

# Configure PHP
COPY ./docker-config/php-fpm.conf /etc/php/8.2/fpm/php-fpm.conf
COPY ./docker-config/www.conf /etc/php/8.2/fpm/pool.d/www.conf

COPY ./docker-config/php.ini /etc/php/8.2/fpm/conf.d/zzz_custom.ini
COPY ./docker-config/xdebug.ini /etc/php/8.2/fpm/conf.d/xdebug.inioff

# Configure Nginx
COPY ./docker-config/nginx.conf /etc/nginx/nginx.conf

# Setup application folder
RUN mkdir -p /var/www/

WORKDIR /var/www/

# Copy config files
COPY ./docker-config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./docker-config/supervisord-ssh.conf /etc/supervisor/conf.d/supervisord-ssh.conf