## [2.0.2] - 2025-08-18
### Added
- Move rsync install from yocto to ubuntu image
- shellcheck: Enable external sources and further options

### Fixed
- Fix build with 'docker compose'
- Add git to ubuntu container

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
