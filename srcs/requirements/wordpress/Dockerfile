FROM alpine:3.18
RUN apk add --no-cache php \
    --no-cache php-fpm \
    --no-cache php-mysqli \
    --no-cache mysql-client \
    --no-cache php-phar \
    --no-cache php-cgi \
    --no-cache php-fileinfo \
    --no-cache php-json \
    --no-cache php-iconv \
    --no-cache php-curl \
    --no-cache php-dom \
    --no-cache php-mbstring \
    --no-cache php-openssl \
    --no-cache php-xml \
    --no-cache php-tokenizer \
    --no-cache php-session \
    --no-cache php-exif \
    --no-cache curl \
    --no-cache tar 
WORKDIR /var/www/html
EXPOSE 9000
ENTRYPOINT ["tools/wordpress_setup.sh"]
