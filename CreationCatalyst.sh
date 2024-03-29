#!/bin/bash

# start working on bonus
# this inScription will create all the folders, files needed by the project.

# creating aliases to make hell less hell
echo "Creating aliases ..."
# docker commands for the speed of life
echo "alias rmd='docker stop \$(docker ps -qa); docker rm \$(docker ps -qa); docker rmi -f \$(docker images -qa); docker volume rm \$(docker volume ls -q); docker network rm \$(docker network ls -q)'" >> ~/.bashrc
echo "alias build='docker-compose build'" >> ~/.bashrc
echo "alias up='docker-compose up -d'" >> ~/.bashrc
echo "alias down='docker-compose down'" >> ~/.bashrc
echo "alias connect='docker exec -it mariadb mysql -u dbuser -p'" >> ~/.bashrc
echo "alias rootdb='docker exec -it mariadb mysql -u root -p'" >> ~/.bashrc
echo "alias lsd='docker ps; docker images; docker volume ls'" >> ~/.bashrc
#open bashrc
echo "alias a='vi ~/.bashrc'" >> ~/.bashrc
# accessing containers
echo "alias mar='docker exec -it mariadb sh'" >> ~/.bashrc
echo "alias ngi='docker exec -it nginx sh'" >> ~/.bashrc
echo "alias wor='docker exec -it wordpress sh'" >> ~/.bashrc
# other aliases
echo "alias .='cd ..'" >> ~/.bashrc
echo "alias gh='open https://github.com/zstenger93/Inception'" >> ~/.bashrc
echo "alias wp='open https://zstenger.42.fr'" >> ~/.bashrc

sleep 1
echo -e "\033[1;32mDone\033[0;39m"

# apply the changes to the current terminal
source ~/.bashrc

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

    # how many folder do we need? yes
    mkdir -p /home/zstenger/mariadb_data
    mkdir -p /home/zstenger/wordpress_data

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating docker-compose ..."

    sleep 1
    # create the docker-compose file
    DOCKERCOMPOSE="version: '3'

services:
    nginx:
        image: nginx1
        container_name: nginx
        build: ./requirements/nginx
        env_file: .env
        ports:
            - '443:443'
        volumes:
            - wordpress_data:/var/www/html
        networks:
            - inception
        depends_on:
            - wordpress
        restart: unless-stopped

    mariadb:
        image: mariadb1
        container_name: mariadb
        build: ./requirements/mariadb
        env_file:
            - .env
        networks:
            - inception
        volumes:
            - mariadb_data:/var/www/html
        restart: unless-stopped

    wordpress:
        image: wordpress1
        container_name: wordpress
        build: ./requirements/wordpress
        env_file: .env
        depends_on:
            - mariadb
        volumes:
            - wordpress_data:/var/www/html
        networks:
            - inception
        restart: unless-stopped

networks:
    inception:
        driver: bridge

volumes:
    mariadb_data:
        driver: local
        driver_opts:
            type: 'none'
            o: 'bind'
            device: \"/home/zstenger/mariadb_data\"

    wordpress_data:
        driver: local
        driver_opts:
            type: 'none'
            o: 'bind'
            device: \"/home/zstenger/wordpress_data\""


    echo "$DOCKERCOMPOSE" > srcs/docker-compose.yml

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating Dockerfile for mariadb ..."

    sleep 1
    # create the dockerfile for mariadb
    MARIADB_DOCKERFILE="FROM alpine:3.18
RUN apk add mysql mysql-client
RUN mkdir -p /run/mysqld
RUN mkdir -p /var/lib/mysql
COPY conf/my.cnf /usr/local/bin/my.cnf
COPY tools/create_database.sh /create_database.sh
RUN mariadb-install-db --user=root --datadir=/var/lib/mysql --skip-test-db
EXPOSE 3306
ENTRYPOINT [\"sh\", \"create_database.sh\"]"

    echo "$MARIADB_DOCKERFILE" > srcs/requirements/mariadb/Dockerfile

    echo -e "\033[1;32mDone\033[0;39m"
    echo -e "Creating config file for database ..."
    sleep 1
    # creating mariadb config
    MARIADB_CONF="[mysql]
default-character-set=utf8
[mysqld]
datadir = /var/lib/mysql
socket  = /var/run/mysqld/mysqld.sock
bind-address = 0.0.0.0
port = 3306"

    echo "$MARIADB_CONF" > srcs/requirements/mariadb/conf/my.cnf

    echo -e "\033[1;32mDone\033[0;39m"
    echo -e "Creating setup file for database ..."
    sleep 1
    # script to create the database
    CREATE_DATABASE="#!/bin/sh

# echo '
# [mysql]
# default-character-set=utf8
# [mysqld]
# datadir = /var/lib/mysql
# socket  = /var/run/mysqld/mysqld.sock
# bind-address = 0.0.0.0
# port = 3306
# ' > /usr/local/bin/my.cnf

cat > database.sql <<EOF
CREATE DATABASE IF NOT EXISTS \${DATABASE_NAME};
ALTER USER 'root'@'localhost' IDENTIFIED BY '\${DATABASE_ROOT}';
CREATE USER IF NOT EXISTS '\${DATABASE_USER}' IDENTIFIED BY '\${DATABASE_USER_PASS}';
GRANT ALL PRIVILEGES ON \${DATABASE_NAME}.* TO '\${DATABASE_USER}';
FLUSH PRIVILEGES;
EOF

exec mariadbd --no-defaults --user=root --datadir=/var/lib/mysql --init-file=/database.sql"

    echo "$CREATE_DATABASE" > srcs/requirements/mariadb/tools/create_database.sh

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating Dockerfile for nginx ..."

    sleep 1
    # create the dockerfile for nginx
    NGINX_DOCKERFILE="FROM alpine:3.18
RUN apk add nginx openssl
COPY conf/nginx.conf /etc/nginx/http.d/default.conf
COPY tools/setup_nginx.sh .
ENTRYPOINT [\"sh\", \"setup_nginx.sh\"]"

    echo "$NGINX_DOCKERFILE" > srcs/requirements/nginx/Dockerfile

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating config file for nginx ..."

    sleep 1
    # create the config file for nginx
    NGINX_CONF="server {
    listen 443 ssl;
    server_name '\"\$WP_DOMAIN\"';
    
    
    ssl_certificate '\"\$CERT_\"';
    ssl_certificate_key '\"\$KEY_\"';
    ssl_protocols TLSv1.2 TLSv1.3;
    
    root /var/www/html;
    index index.php index.html index.htm;
    
    location / {
        try_files \$uri \$uri/ =404;

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
    # script file to setup nginx
    SETUP_NGINX="#!/bin/sh
# create the config and generate key and certificate

# echo '
# server {
#     listen 443 ssl;
#     server_name '\"\$WP_DOMAIN\"';
    
    
#     ssl_certificate '\"\$CERT_\"';
#     ssl_certificate_key '\"\$KEY_\"';
#     ssl_protocols TLSv1.2 TLSv1.3;
    
#     root /var/www/html;
#     index index.php index.html index.htm;
    
#     location / {
#         try_files \$uri \$uri/ =404;
#         autoindex on;
#     }

#     location ~ \.php$ {
#         try_files \$uri =404;
#         fastcgi_pass wordpress:9000;
#         fastcgi_index index.php;
#         fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
#         include fastcgi_params;
#     }
# }
# ' > /etc/nginx/http.d/default.conf

openssl req -x509 -newkey rsa:4096 -keyout \${KEY_} -out \${CERT_} -sha256 -days 365 -nodes -subj \"/CN=\"\${WP_DOMAIN}\"\"
exec nginx -g \"daemon off;\""

    echo "$SETUP_NGINX" > srcs/requirements/nginx/tools/setup_nginx.sh

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating Dockerfile for wordpress ..."

    sleep 1
    # create the dockerfile for wordpress
    WORDPRESS_DOCKERFILE="FROM alpine:3.18
RUN apk add --no-cache php \\
    --no-cache php-fpm \\
    --no-cache php-mysqli \\
    --no-cache mysql-client \\
    --no-cache php-phar \\
    --no-cache php-cgi \\
    --no-cache php-fileinfo \\
    --no-cache php-json \\
    --no-cache php-iconv \\
    --no-cache php-curl \\
    --no-cache php-dom \\
    --no-cache php-mbstring \\
    --no-cache php-openssl \\
    --no-cache php-xml \\
    --no-cache php-tokenizer \\
    --no-cache php-session \\
    --no-cache php-exif \\
    --no-cache curl \\
    --no-cache tar 
WORKDIR /var/www/html
EXPOSE 9000
COPY conf/www.conf /etc/php81/php-fpm.d/www.conf
COPY tools/wordpress_setup.sh /wordpress_setup.sh
RUN chmod +x /wordpress_setup.sh
ENTRYPOINT [\"/wordpress_setup.sh\"]"

    echo "$WORDPRESS_DOCKERFILE" > srcs/requirements/wordpress/Dockerfile

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating config file for wordpress ..."
    sleep 1
    # wordpress cofnig file
    WORDPRESS_CONFIG="[www]
user = nobody
group = nobody
listen = 9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3"

    echo "$WORDPRESS_CONFIG" > srcs/requirements/wordpress/conf/www.conf
    # /etc/hosts addition to e able to access the site
    HOSTS_CONFIG="zstenger.42.fr"
    echo "$HOSTS_CONFIG" > srcs/requirements/wordpress/conf/hosts.conf

    echo -e "\033[1;32mDone\033[0;39m"
    echo "Creating setup file for wordpress ..."
    sleep 1
    # wordpress setup script
    WORDPRESS_SETUP="#!/bin/sh


# echo '
# [www]
# user = nobody
# group = nobody
# listen = 9000
# pm = dynamic
# pm.max_children = 5
# pm.start_servers = 2
# pm.min_spare_servers = 1
# pm.max_spare_servers = 3
# ' > /etc/php81/php-fpm.d/www.conf

echo '
zstenger.42.fr
' >> /etc/hosts

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
    # creating the template for the env file with the necessary attributes
    ENV_TEMPLATE="#!/bin/sh

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
    echo -e "\033[1;32mDone\033[0;39m"
    sleep 1
    echo "Requesting input for the .env file ..."
    # run the template script and get the attributes for the .env file
    bash template.sh
    sleep 1
    echo -e "\033[1;32mDone\033[0;39m"
    sleep 1
    # moving it to the srcs folder
    mv .env srcs/
    echo -e "\033[1;33mCreation has been finished, ready to go in sleep\033[0;39m"
else
    echo -e "\033[1;32mYou have made the right choice, padavan.\033[0;39m"
fi
