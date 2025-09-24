# Use an official PHP image with FPM for Nginx
FROM php:8.2-fpm-alpine

# Install system dependencies first
RUN apk update && apk add --no-cache \
    nginx \
    supervisor \
    curl \
    mysql-client \
    git \
    bash

# Install PHP extensions with ALL required dependencies
RUN apk add --no-cache \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libxml2-dev \
    icu-dev \
    oniguruma-dev \
    freetype-dev \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install \
        pdo_mysql \
        zip \
        gd \
        intl \
        mbstring \
        soap \
        opcache

# Install Redis extension properly (with build tools)
RUN apk add --no-cache --virtual .build-deps \
    autoconf \
    gcc \
    g++ \
    make \
    && pecl install redis \
    && docker-php-ext-enable redis \
    && apk del .build-deps

# Configure PHP-FPM to listen on port 9000
RUN echo "listen = 0.0.0.0:9000" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Copy configurations
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/magento-v2.conf /etc/nginx/conf.d/magento-v2.conf
RUN rm -f /etc/nginx/conf.d/default.conf

#COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www/html/magento

# Copy your entire Magento project
COPY --chown=www-data:www-data sample-project/ .

# Set proper permissions
RUN chmod -R 755 /var/www/html/magento && \
    chown -R www-data:www-data /var/www/html/magento

# Create var directory and set proper permissions
RUN mkdir -p /var/www/html/magento/var /var/www/html/magento/pub/static /var/www/html/magento/pub/media /var/www/html/magento/generated && \
    chown -R www-data:www-data /var/www/html/magento/var && \
    chown -R www-data:www-data /var/www/html/magento/pub/static && \
    chown -R www-data:www-data /var/www/html/magento/pub/media && \
    chown -R www-data:www-data /var/www/html/magento/generated && \
    chmod -R 755 /var/www/html/magento/var && \
    chmod -R 755 /var/www/html/magento/pub/static && \
    chmod -R 755 /var/www/html/magento/pub/media && \
    chmod -R 755 /var/www/html/magento/generated

# Expose ports
EXPOSE 8080

# Copy startup script
COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

CMD ["/usr/local/bin/start.sh"]
