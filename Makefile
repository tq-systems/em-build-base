# Copyright (c) 2024 TQ-Systems GmbH <license@tq-group.com>
# D-82229 Seefeld, Germany. All rights reserved.
# Author:
#   Christoph Krutz

# Default string, if no docker registry is defined
LOCAL_BASE = local/em/base

# The order results from the build dependencies between the images
ALL_IMAGES ?= docker ubuntu linter yocto gitleaks
COMPOSE_FILE ?= -f docker-compose.yml

IMAGE ?= ${ALL_IMAGES}

# Support gitlab environment variables if existent
ifdef CI_REGISTRY_IMAGE
BASE_REGISTRY_IMAGE = ${CI_REGISTRY_IMAGE}
endif
BASE_REGISTRY_IMAGE ?= ${LOCAL_BASE}

ifdef CI_COMMIT_TAG
BASE_DOCKER_TAG = ${CI_COMMIT_TAG}
endif
BASE_DOCKER_TAG ?= latest

# Additional docker-compose build options may be set (e.g. --no-cache)
BUILD_ARGS ?=

# .env file is read by docker-compose
DOCKER_COMPOSE_ENV = .env

DIR_USR_CERTS = /usr/local/share/ca-certificates
DIR_CERTS = certs

# Settings for the user in the docker container
DOCKER_USER ?= tqemci
DOCKER_UID ?= 1000
DOCKER_GID ?= 1000

export define DOCKER_COMPOSE_ENV_CONTENT
BASE_REGISTRY_IMAGE=${BASE_REGISTRY_IMAGE}
BASE_DOCKER_TAG=${BASE_DOCKER_TAG}
DOCKER_USER=${DOCKER_USER}
DOCKER_UID=${DOCKER_UID}
DOCKER_GID=${DOCKER_GID}
endef

# copy local certificates if existent
local-certs:
	mkdir -p ${DIR_CERTS}
	find ${DIR_USR_CERTS} -type f -name *.crt -exec cp {} ${DIR_CERTS} \;

prepare: local-certs
ifneq ("$(wildcard ${DOCKER_COMPOSE_ENV})","")
	$(info Using existing ${DOCKER_COMPOSE_ENV}.)
else
	echo "$${DOCKER_COMPOSE_ENV_CONTENT}" > ${DOCKER_COMPOSE_ENV}
endif

all: prepare
	docker-compose ${COMPOSE_FILE} build ${BUILD_ARGS} ${IMAGE}

push: prepare
ifeq (${BASE_REGISTRY_IMAGE}, ${LOCAL_BASE})
	$(error Prevent pushing to non-existing docker.io/${LOCAL_BASE}, exit.)
endif
	docker-compose ${COMPOSE_FILE} push ${IMAGE}

pull: prepare
	docker-compose ${COMPOSE_FILE} pull ${IMAGE}

clean-files:
	rm -f ${DOCKER_COMPOSE_ENV}
	rm -rf ${DIR_CERTS}

clean-docker:
	docker system prune -f

clean: clean-files clean-docker

release: all push clean

update: clean-files pull clean

.NOTPARALLEL: release update

.PHONY: prepare all push pull \
	clean-files clean-docker clean \
	release update
