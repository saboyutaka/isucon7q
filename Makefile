.DEFAULT_GOAL := help

build: up bundle db-reset ## build develoment environment

serve: up attach ## Run Serve

up: ## Run web container
	docker-compose up -d web

attach: ## Attach running web container for binding.pry
	docker attach `docker ps -f name=isucon7q_web -f status=running --format "{{.ID}}"`

bundle: ## Run Bundle install
	docker-compose run --rm web bundle install

alp: ## Run alp
	 docker-compose run --rm alp -f access.log

mitmweb: ## Run mitmweb
	mitmweb --mode reverse:http://localhost:8888/ -p 80
	mitmdump -n -C flows.dms

replay: ## Run mitmdump

db-reset: _download_dbdump ## Reset DB
	docker-compose up -d db
	docker-compose exec db sh /var/tmp/wait.sh
	docker-compose exec db mysql -uroot -e 'drop database if exists isubata'
	docker-compose exec db mysql -uroot -e 'create database isubata'
	docker-compose exec db sh -c 'mysql -uroot isubata < /var/tmp/db.dump'

_download_dbdump: ## Download db.dump.tgz from Dropbox
	@if ! [ -f db/db.dump ];then curl -L -O -J 'https://www.dropbox.com/s/pbkxpnd2av9pjd7/db.dump?dl=0' && mv db.dump db; fi

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
