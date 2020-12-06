FROM php:7.4-fpm
RUN apt-get update && apt-get install -y \
        libfreetype6-dev libjpeg62-turbo-dev libpng-dev zip unzip libzip-dev libicu-dev nano vim sudo cron \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd pdo pdo_mysql zip intl
RUN usermod -aG sudo www-data
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
COPY --from=composer /usr/bin/composer /usr/bin/composer
RUN composer global require laravel/installer
RUN ln -s /root/.composer/vendor/bin/laravel /usr/bin/laravel
RUN mkdir -p /var/www/.composer && chown -R www-data:www-data /var/www/
RUN echo "#!/bin/bash" > /entrypoint.sh
RUN echo "sudo cron -f &" >> /entrypoint.sh
RUN echo "docker-php-entrypoint php-fpm" >> /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT /entrypoint.sh
