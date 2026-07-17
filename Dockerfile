FROM php:8.3-apache

# Տեղադրում ենք համակարգային գրադարաններ և PHP ընդլայնումներ (PostgreSQL, Zip, Intl)
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    libpq-dev \
    libicu-dev \
    && docker-php-ext-configure intl \
    && docker-php-ext-install zip pdo pdo_pgsql pgsql intl

# Պատճենում ենք Composer-ը
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Կարգավորում ենք Apache-ն Symfony-ի public/ թղթապանակի համար
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Պատճենում ենք ամբողջ նախագիծը
COPY . /var/www/html/

# Թույլ ենք տալիս Composer-ին աշխատել root-ով և տեղադրում ենք գրադարանները
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --optimize-autoloader

# Տալիս ենք ֆայլերի թույլտվությունները Apache-ին
RUN chown -R www-data:www-data /var/www/html