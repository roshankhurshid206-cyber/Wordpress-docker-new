# Base Image: Uses PHP 8.2 running on the Apache web server.
FROM php:8.2-apache

# 1. INSTALL SYSTEM DEPENDENCIES
# Updates package list and installs required utilities (wget, unzip) and libraries (for image handling).
RUN apt-get update && \
    apt-get install -y \
        wget \
        unzip \
        libzip-dev \
        libpng-dev \
        libjpeg-dev \
        --no-install-recommends && \
    rm -rf /var/lib/apt/lists/*

# 2. INSTALL PHP EXTENSIONS
# Installs MySQL drivers (mysqli, pdo_mysql) to connect to the database, and GD for image processing.
RUN docker-php-ext-configure gd --with-jpeg && \
    docker-php-ext-install -j$(nproc) mysqli pdo pdo_mysql opcache zip gd

# 3. DOWNLOAD AND CONFIGURE WORDPRESS CORE
# Downloads WordPress, extracts it, and moves all files to the Apache web root.
RUN wget https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz && \
    tar -xzf /tmp/wordpress.tar.gz -C /usr/src/ && \
    mv /usr/src/wordpress/* /var/www/html/ && \
    rm /tmp/wordpress.tar.gz && \
    rm -rf /usr/src/wordpress

# 4. SET PERMISSIONS
# Sets file ownership to the user Apache runs as (www-data) to allow WordPress to write files.
RUN chown -R www-data:www-data /var/www/html
RUN rm -f /var/www/html/index.html
EXPOSE 80
