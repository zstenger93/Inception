#!/bin/bash

# ask the user if wants to go insane with me
printf "\033[1;31mDo you want to continue and create Inception which is famous for driving people Insane?\033[0;39m\033[1;32m(y/yes)\033[0;39m "
read response

#based on response execute the script or not
if [[ "$response" == "y" || "$response" == "yes" ]]; then
    echo "Continuing with the script..."
    sleep 1
    echo "Creating folders ..."
    sleep 1
    # creating the requested project folder structure by the subject in the pdf
    mkdir -p srcs/requirements/mariadb/conf \
        srcs/requirements/mariadb/tools \
        srcs/requirements/nginx/conf \
        srcs/requirements/nginx/tools \
        srcs/requirements/tools \
        srcs/requirements/wordpress/conf \
        srcs/requirements/wordpress/tools
    touch srcs/requirements/tools/tool.sh

    # get the MacOs version to get to know if we can qualify for the darwin award
    # system=$(uname -s)
    # if [ "$system" != "Darwin" ]; then
    #     # creates some basic folders if they doesn't exist
    #     if [ ! -d "/home/${USER}/data" ]; then
    #             mkdir ~/data
    #             mkdir ~/data/mariadb
    #             mkdir ~/data/wordpress
    #     fi
    # fi

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating docker-compose ..."

    sleep 1
    # create the docker-compose file
    DOCKERCOMPOSE="version: '3'

# Services and their settings we are going to use
# Restart if there is a problem unless stopped i guess?
services:
    nginx:
        container_name: nginx
        env_file:
            - .env
        build:
            context: ./
            dockerfile: requirements/nginx/Dockerfile
        ports:
            - 443:443
        volumes:
            - wordpress_data:/var/www/html
        restart: unless-stopped
        networks:
            - inception
        depends_on:
            - wordpress

    mariadb:
        container_name: mariadb
        env_file:
            - .env
        build:
            context: ./
            dockerfile: requirements/mariadb/Dockerfile
        args:
            DB_NAME: \${DATABASE_NAME}
            DB_USER: \${DATABASE_USER}
            DB_PASS: \${DATABASE_USER_PASS}
            DB_ROOT: \${DATABASE_ROOT}
        volumes:
            - mariadb_data:/var/lib/mysql
        networks:
            - inception
        restart: unless-stopped

    # Has a dependency of database obviously
    wordpress:
        container_name: wordpress
        env_file:
            - .env
        depends_on:
            - mariadb
        build:
            context: ./
            dockerfile: requirements/wordpress/Dockerfile
        args:
            WP_ADMIN_NAME: \${WP_ADMIN} # build time arguments are making dockerfiles
            WP_ADMIN_PW: \${WP_ADMIN_PW} # more dunamic and flexible
            WP_ADMIN_EMAIL: \${WP_ADMIN_EMAIL}
        volumes:
            - wordpress_data:/var/www/html
        restart: unless-stopped
        networks:
            - inception

# Volume locations and settings
volumes:
    mariadb_data:
        driver: local
        driver_opts:
            type: 'none'
            o: 'bind'
            device: /home/zstenger/data/mariadb
    wordpress_data:
        driver: local
        driver_opts:
            type: 'none'
            o: 'bind'
            device: /home/zstenger/data/mariadb

networks:
    inception:
        driver: bridge"

    echo "$DOCKERCOMPOSE" > srcs/docker-compose.yml

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating Dockerfile for mariadb ..."

    sleep 1
    # create the dockerfile for mariadb
    MARIADB_DOCKERFILE="FROM debian:buster

    RUN apt-get update && apt-get upgrade -y && apt-get install mariadb-server mariadb-client procps -y

    RUN sed -ie 's/bind-address            = 127.0.0.1/bind-address = 0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

    RUN mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

    COPY ./docker-entrypoint.sh /usr/local/bin
    RUN chmod +x /usr/local/bin/docker-entrypoint.sh

    EXPOSE 3306

    #USER mysql
    HEALTHCHECK --interval=10s --timeout=3s CMD mysql -e \"SELECT 1\" || exit 1

    ENTRYPOINT [\"docker-entrypoint.sh\"]
    CMD [\"mysqld\"]"

    echo "$MARIADB_DOCKERFILE" > srcs/requirements/mariadb/Dockerfile

    echo -e "\033[1;32mDone\033[0;39m"
    echo -e "Creating config file for database ..."
    sleep 1

    MARIADB_CONF="#!/bin/sh

[mysql]
default-character-set=utf8
[mysqld]
datadir = /var/lib/mysql
socket  = /var/run/mysqld/mysqld.sock
bind-address = 0.0.0.0
port = 3306"

    echo "$MARIADB_CONF" > srcs/requirements/mariadb/conf/mariadb.conf

    echo -e "\033[1;32mDone\033[0;39m"
    echo -e "Creating setup file for database ..."
    sleep 1

    CREATE_DATABASE="#!/bin/sh

cat srcs/requirements/mariadb/conf/mariadb.conf > /usr/local/bin/my.cnf

cat > srcs/requirements/mariadb/database.sql <<EOF
CREATE DATABASE IF NOT EXISTS \${DB_NAME};
ALTER USER 'root'@'localhost' IDENTIFIED BY '\${DATABASE_ROOT}';
CREATE USER IF NOT EXISTS '${DATABASE_USER}' IDENTIFIED BY '${DATABASE_USER_PASS}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DATABASE_USER}';
FLUSH PRIVILEGES;
EOF

exec mariadbd --no-defaults --user=root --datadir=/var/lib/mysql --init-file=/problem.sql"

    echo "$CREATE_DATABASE" > srcs/requirements/mariadb/tools/create_database.sh

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating Dockerfile for nginx ..."

    sleep 1
    # create the dockerfile for nginx
    NGINX_DOCKERFILE="FROM debian:buster

    RUN apt-get update && apt-get upgrade \
        && apt-get install -y nginx openssl

    ARG NGINX_DOMAIN

    RUN mkdir -p \"/etc/cert/\$NGINX_DOMAIN\" && \
        mkdir -p /var/run/nginx && \
        chown -R www-data:www-data /var/run/nginx

    RUN openssl req -x509 -newkey rsa:4096 -keyout \"/etc/cert/\$NGINX_DOMAIN/key.pem\" -out \"/etc/cert/\$NGINX_DOMAIN/cert.pem\" -sha256 -days 365 -nodes -subj \"/CN=\$NGINX_DOMAIN\"

    COPY ./nginx.conf /etc/nginx/nginx.conf
    COPY ./wordpress.conf \"/etc/nginx/conf.d/\$NGINX_DOMAIN.conf\"
    COPY ./adminer.conf \"/etc/nginx/conf.d/adminer.\$NGINX_DOMAIN.conf\"

    RUN sed -i \"s/\$NGINX_DOMAIN/\$NGINX_DOMAIN/g\" /etc/nginx/conf.d/*

    CMD [\"nginx\", \"-g\", \"daemon off;\"]"

    echo "$NGINX_DOCKERFILE" > srcs/requirements/nginx/Dockerfile

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating config file for nginx ..."

    sleep 1
    # create the config file for nginx
    NGINX_CONF="server {
    listen 443 ssl;
    server_name '\"\$DOMAIN_NAME\"';
    
    
    ssl_certificate '\"\$CERT_\"';
    ssl_certificate_key '\"\$KEY_\"';
    ssl_protocols TLSv1.2 TLSv1.3;
    
    root /var/www/html;
    index index.php index.html index.htm;
    
    location / {
		try_files \$uri \$uri/ =404;
		autoindex on;
	}

	location ~ \.php$ {
		try_files \$uri =404;
		fastcgi_pass wordpress:9000;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		include fastcgi_params;
	}
}"

    echo "$NGINX_CONF" > srcs/requirements/nginx/conf/nginx.conf

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating nginx setup file ..."
    sleep 1

    SETUP_NGINX=" # create the config and generate key and certificate

cat srcs/requirements/nginx/conf/nginx.conf > /etc/nginx/http.d/default.conf
openssl req -x509 -newkey rsa:4096 -keyout \${KEY_} -out \${CERT_} -sha256 -days 365 -nodes -subj \"/CN=\"\${DOMAIN_NAME}\"\"
exec nginx -g \"daemon off;\""

    echo "$SETUP_NGINX" > srcs/requirements/nginx/tools/setup_nginx.sh

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating Dockerfile for wordpress ..."

    sleep 1
    # create the dockerfile for wordpress
    WORDPRESS_DOCKERFILE="FROM alpine:3.18
RUN apk add --no-cache php \
    && add --no-cache php-fpm \
    && add --no-cache php-mysqli \
    && add --no-cache mysql-client \
    && add --no-cache php-phar \
    && add --no-cache php-cgi \
    && add --no-cache php-fileinfo \
    && add --no-cache php-json \
    && add --no-cache php-iconv \
    && add --no-cache php-curl \
    && add --no-cache php-dom \
    && add --no-cache php-mbstring \
    && add --no-cache php-openssl \
    && add --no-cache php-xml \
    && add --no-cache php-tokenizer \
    && add --no-cache php-session \
    && add --no-cache php-exif \
    && add --no-cache curl \
    && add --no-cache tar 
WORKDIR /var/www/html
EXPOSE 9000
COPY tools/wp_setup.sh /wp_setup.sh
RUN chmod +x /wordpress_setup.sh
ENTRYPOINT [\"/wordpress_setup.sh\"]"

    echo "$WORDPRESS_DOCKERFILE" > srcs/requirements/wordpress/Dockerfile

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating config file for wordpress ..."
    sleep 1

    WORDPRESS_CONFIG="[www]
user = insane
group = insane
listen = 9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3"

    echo "$WORDPRESS_CONFIG" > srcs/requirements/wordpress/conf/wordpress.conf

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating setup file for wordpress ..."
    sleep 1

    WORDPRESS_SETUP="cat srcs/requirements/wordpress/conf/wordpress.conf > /etc/php81/php-fpm.d/www.conf
if [ ! -f /var/www/html/wp-config.php ]; then
    curl -LO https://wordpress.org/wordpress-5.7.2.tar.gz
    tar -xvzf wordpress-5.7.2.tar.gz
    mv wordpress/* /var/www/html/
    rmdir wordpress
    rm wordpress-5.7.2.tar.gz
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    wp config create --dbname=\${DATABASE_NAME} --dbuser=\${DATABASE_USER} --dbpass=\${DATABASE_USER_PASS} --dbhost=mariadb --path='/var/www/html'
    wp core install --url=\${WP_DOMAIN} --title=\"Insaneption\" --admin_user=\${WP_ADMIN} --admin_password=\${WP_ADMIN_PW} --admin_email=\${WP_ADMIN_EMAIL} --path='/var/www/html'
    wp user create \${WP_USER} \${WP_USER_EMAIL} --user_pass=\${WP_USER_PASS}
fi

php-fpm81 -F"

    echo "$WORDPRESS_SETUP" > srcs/requirements/wordpress/tools/wordpress_setup.sh

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating the environment ..."

    sleep 1
    # creating the template for the env file
    ENV_TEMPLATE="
    echo \"# mariadb\" > .env
    while true; do
        printf \"\033[1;31mEnter the database name:\033[0;39m \"
        read DB_NAME
        if [ -n \"\$DB_NAME\" ]; then
            echo \"DATABASE_NAME=\$DB_NAME\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the database root password:\033[0;39m \"
        read DB_ROOT
        if [ -n \"\$DB_ROOT\" ]; then
            echo \"DATABASE_ROOT=\$DB_ROOT\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the database username:\033[0;39m \"
        read DB_USER
        if [ -n \"\$DB_USER\" ]; then
            echo \"DATABASE_USER=\$DB_USER\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the database user password:\033[0;39m \"
        read DB_USER_PASS
        if [ -n \"\$DB_USER_PASS\" ]; then
            echo \"DATABASE_USER_PASS=\$DB_USER_PASS\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    echo \"# wordpress\" >> .env
    while true; do
        printf \"\033[1;31mEnter the WordPress domain:\033[0;39m \"
        read WP_DOMAIN
        if [ -n \"\$WP_DOMAIN\" ]; then
            echo \"WP_DOMAIN=\$WP_DOMAIN\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the WordPress admin:\033[0;39m \"
        read WP_ADMIN
        if [ -n \"\$WP_ADMIN\" ]; then
            echo \"WP_ADMIN=\$WP_ADMIN\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the WordPress admin password:\033[0;39m \"
        read WP_ADMIN_PW
        if [ -n \"\$WP_ADMIN_PW\" ]; then
            echo \"WP_ADMIN_PW=\$WP_ADMIN_PW\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the WordPress admin email:\033[0;39m \"
        read WP_ADMIN_EMAIL
        if [ -n \"\$WP_ADMIN_EMAIL\" ]; then
            echo \"WP_ADMIN_EMAIL=\$WP_ADMIN_EMAIL\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the WordPress user:\033[0;39m \"
        read WP_USER
        if [ -n \"\$WP_USER\" ]; then
            echo \"WP_USER=\$WP_USER\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the WordPress user password:\033[0;39m \"
        read WP_USER_PASS
        if [ -n \"\$WP_USER_PASS\" ]; then
            echo \"WP_USER_PASS=\$WP_USER_PASS\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    while true; do
        printf \"\033[1;31mEnter the WordPress user email:\033[0;39m \"
        read WP_USER_EMAIL
        if [ -n \"\$WP_USER_EMAIL\" ]; then
            echo \"WP_USER_EMAIL=\$WP_USER_EMAIL\" >> .env
            break
        else
            echo \"Input cannot be empty. Please try again.\"
        fi
    done

    echo \"# API keys\" >> .env
    echo \"CERT_=/etc/ssl/certs/zstenger.42.fr.crt\" >> .env
    echo \"KEY_=/etc/ssl/private/zstenger.42.fr.key\" >> .env"

    echo "$ENV_TEMPLATE" > template.sh

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating template file for .env ..."
    chmod +x template.sh
    echo -e "\033[1;32mDone\033[0;39m"
    sleep 1
    echo "Requesting input for the .env file ..."
    # run the template script and get the attributes for the .env file
    bash template.sh
    sleep 1
    echo -e "\033[1;32mDone\033[0;39m"
    sleep 1
    echo -e "\033[1;33mCreation has been finished, ready to go in sleep\033[0;39m"
else
    echo -e "\033[1;32mYou have made the right choice, padavan.\033[0;39m"
fi
