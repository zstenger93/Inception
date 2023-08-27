FROM debian:bullseye

# Installing requirements and creating crt + key
RUN apt-get update && apt-get isntall -y \
	nginx \
	openssl && \
	mkdir /etc/nginx/ssl && openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -out /etc/nginx/ssl/zstenger.crt \
    -keyout /etc/nginx/ssl/zstenger.key

COPY ./conf/nginx.conf /etc/nginx/conf.d

# nginx config
RUN mkdir -p /run/nginx

# Only port allowed by the subject pdf
EXPOSE 443

# alunch
CMD ["nginx", "-g", "daemon off;"]