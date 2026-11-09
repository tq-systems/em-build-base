#
# Image for test jobs
#

ARG BASE_REGISTRY
ARG BUILD_TAG
ARG GITLEAKS_VERSION=8.30.1
FROM zricethezav/gitleaks:v${GITLEAKS_VERSION} AS tool
FROM ${BASE_REGISTRY}/ubuntu:${BUILD_TAG}

# install test tools
RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	pylint \
	python3-pytest \
	shellcheck \
	wget \
&& apt-get autoremove --yes && apt-get clean --yes

# install yq
ARG YQ_VERSION=4.53.6
RUN wget -qO /usr/local/bin/yq \
	https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64 && \
	chmod +x /usr/local/bin/yq

# copy gitleaks binary from official image
COPY --from=tool /usr/bin/gitleaks /usr/bin/

# add wrapper for pylint and shellcheck
COPY ./docker/linter/lint.sh /usr/local/bin

# Hand-installed tools carry no package metadata, so their versions are exposed as
# labels and can be read back from the built image
ARG GITLEAKS_VERSION
LABEL tqem.tool.gitleaks="${GITLEAKS_VERSION}" \
	tqem.tool.yq="${YQ_VERSION}"
