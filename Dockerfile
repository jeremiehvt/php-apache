FROM php:7.3.6-apache

ARG ADMIN_USER

LABEL maintainer="jeremie_havart <jeremiehvt@gmail.com>" \
      description="image base on debian php 7.3.6 image with apache"

# copy work project files in container
COPY --chown=1000:33 ./app/ /var/www/html/

# copy apache configuration vhost file
COPY ./apache_conf/localhost.conf /etc/apache2/sites-available/

#load php.ini file
COPY ./php-ini/php.ini /usr/local/etc/php

# enable site configuration
RUN a2ensite localhost.conf 

# install some utilities and php add-ons
RUN apt-get update
RUN apt-get install -y nano \
	               vim \
		       sudo \
		       git \
		       libzip-dev \
		       unzip \
		       libmagickwand-dev --no-install-recommends \
    		       zlib1g-dev \
    		       libzip-dev   

RUN pecl install imagick && docker-php-ext-enable imagick

RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_enable=on" >> /usr/local/etc/php/conf.d/xdebug.ini \
    && echo "xdebug.remote_autostart=off" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN useradd -g www-data -G sudo,root ${ADMIN_USER}

RUN a2enmod rewrite

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

EXPOSE 80
