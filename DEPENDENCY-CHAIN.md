# Docker Dependency Chain and Update Process

This document describes how `docker-aem` depends on upstream images and how to safely roll updates through the chain.

## Chain Overview

Release order (bottom to top):

1. `aemdesign/oracle-jdk:jdk21`
2. `aemdesign/java-ffmpeg:jdk21`
3. `aemdesign/aem-base:jdk21`
4. `aemdesign/aem:sdk-<sdk-version>`

`docker-aem` is the final SDK image in this chain.

## Current Dependency Map

1. `docker-oracle-jdk`
   - Builds Oracle JDK runtime image.
2. `docker-java-ffmpeg`
   - `FROM aemdesign/oracle-jdk:jdk21`
   - Adds ffmpeg and media libraries.
3. `docker-aem-base`
   - `FROM aemdesign/java-ffmpeg:jdk21`
   - Adds AEM Forms/system libraries.
4. `docker-aem`
   - `FROM aemdesign/aem-base:jdk21`
   - Adds AEM SDK quickstart and startup config.

## Update Strategy

Always update and release in chain order.

1. Update `docker-oracle-jdk` and publish `jdk21`.
2. Update `docker-java-ffmpeg` to consume latest `oracle-jdk:jdk21`, then publish `jdk21`.
3. Update `docker-aem-base` to consume latest `java-ffmpeg:jdk21`, then publish `jdk21`.
4. Update `docker-aem` for new SDK branch/version and publish `sdk-<sdk-version>`.

Do not skip levels. Each level should build and pass tests before moving to the next.

## Branch and Tag Conventions

1. Runtime/base branches:
   - `jdk21` for `docker-oracle-jdk`, `docker-java-ffmpeg`, `docker-aem-base`.
2. AEM SDK branch:
   - `sdk-<sdk-version>` for `docker-aem` (example: `sdk-2026.2.24464`).
3. Release tags:
   - Runtime/base: semantic tag or release tag used by that repo.
   - AEM SDK: `sdk-<sdk-version>` tag.

## Standard Update Checklist

For each repo in the chain:

1. Update `Dockerfile` base image reference and Java verification labels.
2. Update CI workflow:
   - Ensure build step has `id: docker_build` if dive step uses `steps.docker_build.outputs.imageid`.
   - Ensure test step is enabled and validates Java version.
3. Update local scripts (`build.ps1`, `debug.ps1`) default tags.
4. Update README badge/branch/tag text.
5. Run local smoke checks:
   - `docker build ...`
   - `test/run_tests.sh ...`
6. Push branch and wait for GitHub Actions green.
7. Create and push release tag.
8. Confirm image exists in Docker Hub and GHCR.

## `docker-aem` Specific Notes

1. SDK quickstart comes from Google Drive secret (`GOOGLE_DRIVEID_AEM` in workflow).
2. CIF and Forms packages are optional and handled in separate branches.
3. Base SDK branch should not require CIF/Forms package downloads.
4. Full SDK release runbook is in `RELEASE.md`.

## Verification Commands

Example checks after publishing:

```bash
docker pull aemdesign/oracle-jdk:jdk21
docker pull aemdesign/java-ffmpeg:jdk21
docker pull aemdesign/aem-base:jdk21
docker pull aemdesign/aem:sdk-<sdk-version>
```

```bash
docker run --rm aemdesign/oracle-jdk:jdk21 java --version
docker run --rm aemdesign/java-ffmpeg:jdk21 java --version
docker run --rm aemdesign/aem-base:jdk21 java --version
docker run --rm aemdesign/aem:sdk-<sdk-version> java --version
```
