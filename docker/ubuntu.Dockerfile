#
# Ubuntu image for common settings and tools
#

FROM amd64/ubuntu:24.04

# set environment
ENV DEBIAN_FRONTEND=noninteractive

# install local certificates before the apt install to let ca-certificates pick them up
COPY ./tmp/certs /usr/local/share/ca-certificates

# install basic tools
RUN --mount=type=secret,id=ubuntu_sources \
	[ -s /run/secrets/ubuntu_sources ] \
	&& cp /run/secrets/ubuntu_sources /etc/apt/sources.list.d/ubuntu.sources \
	|| true \
	&& apt-get update && apt-get --yes upgrade && apt-get install --yes \
	bash-completion \
	ca-certificates \
	git \
	make \
	rsync \
&& apt-get autoremove --yes && apt-get clean --yes

# add user and group
ARG DOCKER_USER DOCKER_UID DOCKER_GID
ENV DOCKER_USER=${DOCKER_USER}
ENV DOCKER_UID=${DOCKER_UID}
ENV DOCKER_GID=${DOCKER_GID}
# The user is non-unique as we need 'docker' and 'tqemci' user
# with the same UID for gitlab-runner migration steps.
# The 'non-unique' option has to be removed afterwards.
# If UID/GID 1000 is already taken (e.g. by the default 'ubuntu' user in Ubuntu 24.04),
# remove that user and group before creating our own.
RUN existing_user=$(getent passwd ${DOCKER_UID} | cut -d: -f1); \
	[ -n "$existing_user" ] && userdel "$existing_user" || true; \
	existing_group=$(getent group ${DOCKER_GID} | cut -d: -f1); \
	[ -n "$existing_group" ] && groupdel "$existing_group" || true; \
	groupadd --gid ${DOCKER_GID} ${DOCKER_USER} \
	&& useradd --non-unique --create-home --shell /bin/bash \
		--uid ${DOCKER_UID} --gid ${DOCKER_GID} ${DOCKER_USER}
