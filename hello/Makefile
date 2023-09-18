DOCKER_COMPOSE = docker-compose
COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
# DIRS := ./problem_files ./problem_db

include $(ENV_FILE)
export

build:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) build
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d

#start:
#	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) up -d

# dirs:
# 	@for dir in $(DIRS); do \
# 	  [ -d $$dir ] || mkdir -p $$dir ; \
# 	done

stop:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) stop

clean: stop
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) stop
	@docker system prune -a

fclean:
	@$(DOCKER_COMPOSE) -f $(COMPOSE_FILE) stop
	@docker stop $$(docker ps -aq) || true
	@docker system prune --all --force --volumes
	@docker network prune --force
	@docker volume prune --forceshould not do that in eval

re: stop build

rebuild: build

all: build

ps:
	docker ps

db:
	@docker exec -it mariadb mysql -u sh

delete_data:
	@docker volume rm srcs_problem-db
	@docker volume rm srcs_problem-files



env:
	@bash setupEnv.sh

help:
	@echo "\033[1;32mThe Makefile guide:\033[0m"
	@echo "\033[1;90mbuild: Compiles the project\033[0m"
	@echo "\033[1;32mstart: Well starts the bloody project\033[0m"
	@echo "\033[1;90mstop: Stops the docker files, obviously\033[0m"
	@echo "\033[1;32mThere was a command but I am too lasy to remove it: Builds and starts the docker file\033[0m"
	@echo "\033[1;90mclean: Cleans up the project\033[0m"
	@echo "\033[1;32mfclean: Completely stops the project\033[0m"
	@echo "\033[1;90mre: Stop, build, and start\033[0m"
	@echo "\033[1;32mdb: access the bloody db\033[0m"
	@echo "\033[1;90mps: just docker ps\033[0m"
	@echo "\033[1;32mdelete_data: deletes all stored data - should not do without reason\033[0m"
	@echo "\033[1;90mdirs: helper function on make to create directories for data storage for backup\033[0m"
	@echo "\033[1;32menv: helper function on make to create directories for data storage for backup\033[0m"
	@echo "\033[1;90mhelp: just help\033[0m"


.PHONY: build start rebuild stop re fclean clean all logs log db delete_data help env
