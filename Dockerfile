ARG DISTROLESS_NON_ROOT_IMG
ARG TRIVY_IMAGE_TAG

FROM aquasec/trivy:${TRIVY_IMAGE_TAG} as build
WORKDIR /
RUN mkdir /trivy_cache
RUN chown 65532:65532 /trivy_cache

# Run as nonroot user using numeric ID for compatibllity.
USER 65532

# Download db and cache it.
RUN trivy image --download-db-only --cache-dir /trivy_cache
RUN trivy image --download-java-db-only --cache-dir /trivy_cache
RUN ls -Rl /trivy_cache

# Prepare distroless image for release.
FROM ${DISTROLESS_NON_ROOT_IMG}

COPY --from=build --chown=nonroot:nonroot /trivy_cache /trivy_cache
COPY --from=build --chown=nonroot:nonroot /contrib /contrib
COPY --from=build --chown=nonroot:nonroot /usr/local/bin/trivy /usr/bin/trivy

USER nonroot
WORKDIR /

# echo ${TIMESTAMP} prevents docker from using cache when a new value of TIMESTAMP is provided
ARG TIMESTAMP
RUN echo ${TIMESTAMP}

ENTRYPOINT ["trivy"]
