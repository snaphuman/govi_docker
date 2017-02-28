#!/bin/bash

/usr/local/bin/ep /etc/nginx/sites-available/*.conf
#/usr/bin/supervisord -c /etc/supervisord.conf
/usr/bin/supervisord -c /etc/supervisord.conf
