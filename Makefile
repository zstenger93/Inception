SHELL := /bin/bash

all:
	@echo "docker-compose Inception"
	chmod +x srcs/requirements/tools/initialize.sh
	./srcs/requirements/tools/initialize.sh
	docker compose -f ./scrs/docker-compose.yml up -d --build

down:
	@echo "Taking inception down"
	docker compose -f ./scrs/docker-compose.yml down

re:
	@echo "Rebuilding inception"
	docker compose -f scrs/docker-compose.yml up -d --build

clean:
	docker stop $$(docker ps -qa);\
	docker rm $$(docker ps -qa);\
	docker rmi -f $$(docker images -qa);\
	docker volume rm $$(docker volume ls -q);\
	docker network rm $$(docker network ls -q);\

.PHONY: all re down clean