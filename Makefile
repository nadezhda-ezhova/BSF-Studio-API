cnf ?= config.env
include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

dpl ?= deploy.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

# grep the version from the mix file
VERSION=$(shell ./version.sh)

# HELP
# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

## This help.
help:
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

## Build the container
build:
	docker build -t $(APP_NAME) .

## Deploy container to cluster
deploy:
	cat kube.yml | sed "s/{{VERSION}}/${VERSION}/g" | kubectl apply -f -

## Publish the `{version}` taged container to Registry
publish-version: tag-version
	@echo 'publish $(VERSION) to $(DOCKER_REPO)'
	docker push $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

## Generate container `latest` tag
tag-version:
	@echo 'create tag $(VERSION)'
	docker tag $(APP_NAME) $(DOCKER_REPO)/$(APP_NAME):$(VERSION)

## Run container with params configured in `config.env`
run:
	docker run -i -t --rm --env-file=./config.env -p 80:3000 --name="$(APP_NAME)" $(APP_NAME)

## Output the current version
version:
	@echo $(VERSION)