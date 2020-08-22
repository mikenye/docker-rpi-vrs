#!/bin/sh

REPO=mikenye
IMAGE=virtualradarserver
PLATFORMS="linux/amd64,linux/arm/v6,linux/arm/v7,linux/arm64"

docker context use x86_64
export DOCKER_CLI_EXPERIMENTAL="enabled"
docker buildx use homecluster

# Build the image using buildx
docker buildx build --no-cache -t ${REPO}/${IMAGE}:latest --compress --push --platform "${PLATFORMS}" . || exit 1
docker pull ${REPO}/${IMAGE}:latest || exit 1

# Starting container to pull version from container logs
VERSION=`docker run --rm --name get_vrs_version --entrypoint cat ${REPO}/${IMAGE}:latest /VERSION || exit 1`
# Tag the freshly built image
echo ""
echo VirtualRadarServer version ${VERSION} found
echo ""
docker buildx build -t ${REPO}/${IMAGE}:${VERSION} --compress --push --platform "${PLATFORMS}" . || exit 1
