COMPOSE    := docker compose -f srcs/docker-compose.yml

all: up

up: prepare
	$(COMPOSE) up -d --build

stop:
	$(COMPOSE) stop

prepare:
	mkdir -p $(HOME)/data/mariadb
	mkdir -p $(HOME)/data/wordpress
	echo "Data dirs ready under $(HOME)/data"

re: fclean all

clean: down
	$(COMPOSE) down

fclean: clean
	sudo rm -fr $(HOME)/data
	echo "Volumes data wiped."

.PHONY: all up prepare re clean fclean
