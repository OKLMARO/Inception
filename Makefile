COMPOSE     := docker compose -f srcs/docker-compose.yml

all: up

up: prepare
	$(COMPOSE) up -d --build

prepare:
	@mkdir -p /home/oamairi/data/mariadb
	@mkdir -p /home/oamairi/data/wordpress
	@echo "Data dirs ready under /home/oamairi/data"

down:
	$(COMPOSE) down

stop:
	$(COMPOSE) stop

start:
	$(COMPOSE) start

re: down up

clean: down
	docker system prune -af

fclean: clean
	@sudo rm -rf /home/oamairi/data
	@echo "Volumes data wiped."

.PHONY: all up prepare down stop start re clean fclean
