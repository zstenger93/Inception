FROM debian:bookworm

# Installing requirements
RUN apt-get update && apt-get isntall -y \
	nginx \
	openssl

# Only port allowed by the subject pdf
EXPOSE 443

# alunch
CMD ["nginx", "-g", "daemon off;"]