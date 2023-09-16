FROM alpine:3.18
RUN apk add --no-cache php     && add --no-cache php-fpm     && add --no-cache php-mysqli     && add --no-cache mysql-client     && add --no-cache php-phar     && add --no-cache php-cgi     && add --no-cache php-fileinfo     && add --no-cache php-json     && add --no-cache php-iconv     && add --no-cache php-curl     && add --no-cache php-dom     && add --no-cache php-mbstring     && add --no-cache php-openssl     && add --no-cache php-xml     && add --no-cache php-tokenizer     && add --no-cache php-session     && add --no-cache php-exif     && add --no-cache curl     && add --no-cache tar 
WORKDIR /var/www/html
EXPOSE 9000
COPY tools/wp_setup.sh /wp_setup.sh
RUN chmod +x /wordpress_setup.sh
ENTRYPOINT ["/wordpress_setup.sh"]
