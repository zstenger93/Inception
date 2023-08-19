FROM debian:bookworm

# Installing requirements
RUN apt-get update && apt-get install \
	php \
	php-cgi \
	php-mysql \
	php-fpm \
	php-pdo \
	php-gd php-cli \
	php-mbstring \
	wget \
	curl \
	bash

EXPOSE 6666

# ignore daemon and launch in the foreground
CMD ["/usr/sbin/php-fpm7.3", "-F"]