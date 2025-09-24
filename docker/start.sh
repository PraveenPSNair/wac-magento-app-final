#!/bin/bash

# Create health check file
echo '<?php header("Content-Type: application/json"); echo json_encode(["status" => "ok"]); ?>' > /var/www/html/magento/pub/health-check.php

# Set permissions
chown -R www-data:www-data /var/www/html/magento
chmod -R 755 /var/www/html/magento/var /var/www/html/magento/pub/static /var/www/html/magento/pub/media

# Start Nginx
nginx

# Start PHP-FPM in foreground
php-fpm -F -R
