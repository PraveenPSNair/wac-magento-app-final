#!/bin/sh

# Start PHP-FPM in background
/usr/local/sbin/php-fpm --daemonize

# Start Nginx in foreground
exec /usr/sbin/nginx -g 'daemon off;'
