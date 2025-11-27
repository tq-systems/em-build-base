#
# Image for test jobs
#

ARG BASE_REGISTRY
ARG BUILD_TAG
FROM zricethezav/gitleaks:v8.18.2 AS tool
FROM ${BASE_REGISTRY}/ubuntu:${BUILD_TAG}

# install test tools
RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	pylint \
	shellcheck \
	wget \
&& apt-get autoremove --yes && apt-get clean --yes

# install yq
RUN wget -qO /usr/local/bin/yq https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 && \
	chmod +x /usr/local/bin/yq

# copy gitleaks binary from official image
COPY --from=tool /usr/bin/gitleaks /usr/bin/

# add wrapper for pylint and shellcheck
COPY ./docker/linter/lint.sh /usr/local/bin
