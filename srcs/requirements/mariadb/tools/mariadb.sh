#!/bin/sh

mysql_install_db
/etc/init.d/mysql start

if [ -d "/var/lib/mysql/$MYSQL_DATABASE" ]
then 
	echo "Database already exists"
else

# 1. yes, continue
# 2. pw
# 3. confirm pw
# 4. delete anonymous users
# 5. don't disable remote connections for user
# 6. remove test database
# 7. privilage tables should be reloaded to apply the changes
mysql_secure_installation << _EOF_

Y
secureaf
secureaf
Y
n
Y
Y
_EOF_

# Add a root user on 127.0.0.1 to be able to connect remotely 
# Flush privileges so tables can be updated automatically when you modify it
echo "GRANT ALL ON *.* TO 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;" | mysql -uroot

echo "CREATE DATABASE IF NOT EXISTS $MYSQL_DATABASE; GRANT ALL ON $MYSQL_DATABASE.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; FLUSH PRIVILEGES;" | mysql -u root

# Import database
mysql -uroot -p$MYSQL_ROOT_PASSWORD $MYSQL_DATABASE < /usr/local/bin/wordpress.sql

fi

/etc/init.d/mysql stop

exec "$@"