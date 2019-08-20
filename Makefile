DOCKER := docker
DOCKER_BUILD := $(DOCKER) build
# the memory flags are necessary to avoid the OOM killer during make -j
DOCKER_RUN := $(DOCKER) run
DOCKERFILE := Dockerfile
IMAGE_TAG := trinitycore

.PHONY: all
all: build

.PHONY: build
build:
	$(DOCKER_BUILD) -t $(IMAGE_TAG) .

.PHONY: run-debug
run-debug:
	$(DOCKER_RUN) -it --privileged --user=root $(IMAGE_TAG) dmesg -fkern -w

.PHONY: rm-images
rm-images:
	for IMAGE in $$(docker images -aq); do \
	    $(DOCKER) rmi -f $$IMAGE; \
	done

.PHONY: rm-containers
rm-containers:
	for CONT in $$(docker ps -aq); do \
	    $(DOCKER) rm -f $$CONT; \
	done

.PHONY: clean
clean: rm-images rm-containers

