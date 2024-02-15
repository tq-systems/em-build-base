#
# Ubuntu image for common settings and tools
#

FROM amd64/ubuntu:22.04

# set environment
ENV DEBIAN_FRONTEND=noninteractive

# install basic tools
RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	ca-certificates \
	make \
&& apt-get autoremove --yes && apt-get clean --yes

# add user and group
ARG DOCKER_USER DOCKER_UID DOCKER_GID
ENV DOCKER_USER=${DOCKER_USER}
ENV DOCKER_UID=${DOCKER_UID}
ENV DOCKER_GID=${DOCKER_GID}
RUN groupadd --gid ${DOCKER_GID} ${DOCKER_USER} \
	&& useradd --create-home --shell /bin/bash \
		--uid ${DOCKER_UID} --gid ${DOCKER_GID} ${DOCKER_USER}

# install local certificates if existing
COPY ./certs /usr/local/share/ca-certificates
RUN update-ca-certificates
