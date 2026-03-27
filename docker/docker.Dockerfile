#
# Image for building docker images
#

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# install Docker CLI and basic tools
RUN --mount=type=secret,id=ubuntu_sources \
	[ -s /run/secrets/ubuntu_sources ] \
	&& cp /run/secrets/ubuntu_sources /etc/apt/sources.list.d/ubuntu.sources \
	|| true \
	&& apt-get update && apt-get --yes upgrade && apt-get install --yes \
	ca-certificates \
	curl \
	gnupg \
	make \
&& install -m 0755 -d /etc/apt/keyrings \
&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
	-o /etc/apt/keyrings/docker.asc \
&& chmod a+r /etc/apt/keyrings/docker.asc \
&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
	https://download.docker.com/linux/ubuntu \
	$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
	> /etc/apt/sources.list.d/docker.list \
&& apt-get update \
&& apt-get install --yes docker-ce-cli docker-buildx-plugin docker-compose-plugin \
&& apt-get autoremove --yes && apt-get clean --yes

# install local certificates if existing
COPY ./tmp/certs /usr/local/share/ca-certificates
RUN update-ca-certificates
