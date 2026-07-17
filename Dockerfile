FROM php:8.4-apache

# Տեղադրում ենք բազային ընդլայնումները
RUN apt-get update && apt-get install -y \
    libpq-dev \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install pdo pdo_pgsql pgsql intl

# Apache-ի Document Root-ը ուղղում ենք Symfony-ի public/ թղթապանակ
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Պատճենում ենք ամբողջ նախագիծը (ներառյալ vendor-ը)
COPY . /var/www/html/

RUN chown -R www-data:www-data /var/www/html