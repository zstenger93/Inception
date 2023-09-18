# Inception

<img align=center src="https://github.com/zstenger93/Inception/blob/master/token.jpeg">

Project about using docker-compose to create multiple docker images and services inside of a virtual machine

# Mandatory

## docker-compose

Contains settings for services, networks and volumes

By using docker-compose, we are able to deploy multiple containers by executing all the necessary dockerfiles.

## mariadb

The database

## nginx

For the ssl certificate and key

## wordpress



## commands

docker exec -it mariadb sh

docker stop  mariadb nginx wordpress

docker rm  mariadb nginx wordpress

docker rmi  srcs_mariadb srcs_nginx wordpress