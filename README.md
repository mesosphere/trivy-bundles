# Trivy Bundles

This repository creates a bundled Aquasec Trivy image with a timestamped database.

This repository mainly uses Makefile targets to perform the required actions.
Run `make help` to discover all of them.

### Generate a Docker Image with the latest database version.
Run `make latest_image_tag`

### Publish Docker image to DockerHub
Run `make publish-trivy-bundled-image`

### Create an airgapped bundle
Run `make create-airgapped-image-bundle`

### Delete intermediate files
Run `make clean`
