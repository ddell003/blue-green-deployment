
RUN composer global require hirak/prestissimo

WORKDIR /build

COPY composer.json ./
COPY composer.lock ./

RUN composer install \
    --no-scripts \
    --no-autoloader \
    --no-interaction \
    --ignore-platform-reqs

COPY . ./

RUN composer dump-autoload --optimize

FROM php:7.2-fpm-alpine3.11

# Install php extensions
RUN apk add --no-cache libzip-dev
RUN apk add --no-cache libpng libpng-dev

RUN docker-php-ext-configure zip --with-libzip
RUN docker-php-ext-configure gd

RUN docker-php-ext-install opcache pdo_mysql bcmath ctype fileinfo zip gd

COPY build/php/php-fpm.ini /usr/local/etc/php/php.ini
COPY build/php/php-fpm.conf /usr/local/etc/php-fpm.conf

# Install and configure supervisor
RUN apk add --no-cache supervisor

COPY build/php/sql-proxy-entrypoint.sh /sql-proxy-entrypoint.sh
COPY build/php/php-fpm-supervisor.sh /php-fpm-supervisor.sh

RUN chmod +x /sql-proxy-entrypoint.sh /php-fpm-supervisor.sh

WORKDIR /app

COPY --from=composer --chown=www-data:www-data /build /app

RUN wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
RUN chmod +x cloud_sql_proxy && mv cloud_sql_proxy /usr/local/bin/

EXPOSE 9000

ENTRYPOINT ["/sql-proxy-entrypoint.sh"]
CMD ["/php-fpm-supervisor.sh"]
