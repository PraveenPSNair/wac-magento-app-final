# Use an official PHP image with FPM for Nginx
FROM php:8.2-fpm-alpine

# Install system dependencies first
RUN apk add --no-cache \
    nginx \
    supervisor \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    libxml2-dev \
    oniguruma-dev \
    icu-dev \
    libxslt-dev \
    curl \
    mysql-client

# Install PHP extensions one by one for better debugging
RUN docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install gd

RUN docker-php-ext-install bcmath
RUN docker-php-ext-install intl
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install soap
RUN docker-php-ext-install zip
RUN docker-php-ext-install opcache
RUN docker-php-ext-install xsl

# Alternatively, if the above still fails, try this approach:
# RUN apk add --no-cache --virtual .build-deps $PHPIZE_DEPS \
#     && docker-php-ext-configure gd --with-jpeg \
#     && docker-php-ext-install -j$(nproc) \
#         bcmath \
#         gd \
#         intl \
#         mbstring \
#         pdo_mysql \
#         soap \
#         zip \
#         opcache \
#         xsl \
#     && apk del .build-deps

# Configure PHP-FPM to listen on port 9000
RUN echo "listen = 0.0.0.0:9000" >> /usr/local/etc/php-fpm.d/zz-docker.conf

# Copy configurations
#COPY docker/nginx/magento.conf /etc/nginx/conf.d/default.conf
COPY docker/nginx/nginx.conf /etc/nginx/nginx.conf
COPY docker/nginx/magento.conf /etc/nginx/conf.d/magento.conf
RUN rm -f /etc/nginx/conf.d/default.conf

COPY docker/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Set working directory
WORKDIR /var/www/html

# Copy your entire Magento project
COPY --chown=www-data:www-data sample-project/ .

# Set proper permissions
RUN chmod -R 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Create var directory and set proper permissions
RUN mkdir -p /var/www/html/var /var/www/html/pub/static /var/www/html/pub/media /var/www/html/generated && \
    chown -R www-data:www-data /var/www/html/var && \
    chown -R www-data:www-data /var/www/html/pub/static && \
    chown -R www-data:www-data /var/www/html/pub/media && \
    chown -R www-data:www-data /var/www/html/generated && \
    chmod -R 755 /var/www/html/var && \
    chmod -R 755 /var/www/html/pub/static && \
    chmod -R 755 /var/www/html/pub/media && \
    chmod -R 755 /var/www/html/generated


# Expose port 9000
EXPOSE 9000

# Start Supervisor to manage both processes
#CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf", "-n"]
# Copy startup script

COPY docker/start.sh /usr/local/bin/start.sh
RUN chmod +x /usr/local/bin/start.sh

# Use the simple startup script instead of Supervisor
CMD ["/usr/local/bin/start.sh"]
