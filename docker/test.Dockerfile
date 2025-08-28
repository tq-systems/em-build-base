#
# Image for test jobs
#

ARG BASE_REGISTRY_IMAGE
ARG BUILD_TAG
FROM zricethezav/gitleaks:v8.18.2 AS tool
FROM ${BASE_REGISTRY_IMAGE}/ubuntu:${BUILD_TAG}

# install test tools
RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	pylint \
	shellcheck \
&& apt-get autoremove --yes && apt-get clean --yes

# copy gitleaks binary from official image
COPY --from=tool /usr/bin/gitleaks /usr/bin/

# add wrapper for pylint and shellcheck
COPY ./docker/linter/lint.sh /usr/local/bin
