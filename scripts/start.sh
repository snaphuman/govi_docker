#!/bin/bash

echo "export GOVIBOX_DB_PASSWORD=$GOVIBOX_DB_PASSWORD" >> /home/govi/.bash_profile
echo "export GOVIBOX_SITENAME=$GOVIBOX_SITENAME" >> /home/govi/.bash_profile
echo "export GOVIBOX_DB_USER=$GOVIBOX_DB_USER" >> /home/govi/.bash_profile
echo "export GOVIBOX_DB_NAME=$GOVIBOX_DB_NAME" >> /home/govi/.bash_profile
echo "export GOVIBOX_BASE_URL=$GOVIBOX_BASE_URL" >> /home/govi/.bash_profile
echo "export GOVIBOX_DB_HOST=$GOVIBOX_DB_HOST" >> /home/govi/.bash_profile

su -c "source /home/govi/.bash_profile" - govi

/usr/local/bin/ep /etc/nginx/sites-available/*.conf
/usr/bin/supervisord -c /etc/supervisord.conf
