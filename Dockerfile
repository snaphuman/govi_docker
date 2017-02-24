FROM nginx:1.11-alpine
MAINTAINER <snaphuman> fhernandezn@gmail.com

# Instala dependencias del ambiente de ejecución

RUN apk update

RUN apk add --no-cache --virtual .build-deps \
    gcc \
    libc-dev \
    make \
    openssl-dev \
    pcre-dev \
    zlib-dev \
    linux-headers \
    curl \
    gnupg \
    libxslt-dev \
    gd-dev \
    geoip-dev \
    perl-dev \
    bash \
    supervisor

RUN apk add php5-fpm \
    php5-mcrypt \
    php5-soap \
    php5-openssl \
    php5-gmp \
    php5-json \
    php5-dom \
    php5-zip \
    php5-mysql \
    php5-mysqli \
    php5-bcmath \
    php5-gd \
    php5-xcache \
    php5-gettext \
    php5-xmlreader \
    php5-xmlrpc \
    php5-bz2 \
    php5-memcache \
    php5-iconv \
    php5-curl \
    php5-ctype

# Configuración base

RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

RUN addgroup govi && \
    adduser govi -h /home/govi -s /bin/bash -D govi -G nginx -G govi

# Configuración Nginx

RUN mkdir -p /etc/nginx/sites-available
RUN mkdir -p /etc/nginx/sites-enabled
RUN mkdir -p /var/log/nginx/govi.box
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/govi.box.conf /etc/nginx/sites-available/govi.box.conf
RUN ln -s /etc/nginx/sites-available/govi.box.conf /etc/nginx/sites-enabled/govi.box.conf

RUN echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/www/info.php

# Configuración PHP-FPM

ENV PHP_FPM_USER="nginx" \
    PHP_FPM_GROUP="nginx" \
    PHP_FPM_LISTEN_MODE="0660" \
    PHP_FPM_LISTEN="/run/php-fpm/php-fpm.sock" \
    PHP_MEMORY_LIMIT="512M" \
    PHP_MAX_UPLOAD="50M" \
    PHP_MAX_FILE_UPLOAD="50" \
    PHP_MAX_POST="300M" \
    PHP_DISPLAY_ERRORS="On" \
    PHP_DISPLAY_STARTUP_ERRORS="On" \
    PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR" \
    PHP_CGI_FIX_PATHINFO="0"

RUN mkdir /run/php-fpm

RUN sed -i "s|include\s*=\s*\/etc\/php5\/fpm\.d\/\*\.conf|;include = /etc/php5/fpm.d/*.conf|g" /etc/php5/php-fpm.conf && \
    sed -i "s|listen\s*=\s*127\.0\.0\.1:9000|listen = ${PHP_FPM_LISTEN}|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;listen.owner\s*=\s*nobody|listen.owner = ${PHP_FPM_USER}|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;listen.group\s*=\s*nobody|listen.group = ${PHP_FPM_GROUP}|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g" /etc/php5/php-fpm.conf && \
    sed -i "s|user\s*=\s*nobody|user = ${PHP_FPM_USER}|g" /etc/php5/php-fpm.conf && \
    sed -i "s|group\s*=\s*nobody|group = ${PHP_FPM_GROUP}|g" /etc/php5/php-fpm.conf && \
    sed -i "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php5/php-fpm.conf

RUN sed -i "s|display_errors\s*=\s*Off|display_errors = ${PHP_DISPLAY_ERRORS}|i" /etc/php5/php.ini && \
    sed -i "s|display_startup_errors\s*=\s*Off|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" /etc/php5/php.ini && \
    sed -i "s|error_reporting\s*=\s*E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = ${PHP_ERROR_REPORTING}|i" /etc/php5/php.ini && \
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php5/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" /etc/php5/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php5/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php5/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo= ${PHP_CGI_FIX_PATHINFO}|i" /etc/php5/php.ini

# Instalación de Composer

# Instalación y Configuración de  Drush con Composer

# Asignar el volumen del DocumentRoot del proyecto

# Configuracón supervisor de procesos

RUN mkdir /var/log/supervisor
COPY conf/supervisord.conf /etc/supervisord.conf

# Ejecución del script de inicio

ADD scripts/start.sh /start.sh
RUN chmod 700 /start.sh
CMD ["/start.sh"]
