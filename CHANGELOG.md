## [3.1.1] - 2026-06-05
### Added
- ci: Add .docker-build template with a dedicated runner
- lint_test.sh: unittest file for lint.sh

### Changed
- lint.sh: improved argument handling when targeting a specific file
- lint.sh: added FIND_IGNORE_PATHS variable for paths to be ignored in default and -d mode

## [3.1.0] - 2026-05-18
### Added
- ci: Add .docker-build template with a dedicated runner

## [3.0.2] - 2026-05-15
### Fixed
- ci/images.yml: bump BASE_DOCKER_TAG to v3.0.2 so the tag-build pipeline check passes

## [3.0.1] - 2026-05-15
### Fixed
- docker image: move COPY of local CA certificates before package installation so that curl trusts the TQ corporate CA when fetching the Docker GPG key

## [3.0.0] - 2026-05-04
### Changed
- rules.yml: Remove obsolete merge request cases
- yocto: add pigz tool
- Add TQEM_APT_UBUNTU_SOURCES variable to provide a custom DEB822-formatted apt sources file at
  build time. Without the variable the base image apt configuration is used unchanged.
- Update base images from Ubuntu 22.04 to Ubuntu 24.04
- yocto image: replace deprecated libsdl1.2-dev with libsdl2-dev and libegl1-mesa with libegl-dev
- ci: improve MR pipeline isolation

## [2.1.1] - 2026-03-16
### Fixed
- shell test uses a released image

## [2.1.0] - 2026-03-16
### Added
- ci: Add artifacts templates
- ubuntu: Add bash-completion

### Changed
- ubuntu: Update shell library to 2.0.0 in ubuntu image
- docker: Update dind to 29.1.4

### Fixed
- ci/rules.yml: Allow bundle integration tests to run in triggered (downstream) pipelines

## [2.0.3] - 2025-09-29
### Added
- Rules for Long Term Tests
- TQ-EM shell library installation in the ubuntu image
- CI rules: added combined skip rule for alpha/long-term tests and extended include rules to respect ALPHA_BUILD

### Changed
- Switch to the more permissive TQSPSLA-1.0.3 license
- Remove docker-compose from docker image

### Fixed
- Remove git from test image

## [2.0.2] - 2025-08-18
### Added
- Move rsync install from yocto to ubuntu image
- shellcheck: Enable external sources and further options

### Fixed
- Fix build with 'docker compose'
- add git to ubuntu container

## [2.0.1] - 2025-07-10
### Added
- Check default branch for 'latest' image tag

### Fixed
- Fix image definition for checking the docker tag

## [2.0.0] - 2025-07-10
### Added
- Add base-ci code to the base project to handle their interdependence in one project
- Add the gitleaks job

### Changed
- Merge gitleaks and linter images to the test image
- Ensure that tagged pipelines only run on docker images with a fixed tag

## [1.0.5] - 2025-07-01
### Changed
- Remove bitbake AppArmor profile again

## [v1.0.4] - 2025-05-27
### Changed
- Move etc directory addition to ubuntu container

## [v1.0.3] - 2025-05-27
### Added
- Add jq to yocto image
- Add apparmor profile for bitbake (ubuntu 24.04)

## [v1.0.2] - 2024-07-12
### Changed
- Updated documentation

## [v1.0.1] - 2024-05-17
### Changed
- Create non-unique user

### Added
- Merge request template

## [v1.0.0] - 2024-04-26
