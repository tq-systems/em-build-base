#
# Image for building docker images
#

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# copy local certificates before installing packages so that apt-get install
# ca-certificates picks them up via update-ca-certificates (dpkg trigger)
COPY ./tmp/certs /usr/local/share/ca-certificates

# install Docker CE (daemon + CLI) and basic tools
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
&& apt-get install --yes docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
&& apt-get autoremove --yes && apt-get clean --yes

# DinD entrypoint: start dockerd in background, wait for socket, then run the CI command
RUN printf '#!/bin/sh\ndockerd --host=unix:///var/run/docker.sock &\ntimeout 30 sh -c '"'"'until docker info >/dev/null 2>&1; do sleep 1; done'"'"'\nexec "$@"\n' \
    > /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sh"]
