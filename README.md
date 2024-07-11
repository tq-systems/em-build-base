# Base
## Description
This project creates base docker images that are used in the Gitlab CI/CD
pipelines of the Energy Manager project. The images created here are the basis
for other projects that also create docker images. These two levels of docker
projects are necessary to avoid redundant code. In addition, docker images are
created for very generic purposes that can be used in many projects.

## Release
Typically, a release commit only updates the changelogs. A release build is
triggered by pushing a tag.
