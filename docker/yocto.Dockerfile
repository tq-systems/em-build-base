#
# Image for yocto builds
#

ARG BASE_REGISTRY
ARG BUILD_TAG
FROM ${BASE_REGISTRY}/ubuntu:${BUILD_TAG}

# https://docs.yoctoproject.org/4.0.15/ref-manual/system-requirements.html#supported-linux-distributions
# Adaptions:
# - changed pylint3 to pylint
# - add missing file
# - add locales for en_US.UTF-8 support

RUN apt-get update && apt-get --yes upgrade && apt-get install --yes \
	gawk wget git diffstat unzip texinfo gcc build-essential chrpath socat cpio python3 python3-pip python3-pexpect xz-utils debianutils iputils-ping python3-git python3-jinja2 libegl1-mesa libsdl1.2-dev pylint xterm python3-subunit mesa-common-dev zstd liblz4-tool \
	file \
	locales \
	jq \
&& apt-get autoremove --yes && apt-get clean --yes

RUN locale-gen "en_US.UTF-8"
