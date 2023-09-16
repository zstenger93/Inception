cat srcs/requirements/wordpress/conf/wordpress.conf > /etc/php81/php-fpm.d/www.conf
if [ ! -f /var/www/html/wp-config.php ]; then
    curl -LO https://wordpress.org/wordpress-5.7.2.tar.gz
    tar -xvzf wordpress-5.7.2.tar.gz
    mv wordpress/* /var/www/html/
    rmdir wordpress
    rm wordpress-5.7.2.tar.gz
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    wp config create --dbname=${DATABASE_NAME} --dbuser=${DATABASE_USER} --dbpass=${DATABASE_USER_PASS} --dbhost=mariadb --path='/var/www/html'
    wp core install --url=${WP_DOMAIN} --title="Insaneption" --admin_user=${WP_ADMIN} --admin_password=${WP_ADMIN_PW} --admin_email=${WP_ADMIN_EMAIL} --path='/var/www/html'
    wp user create ${WP_USER} ${WP_USER_EMAIL} --user_pass=${WP_USER_PASS}
fi

php-fpm81 -F
