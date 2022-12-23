TRIVY_IMAGE_TAG ?= 0.35.0
OUTPUT_IMAGE ?= mesosphere/trivy-bundles

TIMESTAMP ?= $(shell date -u +%Y%m%dT%H%M%SZ )
OUTPUT_IMAGE_TAG = $(TRIVY_IMAGE_TAG)-$(TIMESTAMP)

publish-trivy-bundled-image: latest_image_tag
	docker push `cat latest_image_tag`

.PHONY: latest_image_tag
latest_image_tag:
	docker build --build-arg TRIVY_IMAGE_TAG=$(TRIVY_IMAGE_TAG) --build-arg TIMESTAMP=$(TIMESTAMP) -t $(OUTPUT_IMAGE):$(OUTPUT_IMAGE_TAG) .
	echo $(OUTPUT_IMAGE):$(OUTPUT_IMAGE_TAG) > latest_image_tag
