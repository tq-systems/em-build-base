# Base CI
## Description
This project contains Gitlab CI/CD templates for all Energy Manager projects.
The templates here are generic and intended for all projects. They are not tied
to specific builds or artifacts. For example, rules are defined here that can
be used in every project. The docker tags of the base docker images are also
maintained here.

## Release
Typically, a release commit only updates the changelogs.

The release may or may not be accompanied by increasing the docker tag of the
base docker images. Setting the docker tag is typically done in a separate
commit and not in the release commit.
