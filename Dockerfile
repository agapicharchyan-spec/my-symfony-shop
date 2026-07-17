FROM php:8.2-apache

# Տեղադրում ենք անհրաժեշտ գործիքներ և zip ընդլայնումը Composer-ի համար
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    libzip-dev \
    && docker-php-ext-install zip

# Ներբեռնում ենք Composer-ը պաշտոնական image-ից
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Փոխում ենք Apache-ի Document Root-ը
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf
RUN a2enmod rewrite

# Պատճենում ենք նախագծի ֆայլերը
COPY . /var/www/html/

# Աշխատեցնում ենք composer install՝ գրադարանները տեղադրելու համար
ENV COMPOSER_ALLOW_SUPERUSER=1
RUN composer install --no-dev --optimize-autoloader

# Տալիս ենք թույլտվությունները
RUN chown -R www-data:www-data /var/www/html