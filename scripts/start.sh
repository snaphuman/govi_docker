#!/bin/bash

if [ ! -z "$WEBROOT" ]; then
    export WEBROOT=""
else
    echo "webroot ya existe $WEBROOT"
fi

/usr/local/bin/ep /etc/nginx/sites-available/*.conf
cat /etc/nginx/sites-available/govi.box.conf
/usr/sbin/nginx -g "daemon off;"
