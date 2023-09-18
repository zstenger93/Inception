#!/bin/sh

## port to listen
## server_name
## tokens
## protocols
## index files to read
## basic page in case of error also 404 error if files not found
## reading from wordpress PORT:9000

echo '
server {
    listen 443 ssl;
    server_name '"$DOMAIN_NAME"';
    
    
    ssl_certificate '"$CERT_"';
    ssl_certificate_key '"$KEY_"';
    ssl_protocols TLSv1.2 TLSv1.3;
    
    root /var/www/html;
    index index.php index.html index.htm;
    
    location / {
		try_files $uri $uri/ =404;
		autoindex on;
	}

	location ~ \.php$ {
		try_files $uri =404;
		fastcgi_pass wordpress:9000;
		fastcgi_index index.php;
		fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
		include fastcgi_params;
	}
}
' > /etc/nginx/http.d/default.conf

## Generation of SSL certificates

openssl req -x509 -newkey rsa:4096 -keyout ${KEY_} -out ${CERT_} -sha256 -days 365 -nodes -subj "/CN="${DOMAIN_NAME}""
## of nginx
exec nginx -g "daemon off;"
