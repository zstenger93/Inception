FROM debian:bullseye

# Installing requirements
RUN apt-get update && apt-get install \
	php \
	php-cgi \
	php-mysql \
	php-fpm \
	php-pdo \
	php-gd php-cli \
	php-mbstring \
	bash \
	wget \
	curl

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/create_wordpress.sh"]

# Ignore daemon and launch in the foreground
CMD ["/usr/sbin/php-fpm7.3", "-F"]
