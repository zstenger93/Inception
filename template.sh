
	echo "# mariadb" > .env
	while true; do
		printf "\033[1;31mEnter the database root password:\033[0;39m "
    	read DB_NAME
		if [ -n "$DB_NAME" ]; then
			echo "DB_NAME=$DB_NAME" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done

	while true; do
		printf "\033[1;31mEnter the database user:\033[0;39m "
		read DB_ROOT
		if [ -n "$DB_ROOT" ]; then
			echo "DB_ROOT=$DB_ROOT" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done

	while true; do
		printf "\033[1;31mEnter the database:\033[0;39m "
		read DB_USER
		if [ -n "$DB_USER" ]; then
			echo "DB_USER=$DB_USER" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done

	while true; do
		printf "\033[1;31mEnter the database user password:\033[0;39m "
		read DB_PASS
		if [ -n "$DB_PASS" ]; then
			echo "DB_PASS=$DB_PASS" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done

	echo "# wordpress" >> .env

	while true; do
		printf "\033[1;31mEnter the WordPress admin:\033[0;39m "
		read WP_ADMIN
		if [ -n "$WP_ADMIN" ]; then
			echo "WP_ADMIN=$WP_ADMIN" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done

	while true; do
		printf "\033[1;31mEnter the WordPress admin password:\033[0;39m "
		read WP_ADMIN_PW
		if [ -n "$WP_ADMIN_PW" ]; then
			echo "WP_ADMIN_PW=$WP_ADMIN_PW" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done

	while true; do
		printf "\033[1;31mEnter the WordPress admin email:\033[0;39m "
		read WP_ADMIN_EMAIL
		if [ -n "$WP_ADMIN_EMAIL" ]; then
			echo "WP_ADMIN_EMAIL=$WP_ADMIN_EMAIL" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done

	echo "# nginx" >> .env

	while true; do
		printf "\033[1;31mEnter the nginx domain:\033[0;39m "
		read NGINX_DOMAIN
		if [ -n "$NGINX_DOMAIN" ]; then
			echo "NGINX_DOMAIN=$NGINX_DOMAIN" >> .env
			break
		else
			echo "Input cannot be empty. Please try again."
		fi
	done
	
