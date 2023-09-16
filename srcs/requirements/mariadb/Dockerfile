FROM alpine:3.18
RUN apk add mysql 
RUN apk add mysql-client
RUN mkdir -p /run/mysqld
RUN mkdir -p /var/lib/mysql
RUN mariadb-install-db --user=root --datadir=/var/lib/mysql --skip-test-db
EXPOSE 3306
ENTRYPOINT ["sh", "tools/create_database.sh"]
