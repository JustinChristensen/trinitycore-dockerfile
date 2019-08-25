.PHONY: all
all: authserver worldserver

.PHONY: base
base:
	docker build -t trinitycore-base base

.PHONY: authserver
authserver: base
	docker build -t trinitycore-authserver authserver

.PHONY: worldserver
worldserver: base
	docker build -t trinitycore-worldserver worldserver

.PHONY: start
start:
	./start.sh

.PHONY: maintainer-clean
maintainer-clean:
	docker system prune -f --all
	docker volume prune -f
