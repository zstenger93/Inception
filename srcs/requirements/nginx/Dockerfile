FROM debian:buster

	RUN apt-get update && apt-get upgrade 		&& apt-get install -y nginx openssl

	ARG NGINX_DOMAIN

	RUN mkdir -p "/etc/cert/$NGINX_DOMAIN" && 		mkdir -p /var/run/nginx && 		chown -R www-data:www-data /var/run/nginx

	RUN openssl req -x509 -newkey rsa:4096 -keyout "/etc/cert/$NGINX_DOMAIN/key.pem" -out "/etc/cert/$NGINX_DOMAIN/cert.pem" -sha256 -days 365 -nodes -subj "/CN=$NGINX_DOMAIN"

	COPY ./nginx.conf /etc/nginx/nginx.conf
	COPY ./wordpress.conf "/etc/nginx/conf.d/$NGINX_DOMAIN.conf"
	COPY ./adminer.conf "/etc/nginx/conf.d/adminer.$NGINX_DOMAIN.conf"

	RUN sed -i "s/$NGINX_DOMAIN/$NGINX_DOMAIN/g" /etc/nginx/conf.d/*

	CMD ["nginx", "-g", "daemon off;"]
