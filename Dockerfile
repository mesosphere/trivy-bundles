ARG TRIVY_IMAGE_TAG
FROM aquasec/trivy:${TRIVY_IMAGE_TAG}

WORKDIR /
RUN mkdir /trivy_cache
RUN chown 65532:65532 /trivy_cache

# Run as nonroot user using numeric ID for compatibllity.
USER 65532

# echo ${TIMESTAMP} prevents docker from using cache when a new value of TIMESTAMP is provided
ARG TIMESTAMP
RUN echo ${TIMESTAMP}

RUN trivy image --download-db-only --cache-dir /trivy_cache
RUN ls -Rl /trivy_cache

ENTRYPOINT ["trivy"]
