#
# Image for linter jobs
#

ARG BASE_REGISTRY_IMAGE
ARG BASE_DOCKER_TAG
FROM zricethezav/gitleaks:v8.18.2 AS tool
FROM ${BASE_REGISTRY_IMAGE}/ubuntu:${BASE_DOCKER_TAG}

# install linter tools
RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	git \
&& apt-get autoremove --yes && apt-get clean --yes

# copy gitleaks binary from official image
COPY --from=tool /usr/bin/gitleaks /usr/bin/
