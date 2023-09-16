#!/bin/sh

cat srcs/requirements/mariadb/conf/mariadb.conf > /usr/local/bin/my.cnf

cat > srcs/requirements/mariadb/database.sql <<EOF
CREATE DATABASE IF NOT EXISTS ${DB_NAME};
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_ROOT}';
CREATE USER IF NOT EXISTS '' IDENTIFIED BY '';
GRANT ALL PRIVILEGES ON .* TO '';
FLUSH PRIVILEGES;
EOF

exec mariadbd --no-defaults --user=root --datadir=/var/lib/mysql --init-file=/problem.sql
