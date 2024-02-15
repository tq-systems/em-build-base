#
# Image for linter jobs
#

ARG BASE_REGISTRY_IMAGE
ARG BASE_DOCKER_TAG
FROM ${BASE_REGISTRY_IMAGE}/ubuntu:${BASE_DOCKER_TAG}

# install linter tools
RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	pylint \
	shellcheck \
&& apt-get autoremove --yes && apt-get clean --yes

COPY ./docker/linter/lint.sh /usr/local/bin
