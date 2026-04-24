#
# Image for building docker images
#

FROM cruizba/ubuntu-dind:jammy-29.1.4

# install basic tools
RUN --mount=type=secret,id=ubuntu_sources \
	[ -s /run/secrets/ubuntu_sources ] \
	&& cp /run/secrets/ubuntu_sources /etc/apt/sources.list.d/ubuntu.sources \
	|| true \
	&& apt-get update && apt-get --yes upgrade && apt-get install --yes \
	make \
&& apt-get autoremove --yes && apt-get clean --yes

# install local certificates
COPY ./tmp/certs /usr/local/share/ca-certificates
RUN update-ca-certificates
