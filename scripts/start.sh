#!/bin/bash

source /root/.bash_profile

RUN chown -R govi:users /usr/share/nginx/html/www/drupal

/usr/local/bin/ep /etc/nginx/sites-available/*.conf
/usr/bin/supervisord -c /etc/supervisord.conf
