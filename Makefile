NAME = postgres-toolbox
TAG = latest
IMAGE_NAME := panubo/$(NAME)

.PHONY: help build test clean push

help:
	@printf "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)\n"

build: ## Builds docker image
	docker build --pull -t $(IMAGE_NAME):$(TAG) .

test: ## Run tests
	./tests/dind-runner.sh

clean: ## Remove built image
	docker rmi $(IMAGE_NAME):$(TAG)

push: ## Pushes the docker image to hub.docker.com
	docker push $(IMAGE_NAME):$(TAG)
