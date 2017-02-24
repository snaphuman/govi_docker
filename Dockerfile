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
    perl-dev

RUN apk add bash

RUN apk add openrc

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

# Configuración Nginx

RUN mkdir -p /etc/nginx/sites-available
RUN mkdir -p /etc/nginx/sites-enabled
RUN mkdir -p /var/log/nginx/govi.box
COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY conf/govi.box.conf /etc/nginx/sites-available/govi.box.conf
RUN ln -s /etc/nginx/sites-available/govi.box.conf /etc/nginx/sites-enabled/govi.box.conf

#CMD [ "/usr/local/bin/ep", "/etc/nginx/sites-available/*.conf"]
#CMD ["/usr/sbin/nginx", "-c", "/etc/nginx/nginx.conf" ]

ADD scripts/start.sh /start.sh
RUN chmod 700 /start.sh

# Configuración PHP-FPM

# Instalación de Composer

# Instalación y Configuración de  Drush con Composer

# Asignar el volumen del DocumentRoot del proyecto

# Ejecución del script de inicio
CMD ["/start.sh"]
