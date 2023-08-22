FROM debian:bullseye

# Installing requirements
RUN apt-get update && apt-get install -y \
	mariadb-server \
	mariadb-client \
	vim

EXPOSE 3333

ENTRYPOINT [ "/usr/local/bin/mariadb.sh" ]

# Launch and enable the listening globally for the database
CMD ["mysqld", "--bind-address=0.0.0.0"]