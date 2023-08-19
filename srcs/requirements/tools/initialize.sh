#!/bin/bash

ENV_CONTENT="DOMAIN_NAME=zstenger.42.fr
CERT_=
KEY_=
DB_NAME=dbname
DB_ROOT=dbpass
DB_USER=wpuser
DB_PASS=wppass"

echo "$ENV_CONTENT" > ../.env

if [ ! -d "/home/${USER}/data" ]; then
		mkdir ~/data
        mkdir ~/data/mariadb
        mkdir ~/data/wordpress
fi