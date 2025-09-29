# Base
## Description
This project creates base Docker images that are used in the Gitlab CI/CD
pipelines of the Energy Manager project. The images created here are the basis
for other projects that also create Docker images. These two levels of Docker
projects are necessary to avoid redundant code. In addition, Docker images are
created for very generic purposes that can be used in many projects.

This project also contains Gitlab CI/CD templates associated with the Docker
images. The templates here are generic and intended for all projects. They are
not tied to specific builds or artifacts. For example, rules are defined here
that can be used in every project.

## License information
All files in this project are classified as product-specific software
and bound to the use with the TQ-Systems GmbH product: EM400

    SPDX-License-Identifier: LicenseRef-TQSPSLA-1.0.3

## Release
Typically, a release commit updates the changelogs and the base docker tag in
the `ci/images.yml` file. A release build is triggered by pushing a tag.
