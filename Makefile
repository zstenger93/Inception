DOCKER-COMPOSE_FILE = docker-compose -f ./srcs/docker-compose.yml

# make makefile great again

creationcatalyst:
	chmod +x CreationCatalyst.sh
	./CreationCatalyst.sh

build:
	@echo "docker-compose Inception"
	cd srcs/
	$(DOCKER-COMPOSE_FILE) build

run:
	@echo "Starting Inception"
	$(DOCKER-COMPOSE_FILE) up -d

stop:
	@$(DOCKER-COMPOSE_FILE) stop

down:
	@echo "Taking inception down"
	$(DOCKER-COMPOSE_FILE) down

re:
	@echo "Rebuilding inception"
	make down
	make build
	make run

db:
	docker exec -it mariadb mysql -u sh

clean:
	docker stop $$(docker ps -aq);\
	docker rm $$(docker ps -aq);\
	docker rmi -f $$(docker images -qa);\
	docker volume rm $$(docker volume ls -q);\
	docker network rm $$(docker network ls -q);\

fclean:
	rm -rf srcs/
	rm template.sh

.PHONY: build run down re clean stop creationcatalyst