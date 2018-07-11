FROM nginx:1.13.8-alpine
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

RUN apk add php7 php7-common php7-fpm \
    php7-mcrypt \
    php7-soap \
    php7-openssl \
    php7-gmp \
    php7-json \
    php7-pdo \
    php7-pdo_mysql \
    php7-pdo_dblib \
    php7-dom \
    php7-zip \
    php7-mysqli \
    php7-bcmath \
    php7-gd \
    php7-gettext \
    php7-xmlreader \
    php7-xmlrpc \
    php7-bz2 \
    php7-iconv \
    php7-curl \
    php7-ctype \
    php7-zlib \
    php7-opcache \
    php7-phar
    
RUN ln -s /usr/bin/php7 /usr/bin/php

# Cliente Maria DB necesario para ejecutar drush

RUN apk add mariadb-client \
    mariadb-client-libs \
    mariadb-common

# Configuración base

RUN curl -sLo /usr/local/bin/ep https://github.com/kreuzwerker/envplate/releases/download/v0.0.8/ep-linux && chmod +x /usr/local/bin/ep

RUN adduser govi -D govi -u 1000  -G users

# Configuración Nginx

RUN mkdir -p /etc/nginx/sites-available
RUN mkdir -p /etc/nginx/sites-enabled
RUN mkdir -p /var/log/nginx/govi.box
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/govi.box.conf /etc/nginx/sites-available/govi.box.conf
COPY conf/supervisor.govi.box.conf /etc/nginx/sites-available/supervisor.govi.box.conf
RUN ln -s /etc/nginx/sites-available/govi.box.conf /etc/nginx/sites-enabled/govi.box.conf
RUN ln -s /etc/nginx/sites-available/supervisor.govi.box.conf /etc/nginx/sites-enabled/supervisor.govi.box.conf

# Verifica la configuración de php

RUN mkdir -p /usr/share/nginx/html/www/drupal && \
    echo "<?php phpinfo(); ?>" > /usr/share/nginx/html/www/info.php

RUN chown -R govi:users /usr/share/nginx/html/www/drupal

# Configuración PHP-FPM

ENV PHP_FPM_USER="govi" \
    PHP_FPM_GROUP="users" \
    PHP_FPM_LISTEN_MODE="0660" \
    PHP_FPM_LISTEN="/run/php-fpm/php-fpm.sock" \
    PHP_FPM_REQUEST_TERMINATE_TIMEOUT="3400" \
    PHP_MEMORY_LIMIT="4096M" \
    PHP_MAX_UPLOAD="50M" \
    PHP_MAX_FILE_UPLOAD="50" \
    PHP_MAX_POST="300M" \
    PHP_MAX_EXECUTION_TIME="0" \
    PHP_MAX_INPUT_TIME="1000" \
    PHP_DISPLAY_ERRORS="On" \
    PHP_DISPLAY_STARTUP_ERRORS="On" \
    PHP_ERROR_REPORTING="E_COMPILE_ERROR\|E_RECOVERABLE_ERROR\|E_ERROR\|E_CORE_ERROR" \
    PHP_CGI_FIX_PATHINFO="0"

RUN mkdir /run/php-fpm

RUN sed -i "s|include\s*=\s*\/etc\/php7\/fpm\.d\/\*\.conf|;include = /etc/php7/fpm.d/*.conf|g" /etc/php7/php-fpm.conf && \
    sed -i "s|listen\s*=\s*127\.0\.0\.1:9000|listen = ${PHP_FPM_LISTEN}|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;listen.owner\s*=\s*nobody|listen.owner = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;listen.group\s*=\s*nobody|listen.group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;listen.mode\s*=\s*0660|listen.mode = ${PHP_FPM_LISTEN_MODE}|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;request_terminate_timeout\s*=\s*0|request_terminate_timeout = ${PHP_FPM_REQUEST_TERMINATE_TIMEOUT}|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|user\s*=\s*nobody|user = ${PHP_FPM_USER}|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|group\s*=\s*nobody|group = ${PHP_FPM_GROUP}|g" /etc/php7/php-fpm.d/www.conf && \
    sed -i "s|;log_level\s*=\s*notice|log_level = notice|g" /etc/php7/php-fpm.conf && \
    sed -i "s|;clear_env\s*=\s*no|clear_env = no|g" /etc/php7/php-fpm.d/www.conf

RUN sed -i "s|display_errors\s*=\s*Off|display_errors = ${PHP_DISPLAY_ERRORS}|i" /etc/php7/php.ini && \
    sed -i "s|display_startup_errors\s*=\s*Off|display_startup_errors = ${PHP_DISPLAY_STARTUP_ERRORS}|i" /etc/php7/php.ini && \
    sed -i "s|error_reporting\s*=\s*E_ALL & ~E_DEPRECATED & ~E_STRICT|error_reporting = ${PHP_ERROR_REPORTING}|i" /etc/php7/php.ini && \
    sed -i "s|;*memory_limit =.*|memory_limit = ${PHP_MEMORY_LIMIT}|i" /etc/php7/php.ini && \
    sed -i "s|;*upload_max_filesize =.*|upload_max_filesize = ${PHP_MAX_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*max_file_uploads =.*|max_file_uploads = ${PHP_MAX_FILE_UPLOAD}|i" /etc/php7/php.ini && \
    sed -i "s|;*post_max_size =.*|post_max_size = ${PHP_MAX_POST}|i" /etc/php7/php.ini && \
    sed -i "s|;*cgi.fix_pathinfo=.*|cgi.fix_pathinfo = ${PHP_CGI_FIX_PATHINFO}|i" /etc/php7/php.ini && \
    sed -i "s|max_execution_time =.*|max_execution_time = ${PHP_MAX_EXECUTION_TIME}|i" /etc/php7/php.ini && \
    sed -i "s|max_input_time =.*|max_input_time = ${PHP_MAX_INPUT_TIME}|i" /etc/php7/php.ini

# Instalación de Composer

ENV COMPOSER_SIG="544e09ee996cdf60ece3804abc52599c22b1f40f4323403c44d44fdfdd586475ca9813a858088ffbc1f233e9b180f061"

RUN cd /tmp && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php -r "if (hash_file('SHA384', 'composer-setup.php') === '${COMPOSER_SIG}') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer && \
    php -r "unlink('composer-setup.php');"

# Instalación y Configuración de  Drush con Composer

RUN COMPOSER_HOME=/opt/drush COMPOSER_BIN_DIR=/usr/local/bin COMPOSER_VENDOR_DIR=/opt/drush/8 composer require drush/drush:8

RUN cd /opt/drush/8/drush/drush/ && composer update

# Configuracón supervisor de procesos y scripts de inicio

COPY conf/supervisord.conf /etc/supervisord.conf
COPY scripts/start.sh /start.sh

# Ejecución del script de inicio

RUN chmod 700 /start.sh

EXPOSE 80 443 22

CMD ["/start.sh"]
