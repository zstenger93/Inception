FROM debian:bullseye

# Installing requirements
RUN apt-get update && apt-get install -y \
	mariadb-server \
	mariadb-client && \
	mkdir -p /run/mysqld && chown mysql:mysql /run/mysqld

EXPOSE 3306

ENV MYSQL_SOCKET=/var/run/mysqld/mysqld.sock

COPY requirements/mariadb/conf/mariadb.sh /mariadb.sh

RUN chmod +x mariadb.sh && bash mariadb.sh

ENTRYPOINT [ "/usr/local/bin/mariadb.sh" ]

# Launch and enable the listening globally for the database
CMD ["mysqld", "--bind-address=0.0.0.0"]