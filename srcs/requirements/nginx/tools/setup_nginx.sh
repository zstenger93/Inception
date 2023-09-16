 # create the config and generate key and certificate

cat srcs/requirements/nginx/conf/nginx.conf > /etc/nginx/http.d/default.conf
openssl req -x509 -newkey rsa:4096 -keyout ${KEY_} -out ${CERT_} -sha256 -days 365 -nodes -subj "/CN="${DOMAIN_NAME}""
exec nginx -g "daemon off;"
