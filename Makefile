CONTAINER_NAME = docker-concourse-init
NAME = dmacedo/docker-concourse-init
VERSION = 4.2

.PHONY: all build test tag_latest release ssh

## [default] Build and run
all: build tag

## Build tagged container
build:
	docker build -t ${NAME}:${VERSION} .

## Docker tagging
tag: tag_latest tag_version

## Tag latest release
tag_latest:
	@echo 'Create tag latest'
	docker tag ${NAME}:${VERSION} ${NAME}:latest

## Tag version release
tag_version:
	@echo 'Create tag ${VERSION}'
	docker tag ${NAME}:${VERSION} ${NAME}:${VERSION}

## Push latest release
release: tag_latest
	@if ! docker images ${NAME} | awk '{ print $$2 }' | grep -q -F ${VERSION}; then echo "${NAME} version ${VERSION} is not yet built. Please run 'make build'"; false; fi
	docker push ${NAME}
	@echo "*** Don't forget to create a tag by creating an official GitHub release."

## Print this help
help:
	@awk -v skip=1 \
		'/^##/ { sub(/^[#[:blank:]]*/, "", $$0); doc_h=$$0; doc=""; skip=0; next } \
		 skip  { next } \
		 /^#/  { doc=doc "\n" substr($$0, 2); next } \
		 /:/   { sub(/:.*/, "", $$0); printf "\033[34m%-30s\033[0m\033[1m%s\033[0m %s\n\n", $$0, doc_h, doc; skip=1 }' \
		$(MAKEFILE_LIST)
