#!/bin/sh

echo '
[www]
user = nobody
group = nobody
listen = 9000
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
' > /etc/php81/php-fpm.d/www.conf

if [ ! -f /var/www/html/wp-config.php ]; then
    curl -LO https://wordpress.org/wordpress-5.7.2.tar.gz
    tar -xvzf wordpress-5.7.2.tar.gz
    mv wordpress/* /var/www/html/
    rmdir wordpress
    rm wordpress-5.7.2.tar.gz
    curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
    chmod +x wp-cli.phar
    mv wp-cli.phar /usr/local/bin/wp
    wp config create --dbname=${MYSQL_PROBLEM} --dbuser=${MYSQL_USER_PROBLEM} --dbpass=${MYSQL_USER_PASSWORD_PROBLEM} --dbhost=mariadb --path='/var/www/html'
    wp core install --url=${DOMAIN_NAME} --title="PROBLEM" --admin_user=${WP_PROBLEM_ADMIN} --admin_password=${WP_PROBLEM_ADMIN_PASSWORD} --admin_email=${WP_PROBLEM_EMAIL} --path='/var/www/html'
    wp user create ${WP_NORMAL_PROBLEM} ${WP_NORMAL_PROBLEM_EMAIL} --user_pass=${WP_NORMAL_PROBLEM_PASS}
fi

php-fpm81 -F
