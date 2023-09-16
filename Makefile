DOCKER-COMPOSE_FILE = docker-compose -f ./srcs/docker-compose.yml

ENV_FILE = srcs/.env

include $(ENV_FILE)
export

# make makefile great again

creationcatalyst:
	chmod +x CreationCatalyst.sh
	./CreationCatalyst.sh

build:
	@echo "docker-compose Inception"
	chmod +x srcs/requirements/tools/initialize.sh
	./srcs/requirements/tools/initialize.sh
	$(DOCKER-COMPOSE_FILE) build

run:
	@echo "Starting Inception"
	$(DOCKER-COMPOSE_FILE) up -d

down:
	@echo "Taking inception down"
	$(DOCKER-COMPOSE_FILE) down

re:
	@echo "Rebuilding inception"
	make down
	make build
	make run

clean:
	docker stop $$(docker ps -aq);\
	docker rm $$(docker ps -aq);\
	docker rmi -f $$(docker images -qa);\
	docker volume rm $$(docker volume ls -q);\
	docker network rm $$(docker network ls -q);\

.PHONY: build run down re clean creationcatalyst