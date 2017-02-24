#!/bin/bash

/usr/local/bin/ep /etc/nginx/sites-available/*.conf
/usr/bin/supervisord
