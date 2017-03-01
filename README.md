# Ambientes de ejecución Govimentum CMS

Esta es una imagen de docker que permite la creacion de contenedores con los ambientes de ejecución de Govimentum CMS, el cual es una distribución basada en Drupal 7.

## Que hay dentro?

* Alpine Linux 3.4
* Nginx 1.11
* php-fpm 5.6
* composer
* Supervisord

## Requerimientos

* Docker 1.12.x

## Inicializar contenedor

docker run --name algun-nombre -e 'WEBROOT=www' -e 'DOMAIN_NAME=ejemplo.net' -e 'SITE_ENV=dev|stage|prod' govi-box:latest

## TODO: Parámetros

## TODO: Docker Compose

## TODO: Esquemático
