FROM alpine:3.18
RUN apk add --no-cache php 
RUN apk add --no-cache php-fpm 
RUN apk add --no-cache php-mysqli 
RUN apk add --no-cache mysql-client 
RUN apk add --no-cache php-phar 
RUN apk add --no-cache php-cgi 
RUN apk add --no-cache php-fileinfo
RUN apk add --no-cache php-json
RUN apk add --no-cache php-iconv
RUN apk add --no-cache php-curl 
RUN apk add --no-cache php-dom
RUN apk add --no-cache php-mbstring
RUN apk add --no-cache php-openssl
RUN apk add --no-cache php-xml
RUN apk add --no-cache php-tokenizer
RUN apk add --no-cache php-session
RUN apk add --no-cache php-exif
RUN apk add --no-cache curl
RUN apk add --no-cache tar
WORKDIR /var/www/html
EXPOSE 9000
COPY tools/wp_setup.sh /wp_setup.sh
RUN chmod +x /wp_setup.sh
ENTRYPOINT ["/wp_setup.sh"]