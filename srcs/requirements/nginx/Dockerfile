FROM debian:bookworm

# Installing requirements
RUN apt-get update && apt-get isntall -y \
	nginx \
	openssl

# only port allowed by the subject pdf
EXPOSE 443

# alunch
CMD ["nginx", "-g", "daemon off;"]