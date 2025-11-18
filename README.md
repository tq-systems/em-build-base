# Base Docker Images for TQ Energy Manager

## Description
This project creates base Docker images that are used in the GitLab CI/CD pipelines of the Energy Manager project. The images created here serve as the foundation for other projects that also create Docker images. This two-level Docker architecture is necessary to avoid redundant code and provides generic Docker images that can be used across multiple projects.

This project also contains GitLab CI/CD templates associated with the Docker images. These templates are generic and intended for all projects, providing reusable CI/CD components that are not tied to specific builds or artifacts.

## Docker Images

The project builds four specialized Docker images:

### 1. **ubuntu** (`${BASE_REGISTRY}/ubuntu:${BUILD_TAG}`)
- **Base**: Ubuntu 22.04 (amd64)
- **Purpose**: Common base image with essential tools and TQ-specific configurations
- **Includes**:
  - Basic tools: `ca-certificates`, `git`, `make`, `rsync`
  - TQ-EM shell library (v1.0.0)
  - Custom user configuration with configurable UID/GID
  - Local certificate support
- **Dependencies**: None (base image)

### 2. **docker** (`${BASE_REGISTRY}/docker:${BUILD_TAG}`)
- **Base**: cruizba/ubuntu-dind:jammy-25.0.1
- **Purpose**: Docker-in-Docker image for building other Docker images
- **Includes**:
  - Docker daemon and CLI tools
  - `make` for build automation
  - Local certificate support
- **Dependencies**: None (independent base)

### 3. **test** (`${BASE_REGISTRY}/test:${BUILD_TAG}`)
- **Base**: ubuntu image (from this project)
- **Purpose**: Code quality and security testing
- **Includes**:
  - `pylint` for Python code analysis
  - `shellcheck` for shell script analysis
  - `gitleaks` for secret detection (v8.18.2)
  - `lint.sh` wrapper script for automated linting
- **Dependencies**: ubuntu image must be built first

### 4. **yocto** (`${BASE_REGISTRY}/yocto:${BUILD_TAG}`)
- **Base**: ubuntu image (from this project)
- **Purpose**: Yocto/embedded Linux development
- **Includes**:
  - All Yocto Project required dependencies
  - Development tools: `build-essential`, `python3-*` packages
  - Utilities: `jq`, `rsync`, `wget`, `git`
  - Locale support (en_US.UTF-8)
- **Dependencies**: ubuntu image must be built first

## Quick Start

### Prerequisites
- Docker installed
- Make utility
- Access to the container registry (for pushing)

### Building Images Locally

```bash
# Build all images with default settings
make all

# Build specific images
make ubuntu         # Build only ubuntu image
make test           # Build ubuntu + test images
make yocto          # Build ubuntu + yocto images
make docker         # Build only docker image
```

### Configuration

#### Environment Variables
The build process can be customized using these variables:

```bash
# Docker registry settings
export BASE_REGISTRY="your-registry.com/project" # Default: local/em/base
export BUILD_TAG="v2.0.2"                        # Default: latest

# Container user settings
export DOCKER_USER="myuser"                      # Default: tqemci
export DOCKER_UID="1001"                         # Default: 1000
export DOCKER_GID="1001"                         # Default: 1000

# Build options
export BUILD_ARGS="--no-cache"                   # Additional docker compose args
```

#### Local Certificates
Place custom certificates in the `certs/` directory. They will be automatically copied to `/usr/local/share/ca-certificates` in all images.

### Advanced Usage

#### Custom Registry
```bash
# Build and push to custom registry
make BASE_REGISTRY=my-registry.com/em/base BUILD_TAG=v1.0.0 release
```

#### Development Workflow
```bash
# Pull latest images from registry
make update

# Clean local environment
make clean

# Build and test locally
make all
```

#### Linting Tools Usage
The test image includes a unified linting wrapper:

```bash
# In a container based on the test image
lint.sh shell                    # Lint all *.sh files
lint.sh python                   # Lint all *.py files
lint.sh shell -f script.sh       # Lint specific file
lint.sh python -d src/           # Lint files in directory
```

## Build Dependencies

The images have the following build order due to dependencies:
1. `docker` (independent)
2. `ubuntu` (independent)
3. `test` (requires ubuntu)
4. `yocto` (requires ubuntu)

## Available Make Targets

| Target         | Description                        |
|----------------|------------------------------------|
| `all`          | Build all images (default)         |
| `prepare`      | Setup environment and certificates |
| `docker`       | Build docker image only            |
| `ubuntu`       | Build ubuntu image only            |
| `test`         | Build ubuntu + test images         |
| `yocto`        | Build ubuntu + yocto images        |
| `push`         | Push images to registry            |
| `pull`         | Pull images from registry          |
| `release`      | Build all + push + clean           |
| `update`       | Pull latest + clean                |
| `clean`        | Clean files and Docker system      |
| `clean-files`  | Remove .env and certs/             |
| `clean-docker` | Run docker system prune            |

## License Information
All files in this project are classified as product-specific software and bound to the use with the TQ-Systems GmbH product: EM400

    SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3

## Release Process
Releases are managed through git tags and automated CI/CD:

1. Update `CHANGELOG.md` with new version information
2. Update the `BASE_DOCKER_TAG` in `ci/images.yml` if needed
3. Create and push a git tag (e.g., `v2.0.3`)
4. The CI pipeline automatically builds and pushes tagged images
5. Release images use fixed tags for reproducible builds

The CI ensures that:
- Development builds use `latest` tag for testing
- Tagged releases use the specific version tag
- Release builds are only triggered on the default branch or tags
