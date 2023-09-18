FROM alpine:3.18
RUN apk add nginx
RUN apk add openssl
COPY tools/cert.sh .
ENTRYPOINT ["sh", "cert.sh"]
