ifeq ($(origin TRIVY_VERSION), undefined)
$(error Required env-var TRIVY_VERSION has not been set, please set TRIVY_VERSION to the version matching the NKP/DKP release. See README for details)	
endif 

ROOT_DIR := $(shell cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
TIMESTAMP ?= $(shell date -u +%Y%m%dT%H%M%SZ )

REGISTRY ?= docker.io
REPOSITORY ?= mesosphere
IMAGE ?= trivy-bundles
TAG ?= $(TRIVY_VERSION)-$(TIMESTAMP)

IMAGE_NAME := $(REPOSITORY)/$(IMAGE):$(TAG)
IMAGE_NAME_FULL := $(REGISTRY)/$(IMAGE_NAME)

IMAGE_BUNDLE := $(IMAGE)-$(TAG).tar.gz

IMAGES_FILE ?= $(ROOT_DIR)/images.txt
TAGS_FILE ?= $(ROOT_DIR)/tags.txt

DISTROLESS_NON_ROOT_IMG ?= cgr.dev/chainguard/busybox:latest@sha256:5c46e3a84fa2c0e9cb556bd5aacab23d9e36a0a35b65875406b2a6ac49e7ac92

.DEFAULT_GOAL := help

# Tooling needed for mindthegap
MINDTHEGAP_VERSION ?= v1.16.0
TOOLS_DIR ?= $(ROOT_DIR)/.local/tools

MINDTHEGAP_BIN = $(TOOLS_DIR)/mindthegap

HOST_ARCH=$(shell uname -m)
OS=$(shell uname -s | tr '[:upper:]' '[:lower:]')

ifeq ($(HOST_ARCH),amd64)
ARCH := amd64
else ifeq ($(HOST_ARCH),x86_64)
ARCH := amd64
else ifeq ($(HOST_ARCH),arm64)
ARCH := amd64
endif

# Enable ONESHELL for all targets
.ONESHELL:

.PHONY: clean
clean: ## Clear all intermedieate files
clean: 
	rm $(IMAGES_FILE) $(TAGS_FILE)

.PHONY: create-airgapped-image-bundle
create-airgapped-image-bundle: ## Create airgapped image bundle
create-airgapped-image-bundle: install-mindthegap publish-trivy-bundled-image
	$(call print-target)
	$(MINDTHEGAP_BIN) create image-bundle --platform linux/amd64 --images-file $(IMAGES_FILE) --output-file $(IMAGE)-`cat $(TAGS_FILE)`.tar.gz

.PHONY: publish-trivy-bundled-image
publish-trivy-bundled-image: ## Publish image to registry
publish-trivy-bundled-image: latest_image_tag
	$(call print-target)
	docker push `cat $(IMAGES_FILE)`

.PHONY: latest_image_tag
latest_image_tag: ## Build an image with specified version and tag
latest_image_tag:
	$(call print-target)
	docker build --platform linux/amd64 --build-arg TRIVY_IMAGE_TAG=$(TRIVY_VERSION) --build-arg TIMESTAMP=$(TIMESTAMP) --build-arg DISTROLESS_NON_ROOT_IMG=$(DISTROLESS_NON_ROOT_IMG) -t $(IMAGE_NAME_FULL) .
	echo $(IMAGE_NAME_FULL) > $(IMAGES_FILE)
	echo $(TAG) > $(TAGS_FILE)

.PHONY: install-mindthegap
install-mindthegap: ## Install mind-the-gap binary.
install-mindthegap: $(MINDTHEGAP_BIN)
	$(call print-target)

$(MINDTHEGAP_BIN):
	mkdir -p $(dir $@)
	curl -Lf https://github.com/mesosphere/mindthegap/releases/download/$(MINDTHEGAP_VERSION)/mindthegap_$(MINDTHEGAP_VERSION)_$(OS)_$(ARCH).tar.gz | tar -xz -C $(TOOLS_DIR) 'mindthegap'

.PHONY: help
help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":"}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' | sort

define print-target
		@printf "Executing target: \033[36m$@\033[0m\n"
endef
