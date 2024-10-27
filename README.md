# Trivy Bundles

This repository creates a bundled Aquasec Trivy image with a timestamped database.

This repository mainly uses Makefile targets to perform the required actions.
Run `make help` to discover all of them.

## Set the matching Trivy Version

|DKP/NKP Version |Trivy Version|
|-|-|
|NKP 2.12.x|0.53.0|
|DKP 2.8.x|0.49.1|
|DKP 2.7.x|0.45.1|
|DKP 2.6.x|0.42.1|

```bash
export TRIVY_VERSION=<version matching Insights Release above>
```

## Override Registry and Repository

Override the default registry and repository values, by setting the following env-vars:

```bash
export REGISTRY=docker.io
export REPOSITORY=foo-org
```

## Create an airgapped bundle

Run `make create-airgapped-image-bundle`

## Generate a Docker Image with the latest database version

Run `make latest_image_tag`

## Publish Docker image to Registry

Run `make publish-trivy-bundled-image`

## Delete intermediate files

Run `make clean`
