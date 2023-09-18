#!/bin/sh

echo '
[mysql]
default-character-set=utf8
[mysqld]
datadir = /var/lib/mysql
socket  = /var/run/mysqld/mysqld.sock
bind-address = 0.0.0.0
port = 3306
' > /usr/local/bin/my.cnf

cat > problem.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${MYSQL_PROBLEM};
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PROBLEM_PASSWORD}';
CREATE USER IF NOT EXISTS '${MYSQL_USER_PROBLEM}' IDENTIFIED BY '${MYSQL_USER_PASSWORD_PROBLEM}';
GRANT ALL PRIVILEGES ON ${MYSQL_PROBLEM}.* TO '${MYSQL_USER_PROBLEM}';
FLUSH PRIVILEGES;
EOF

exec mariadbd --no-defaults --user=root --datadir=/var/lib/mysql --init-file=/problem.sql
