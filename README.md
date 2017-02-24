# Ambiente de desarrollo Govimentum CMS

## Requerimientos

- Docker 1.12.x

## Inicializar contenedor

docker run --name algun-nombre -e 'WEBROOT=www' -e 'DOMAIN_NAME=ejemplo.net' -e 'SITE_ENV=dev|stage|prod' govi-box:latest

