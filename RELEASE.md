# Release Guide (AEM SDK Base Image)

This guide covers how to release a new **base** `docker-aem` SDK image when Adobe publishes a new SDK.

Scope:
- Base image branch only (for example: `sdk-2026.2.24464`)
- CIF and Forms packages are optional and maintained in separate branches

## 1. Prepare branch

1. Create or switch to the SDK branch:
   - `git checkout -b sdk-<sdk-version>`
2. Confirm the branch name matches the SDK version format used by this repo.

Example:
- `sdk-2026.2.24464`

## 2. Upload SDK quickstart and configure secret

1. Upload the SDK quickstart jar to Google Drive.
2. Add/update repository secret in GitHub for the SDK file ID (copy the file link and extract the ID from it).
3. Use an underscore-only secret name (recommended), for example:
   - `GOOGLE_DRIVEID_SDK_2026_2_24464`

Note:
- If a secret name includes dots, GitHub Actions requires bracket syntax (`secrets['...']`).
- To keep workflow expressions simple, prefer underscores in secret names.

## 3. Update workflow variables

Edit [.github/workflows/build.yml](.github/workflows/build.yml):

1. `GOOGLE_DRIVEID_AEM` -> point to the new SDK secret.
2. `DOCKER_IMAGE_VERSION` -> set the full SDK build version.
3. `GOOGLE_DRIVEID_AEM_VERSION` -> set the matching SDK quickstart filename/version.

Important:
- CIF and Forms variables are optional for the base image branch.
- Keep CIF/Forms package updates in their dedicated branches.

## 4. Update docs

Edit [README.md](README.md):

1. Update branch badge to the new SDK branch.
2. Update the "current SDK version branch" tag text.
3. Update example `docker run` tag to the new SDK branch tag.
4. Update release example/tag references.

## 5. Validate before tag

1. Commit and push the branch.
2. Wait for GitHub Actions `build` workflow to pass.
3. Verify test stage passes (Java version check and image test script).

Optional local checks:
- `docker build . -f Dockerfile -t aemdesign/aem:sdk-2026.2.24464`

## 6. Create release tag

After the branch pipeline is green:

1. Create tag:
   - `git tag sdk-<sdk-version>`
2. Push tag:
   - `git push origin sdk-<sdk-version>`

This triggers image publishing for the version tag.

## 7. Post-release verification

1. Confirm workflow run for tag completed successfully.
2. Confirm published images exist:
   - Docker Hub: `aemdesign/aem:sdk-<sdk-version>`
   - GHCR: `ghcr.io/aem-design/aem:sdk-<sdk-version>`
3. If this is the default branch release path, verify `latest` behavior is still correct.

## 8. Push parent submodule repo updates

This repository is a submodule:

1. Commit updated `docker-aem` submodule pointer in `aemdesign-docker`.
2. Commit updated `aemdesign-docker` pointer in `aemdesign-operations`.
3. Commit updated `aemdesign-operations` pointer in `aemdesign-parent`.
