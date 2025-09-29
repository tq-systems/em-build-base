#
# Image for building docker images
#

FROM cruizba/ubuntu-dind:jammy-25.0.1

# install basic tools
RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	make \
&& apt-get autoremove --yes && apt-get clean --yes

# install local certificates
COPY ./certs /usr/local/share/ca-certificates
RUN update-ca-certificates
