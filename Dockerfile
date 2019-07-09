FROM php:7.3.6-apache

LABEL maintainer="jeremie_havart <jeremiehvt@gmail.com>" \
      description="image base on debian php 7.3.6 image with apache"


ENV ADMIN_USER="havartjeremie"

# copy work project files in container
COPY --chown=1000:33 ./ /var/www/html/

# copy apache configuration vhost file
COPY ./apache_conf/localhost.conf /etc/apache2/sites-available/

# enable site configuration
RUN a2ensite localhost.conf 

# install some utilities
RUN apt-get update
RUN apt-get install -y nano \
	               vim \
		       sudo \
		       git 

RUN useradd -g www-data -G sudo,root $ADMIN_USER

RUN a2enmod rewrite

# change right var folder 
RUN chmod -R 777 /var/www/html/var

# Composer install
RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
    && php composer-setup.php --install-dir=/usr/local/bin --filename=composer \
    && php -r "unlink('composer-setup.php');"

EXPOSE 80
