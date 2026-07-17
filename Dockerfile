FROM php:8.2-apache

# Փոխում ենք Apache-ի գլխավոր թղթապանակը դեպի Symfony-ի public/
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf

# Միացնում ենք mod_rewrite-ը, որպեսզի Symfony-ի էջերը ճիշտ բացվեն
RUN a2enmod rewrite

COPY . /var/www/html/
RUN chown -R www-data:www-data /var/www/html