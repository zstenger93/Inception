FROM alpine:3.18
RUN apk add nginx
RUN apk add openssl
ENTRYPOINT ["sh", "tools/setup_nginx.sh"]
