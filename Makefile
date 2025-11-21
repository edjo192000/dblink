.PHONY: help up down restart logs status clean test-mariadb test-oracle

help: ## Mostrar esta ayuda
	@echo "Comandos disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Iniciar los contenedores
	docker-compose up -d
	@echo ""
	@echo "Contenedores iniciados. Espera 2-3 minutos para que se configuren."
	@echo "Usa 'make logs' para ver el progreso."

down: ## Detener los contenedores
	docker-compose down

restart: ## Reiniciar los contenedores
	docker-compose restart

logs: ## Ver logs de todos los contenedores
	docker-compose logs -f

logs-oracle: ## Ver logs solo de Oracle
	docker logs -f oracle-xe-dblink

logs-mariadb: ## Ver logs solo de MariaDB
	docker logs -f mariadb-dblink

status: ## Ver estado de los contenedores
	docker-compose ps

clean: ## Detener y eliminar contenedores y volúmenes
	docker-compose down -v
	@echo "Contenedores y volúmenes eliminados"

test-mariadb: ## Conectarse a MariaDB
	docker exec -it mariadb-dblink mysql -u oracle_user -p12345 testdb

test-oracle: ## Conectarse a Oracle
	docker exec -it oracle-xe-dblink sqlplus system/12345@XE

test-dblink: ## Probar el DBLink desde Oracle
	@docker exec -it oracle-xe-dblink sqlplus -s system/12345@XE <<< "SELECT * FROM alumnos@mariadblk; EXIT;"

setup: ## Ejecutar configuración manual
	docker exec -it oracle-xe-dblink bash /opt/oracle/scripts/startup/00-wait-and-setup.sh

listener-status: ## Ver estado del listener de Oracle
	docker exec oracle-xe-dblink lsnrctl status
