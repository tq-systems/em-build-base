#!/bin/bash
# Copyright (c) 2026 TQ-Systems GmbH

set -e

VERSION="$1"
IMAGES_FILE="ci/images.yml"

set_base_docker_tag() {
	local docker_tag="v${1}"
	sed -i "s/^\(  BASE_DOCKER_TAG: '\)[^']*'/\1${docker_tag}'/" "$IMAGES_FILE"
}

set_base_docker_tag "$VERSION"
git add "$IMAGES_FILE"
