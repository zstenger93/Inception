echo "Creating folders ..."
mkdir -p src/requirements/mariadb/conf
mkdir -p src/requirements/mariadb/tools
mkdir -p src/requirements/nginx/conf
mkdir -p src/requirements/nginx/tools
mkdir -p src/requirements/tools
mkdir -p src/requirements/wordpress/conf
mkdir -p src/requirements/wordpress/tools

echo "\033[1;32mDone\033[0;39m"
echo "Creating docker-compose ..."

sleep 1
DOCKERCOMPOSE="version: '3'

# Services and their settings we are going to use
# Alaways restart if there is a problem
services:
  nginx:
    container_name: nginx
    build:
      context: ./
      dockerfile: requirements/nginx/Dockerfile
    ports:
      - 443:443
    volumes:
      - wordpress_data:/var/www/html
    restart: always
    networks:
      - network

  mariadb:
    container_name: mariadb
    build:
      context: ./
      dockerfile: requirements/mariadb/Dockerfile
      args:
        DB_NAME: \${DB_NAME}
        DB_USER: \${DB_USER}
        DB_PASS: \${DB_PASS}
        DB_ROOT: \${DB_ROOT}
    volumes:
      - mariadb_data:/var/lib/mysql
    networks:
      - network
    restart: always
    env_file:
      - .env

# Has a dependency of database
  wordpress:
    container_name: wordpress
    depends_on:
      - mariadb
    build:
      context: ./
      dockerfile: requirements/wordpress/Dockerfile
      args:
        DB_NAME: \${DB_NAME} # build time arguments are making dockerfiles
        DB_USER: \${DB_USER} # more dunamic and flexible
        DB_PASS: \${DB_PASS}
    restart: always
    env_file:
      - .env
    networks:
      - network

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
  network:
    driver: bridge"

echo "$DOCKERCOMPOSE" > src/docker-compose.yml

echo "\033[1;32mDone\033[0;39m"
echo "Creating Dockerfile for mariadb ..."

sleep 1
MARIADB_DOCKERFILE="FROM debian:bullseye

# Installing requirements
RUN apt-get update && apt-get install -y \\
	mariadb-server \\
	mariadb-client && \\
	mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

EXPOSE 3306

ENV MYSQL_SOCKET=/var/run/mysqld/mysqld.sock

COPY requirements/mariadb/conf/mariadb.sh /mariadb.sh

RUN chmod +x mariadb.sh && bash mariadb.sh

ENTRYPOINT [ \"/usr/local/bin/mariadb.sh\" ]

# Launch and enable the listening globally for the database
CMD [\"mysqld\", \"--bind-address=0.0.0.0\"]"

echo "$MARIADB_DOCKERFILE" > src/requirements/mariadb/Dockerfile

MARIADB_CONF=""

echo "\033[1;32mDone\033[0;39m"
echo "Creating Dockerfile for nginx ..."

sleep 1
NGINX_DOCKERFILE="FROM debian:bullseye

# Installing requirements and creating crt + key
RUN apt-get update && apt-get isntall -y \\
	nginx \\
	openssl && \\
	mkdir /etc/nginx/ssl && openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \\
    -out /etc/nginx/ssl/zstenger.crt \\
    -keyout /etc/nginx/ssl/zstenger.key

COPY ./conf/nginx.conf /etc/nginx/conf.d

# nginx config
RUN mkdir -p /run/nginx

# Only port allowed by the subject pdf
EXPOSE 443

# alunch
CMD [\"nginx\", \"-g\", \"daemon off;\"]"

echo "$NGINX_DOCKERFILE" > src/requirements/nginx/Dockerfile

echo "\033[1;32mDone\033[0;39m"
echo "Creating config file for nginx ..."

sleep 1
NGINX_CONF="server {
	listen 443 ssl; # server will listen on port 443 
	listen [::]:443 ssl; # for incoming SSL/TLS encrypted connections

	server_name zstenger.42.fr; # domain name
	ssl_certificate		/etc/nginx/ssl/zstenger.crt; # ssl certificate
	ssl_certificate_key	/etc/nginx/ssl/zstenger.key; # key to the sl certificate

	ssl_protocols		TLSv1.2 TLSv1.3; # protocols required by subject

	root /var/www/html; # website files
	index index.php index.nginx-debian.html; # order the files being checked

	location / {
		try_files \$uri \$uri/ /index.php\$is_args\$args;
	}

	location ~ \.php$ {
		fastcgi_split_path_info ^(.+\.php)(/.+)$;
		fastcgi_pass wordpress:6666;
		fastcgi_index index.php;
		include fastcgi_params;
		fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
		fastcgi_param SCRIPT_NAME \$fastcgi_script_name;
	}
}"

echo "$NGINX_CONF" > src/requirements/nginx/conf/nginx.conf

echo "\033[1;32mDone\033[0;39m"
echo "Creating Dockerfile for wordpress ..."

sleep 1
WORDPRESS_DOCKERFILE="FROM debian:bullseye

# Installing requirements
RUN apt-get update && apt-get install \\
	php \\
	php-cgi \\
	php-mysql \\
	php-fpm \\
	php-pdo \\
	php-gd php-cli \\
	php-mbstring \\
	bash \\
	wget \\
	curl

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT [\"/usr/local/bin/create_wordpress.sh\"]

# Ignore daemon and launch in the foreground
CMD [\"/usr/sbin/php-fpm7.3\", \"-F\"]"

echo "$WORDPRESS_DOCKERFILE" > src/requirements/wordpress/Dockerfile

echo "\033[1;32mDone\033[0;39m"
echo "Creating the environment ..."

sleep 1
ENV_TEMPLATE="
echo \"# mariadb\" > .env
while true; do
    read -p \"\033[1;31mEnter the database root password:\033[0;39m \" DB_NAME
    if [ -n \"\$DB_NAME\" ]; then
        echo \"DB_NAME=\$DB_NAME\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done

while true; do
    read -p \"\033[1;31mEnter the database user:\033[0;39m \" DB_ROOT
    if [ -n \"\$DB_ROOT\" ]; then
        echo \"DB_ROOT=\$DB_ROOT\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done

while true; do
    read -p \"\033[1;31mEnter the database:\033[0;39m \" DB_USER
    if [ -n \"\$DB_USER\" ]; then
        echo \"DB_USER=\$DB_USER\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done

while true; do
    read -p \"\033[1;31mEnter the database user password:\033[0;39m \" DB_PASS
    if [ -n \"\$DB_PASS\" ]; then
        echo \"DB_PASS=\$DB_PASS\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done

echo \"# wordpress\" >> .env

while true; do
    read -p \"\033[1;31mEnter the WordPress admin:\033[0;39m \" WP_ADMIN
    if [ -n \"\$WP_ADMIN\" ]; then
        echo \"WP_ADMIN=\$WP_ADMIN\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done

while true; do
    read -p \"\033[1;31mEnter the WordPress admin password:\033[0;39m \" WP_ADMIN_PW
    if [ -n \"\$WP_ADMIN_PW\" ]; then
        echo \"WP_ADMIN_PW=\$WP_ADMIN_PW\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done

while true; do
    read -p \"\033[1;31mEnter the WordPress admin email:\033[0;39m \" WP_ADMIN_EMAIL
    if [ -n \"\$WP_ADMIN_EMAIL\" ]; then
        echo \"WP_ADMIN_EMAIL=\$WP_ADMIN_EMAIL\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done

echo \"# nginx\" >> .env

while true; do
    read -p \"\033[1;31mEnter the nginx domain:\033[0;39m \" NGINX_DOMAIN
    if [ -n \"\$NGINX_DOMAIN\" ]; then
        echo \"NGINX_DOMAIN=\$NGINX_DOMAIN\" >> .env
        break
    else
        echo \"Input cannot be empty. Please try again.\"
    fi
done
"

echo "$ENV_TEMPLATE" > template.sh

echo "\033[1;32mDone\033[0;39m"
echo "Creating template file for .env"
chmod +x template.sh
echo "\033[1;32mDone\033[0;39m"
sleep 1
echo "Requesting input for the .env file:"
bash template.sh
sleep 1
echo "\033[1;32mDone\033[0;39m"
sleep 1
echo "\033[1;33mCreation has been finished, ready to go in sleep\033[0;39m"