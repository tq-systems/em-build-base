# Copyright (c) 2024-2025 TQ-Systems GmbH <license@tq-group.com>
# D-82229 Seefeld, Germany. All rights reserved.
# Author:
#   Christoph Krutz

# Default string, if no docker registry is defined
LOCAL_BASE = local/em/base
BASE_REGISTRY_IMAGE ?= ${LOCAL_BASE}

# The if-clause also applies if an empty string is set in CI pipelines
ifeq ($(strip ${BUILD_TAG}),)
	BUILD_TAG := latest
endif

# The order results from the build dependencies between the images
IMAGE ?= docker ubuntu test yocto
COMPOSE_FILE ?= -f docker-compose.yml

# Additional docker compose build options may be set (e.g. --no-cache)
BUILD_ARGS ?=

# .env file is read by docker compose
DOCKER_COMPOSE_ENV = .env

DIR_USR_CERTS = /usr/local/share/ca-certificates
DIR_CERTS = certs

# Settings for the user in the docker container
DOCKER_USER ?= tqemci
DOCKER_UID ?= 1000
DOCKER_GID ?= 1000

export define DOCKER_COMPOSE_ENV_CONTENT
BASE_REGISTRY_IMAGE=${BASE_REGISTRY_IMAGE}
BUILD_TAG=${BUILD_TAG}
DOCKER_USER=${DOCKER_USER}
DOCKER_UID=${DOCKER_UID}
DOCKER_GID=${DOCKER_GID}
endef

DOCKER_COMPOSE := docker compose $(COMPOSE_FILE) build $(BUILD_ARGS)

all: prepare ${IMAGE}

# copy local certificates if existent
local-certs:
ifneq ("$(wildcard ${DIR_CERTS})","")
	$(info Use existing certificates in ${DIR_CERTS})
else
	mkdir -p ${DIR_CERTS}
	find ${DIR_USR_CERTS} -type f -name *.crt -exec cp {} ${DIR_CERTS} \;
endif

env:
ifneq ("$(wildcard ${DOCKER_COMPOSE_ENV})","")
	$(info Use existing ${DOCKER_COMPOSE_ENV})
else
	echo "$${DOCKER_COMPOSE_ENV_CONTENT}" > ${DOCKER_COMPOSE_ENV}
endif

prepare: env local-certs

docker: prepare
	${DOCKER_COMPOSE} docker

ubuntu: prepare
	${DOCKER_COMPOSE} ubuntu

test: ubuntu
	${DOCKER_COMPOSE} test

yocto: ubuntu
	${DOCKER_COMPOSE} yocto

push: env
ifeq (${BASE_REGISTRY_IMAGE}, ${LOCAL_BASE})
	$(error Prevent pushing to non-existing docker.io/${LOCAL_BASE})
endif
	docker compose ${COMPOSE_FILE} push ${IMAGE}

pull: env
	docker compose ${COMPOSE_FILE} pull ${IMAGE}

clean-files:
	rm -f ${DOCKER_COMPOSE_ENV}
	rm -rf ${DIR_CERTS}

clean-docker:
	docker system prune -f

clean: clean-files clean-docker

release: all
	$(MAKE) push
	$(MAKE) clean

update: clean-files
	$(MAKE) pull
	$(MAKE) clean

.PHONY: all \
	prepare env local-certs \
	push pull \
	clean-files clean-docker clean \
	release update
